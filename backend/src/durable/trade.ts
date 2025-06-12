import { DurableObject } from "cloudflare:workers";
import currency from 'currency.js';
import { D1QB, DefaultReturnObject } from "workers-qb";
import { BackeEndEnv } from "../graphql/builder";

/* 
Method defined in this class
the main url route is: ws://127.0.0.1:8787/trade?userId={userId}
it has the following method:
getMainData: {"reqType": "getMainData"}
newOrder: {"reqType": "newOrder", "amount": {int}, "price": {int}, type: {0 or 1}}
cancelOrder: {"reqType": "cancelOrder", "orderId": {int}}
*/

export class TradeShare extends DurableObject {
	private sessions: Map<WebSocket, Session>;
	private tax: number = 100; // 100 sp (100 ليرة سورية)

	constructor(private state: DurableObjectState, env: BackeEndEnv) {
		super(state, env);
		this.sessions = new Map();

		// Restore any existing WebSocket sessions after a potential DO restart/hibernate
		for (const ws of this.state.getWebSockets()) {
			const s = ws.deserializeAttachment() as Session | null;
			if (s && s.userId) {
				this.sessions.set(ws, { userId: s.userId });
				try { this.state.acceptWebSocket(ws) }
				catch (e) {
					ws.close(1011, "Session data lost");
					this.sessions.delete(ws);
				}
			} else {
				ws.close(1011, "Session data lost");
			}
		}
	}

	async fetch(request: Request): Promise<Response> {
		const url = new URL(request.url);
		const userId = Number(url.searchParams.get("userId") ?? 0);
		if (userId == 0) return new Response("User ID is required for WebSocket connection.", { status: 400 });

		// Enforce single connection per user: close any existing socket for this user
		for (const [ws, session] of this.sessions) {
			if (session.userId === userId) {
				try { ws.close(1000, "Another session opened"); } catch (_) {/* ignore errors closing */ }
				this.sessions.delete(ws);
				break;
			}
		}

		// Create a new WebSocket pair and accept the server side in the DO
		const pair = new WebSocketPair();
		const [client, server] = Object.values(pair);
		this.state.acceptWebSocket(server);  // Accept the WebSocket in the Durable Object context for hibernation support
		server.serializeAttachment({ userId }); // Attach userId to allow session
		this.sessions.set(server, { userId }); // Store the new session

		// Return the client end of the WebSocket pair to complete the handshake
		return new Response(null, { status: 101, webSocket: client });
	}

	private async broadcast() {
		const orders: OpenOrder[] = await this.getOpenOrders()

		for (const [ws] of this.sessions) {
			try {
				ws.send(JSON.stringify({ result: true, type: 'broadcast', data: orders }));
			} catch (err) {
				this.sessions.delete(ws);
				try { ws.close(1011, "Connection error"); } catch (_) { }
			}
		}
	}

	async webSocketMessage(ws: WebSocket, message: string) {
		await this.state.blockConcurrencyWhile(async () => {
			const { userId } = ws.deserializeAttachment() as { userId: number };

			if (!userId) {
				try { ws.close(1011, "Internal error: userId not found"); } catch { }
				return;
			};

			let data: any;
			try { data = JSON.parse(message) } catch (e) { ws.send(JSON.stringify({ result: false, data: "error in webSocketMessage" })); }

			try {
				switch (data.reqType) {
					case "getMainData":
						const orders: OpenOrder[] = await this.getOpenOrders()
						ws.send(JSON.stringify({ result: true, type: 'getMainData', data: orders }));
						break;

					case "newOrder":
						let { amount, price, type } = data;

						if (typeof amount !== "number" || amount <= 0 || typeof price !== "number" || price < 0 || (type !== 0 && type !== 1)) break;

						amount = Math.floor(amount)
						price = Math.floor(price)

						const { balance, shares } = await this.getAvailableBalance(userId);

						const balanceVal = currency(balance).value;

						let checkTotal: number = 0;
						if (price == 0) { // best market price
							checkTotal = await this.getMarketPrice(type, amount)
						} else {
							checkTotal = (amount * price)
						}

						if (checkTotal == 0 && price == 0) break; // no opposite‐side liquidity → reject the order
						if (amount > 30) amount = 30 // setup max amount

						checkTotal += this.tax; // check with tax

						if (type == 0 && checkTotal > balanceVal) {  // buy order
							ws.send(JSON.stringify({ result: false, type: 'newOrder', data: 'insufficient balance' }));
							break;
						}

						if (type == 1 && amount > shares) {  // sell order
							ws.send(JSON.stringify({ result: false, type: 'newOrder', data: 'insufficient shares' }));
							break;
						}

						if (type == 1 && balanceVal < this.tax) { // sell order
							ws.send(JSON.stringify({ result: false, type: 'newOrder', data: 'insufficient balance for tax' }));
							break
						}

						let { affected, statements, totalPrice } = await this.placeNewOrder(amount, price, type, userId)

						statements = (type == 0)
							? await this.editOwnersBalanceForBuy(affected, userId, statements, totalPrice)
							: await this.editOwnersBalanceForSell(affected, userId, statements, totalPrice)

						let rawStatements = this.convertToQuery(statements)

						const database = new D1QB((this.env as BackeEndEnv).USER_DB)
						await database.batchExecute(rawStatements)

						ws.send(JSON.stringify({ result: true, type: 'newOrder', data: true }));
						await this.broadcast()
						break;

					case "cancelOrder":
						const { orderId } = data;

						if (!orderId || typeof orderId !== "number" || orderId <= 0) break;
						await this.cancelOrder(userId, orderId)
						ws.send(JSON.stringify({ result: true, type: 'cancelOrder', data: true }));
						await this.broadcast();
						break;

					default:
						console.warn("Unknown action type:", data);
						ws.send(JSON.stringify({ result: false, data: "Unknown action" }));
				}
			} catch (error) {
				console.error("Error handling WebSocket message:", error);
			}
		})
	}

	webSocketClose(ws: WebSocket) {
		const session = this.sessions.get(ws);
		if (session) this.sessions.delete(ws);
	}

	webSocketError(ws: WebSocket, err: Error) {
		console.error("WebSocket error:", err);
		this.sessions.delete(ws);
	}

	async getOpenOrders(): Promise<OpenOrder[]> {
		let orders: OpenOrder[] = []

		const database = new D1QB((this.env as BackeEndEnv).USER_DB)
		const res = await database.fetchAll({ tableName: 'trade', where: { conditions: 'orderStatus = 1' } }).execute()

		if (res.results && res.results?.length > 0) {
			for (const el of res.results) {
				orders.push({
					amount: el.amount as number,
					executed: el.executed as number,
					price: el.price as number,
					orderType: el.orderType as number,
				});
			}
		}

		return orders
	}

	async placeNewOrder(amount: number, price: number, type: number, userId: number): Promise<AffectedResult> {
		let result: AffectedResult = { affected: [], statements: { changes: [], balances: [] }, totalPrice: 0, }

		let statment = '';

		// type 0 mean buy order
		if (type == 0) statment = 'orderStatus = 1 AND orderType = 1' // buy Statement
		else statment = 'orderStatus = 1 AND orderType = 0' // sell Statement

		// if price is 0 this mean best market price or set it based on price
		if (price != 0) statment += type == 0 ? ' AND price <= ?1' : ' AND price >= ?1'
		const params = price != 0 ? [price] : null;

		let res: { results?: DefaultReturnObject[] | undefined } = {}

		const database = new D1QB((this.env as BackeEndEnv).USER_DB)
		try { res = await database.fetchAll({ tableName: 'trade', where: { conditions: statment, params: params } }).execute() }
		catch (err) { console.error("Error in placeNewOrder fetchAll:", err) }

		if (res.results != undefined && res.results.length > 0) {
			const orders = res.results.sort((a, b) => {
				const aPrice = a.price as number;
				const bPrice = b.price as number;
				const aCreatedAt = a.createdAt as number;
				const bCreateAt = b.createdAt as number;

				// 1) Market orders: price == 0
				if (price == 0) {
					if (aPrice != bPrice) return type == 1 ? bPrice - aPrice : aPrice - bPrice; // type 0 (buy) → ascending; type 1 (sell) → descending
					return aCreatedAt - bCreateAt; // same price → oldest first
				}

				// 2) Limit orders: price !== 0
				const aIsMain = aPrice == price;
				const bIsMain = bPrice == price;

				// a) Exact‐price orders first
				if (aIsMain != bIsMain) return aIsMain ? -1 : 1;
				if (aIsMain && bIsMain) return aCreatedAt - bCreateAt;

				// b) The “others” → best‐price first based on side
				if (aPrice !== bPrice) {
					return type === 1
						? aPrice - bPrice   // buying: cheapest asks first
						: bPrice - aPrice;  // selling: highest bids first
				}

				// c) Tie‐break on timestamp
				return aCreatedAt - bCreateAt;
			});

			let remainingAmount = amount;

			for (let i = 0; i < orders.length; i++) {
				const el = orders[i];

				let availableAmount: number = (el.amount as number) - (el.executed as number)

				if (availableAmount > remainingAmount) {
					const executedAmount = (el.executed as number) + remainingAmount;
					result.statements.changes.push(
						database.insert({
							tableName: 'trade',
							data: {
								createdAt: Date.now(),
								amount: amount,
								price: price,
								orderType: type,
								executed: remainingAmount,
								orderStatus: 2,
								userId: userId,
							}
						})
					)

					result.statements.changes.push(
						database.update({
							tableName: 'trade',
							data: { executed: executedAmount, orderStatus: 1 },
							where: { conditions: 'id = ?1', params: [el.id] },
						})
					)

					result.affected.push({ ownerId: el.userId as number, amount: remainingAmount, price: el.price as number });
					result.totalPrice += el.price as number * remainingAmount

					remainingAmount = 0;

					break;
				}

				else if (availableAmount == remainingAmount) {
					const executedAmount = (el.executed as number) + remainingAmount;

					result.statements.changes.push(
						database.insert({
							tableName: 'trade',
							data: {
								createdAt: Date.now(),
								amount: amount,
								price: price,
								orderType: type,
								executed: amount,
								orderStatus: 2,
								userId: userId,
							}
						})
					)

					result.statements.changes.push(
						database.update({
							tableName: 'trade',
							data: { executed: executedAmount, orderStatus: 2 },
							where: { conditions: 'id = ?1', params: [el.id] },
						})
					)

					result.affected.push({ ownerId: el.userId as number, amount: remainingAmount, price: el.price as number });
					result.totalPrice += el.price as number * remainingAmount
					remainingAmount = 0;

					break;
				}

				// only edit the counterparty exected amount, and the new initiator’s order will be added eventully in > or == condition
				// becuase if I add insert new order this mean I have to insert several order for same original order
				else { // availableAmount < remainingAmount
					result.statements.changes.push(
						database.update({
							tableName: 'trade',
							data: { executed: el.amount, orderStatus: 2 },
							where: { conditions: 'id = ?1', params: [el.id] },
						})
					)

					result.affected.push({ ownerId: el.userId as number, amount: el.amount as number, price: el.price as number })
					result.totalPrice += el.price as number * availableAmount

					remainingAmount -= availableAmount
				}
			}

			// if there are still remaining amount
			if (remainingAmount > 0) {
				result.statements.changes.push(
					database.insert({
						tableName: 'trade',
						data: {
							createdAt: Date.now(),
							amount: amount,
							price: price,
							orderType: type,
							executed: amount - remainingAmount,
							orderStatus: 1,
							userId: userId,
						}
					})
				)
			}
		}

		else {
			result.statements.changes.push(
				database.insert({
					tableName: 'trade',
					data: {
						createdAt: Date.now(),
						amount: amount,
						price: price,
						orderType: type,
						executed: 0,
						orderStatus: 1,
						userId: userId,
					}
				})
			)
		}

		return result;
	}

	async cancelOrder(userId: number, orderId: number): Promise<boolean> {
		const database = new D1QB((this.env as BackeEndEnv).USER_DB)
		await database.update({
			tableName: 'trade',
			data: { orderStatus: 0 },
			where: { conditions: 'userId = ?1 AND id = ?2', params: [userId, orderId] },
		}).execute()

		return true
	}

	async getMarketPrice(orderType: number, amount: number) {
		let total = 0;
		const database = new D1QB((this.env as BackeEndEnv).USER_DB)
		const res = await database.fetchAll({ tableName: 'trade', where: { conditions: 'orderStatus = 1' } }).execute()
		if (res.results && res.results.length > 0) {
			const type = orderType == 0 ? 1 : 0;
			let orders = res.results.filter(el => el.orderType == type);
			orders = orders.sort((a, b) => {
				if (a.price !== b.price && orderType == 0) return (a.price as number) - (b.price as number);
				if (a.price !== b.price && orderType == 1) return (b.price as number) - (a.price as number);
				return (a.createdAt as number) - (b.createdAt as number);
			});

			let a = amount
			for (const el of orders) {
				if (a > (el.amount as number)) {
					total += (el.amount as number) * (el.price as number);
					a -= el.amount as number;
				} else {
					total += a * (el.price as number);
					a -= a;
					break;
				}
			}
		}

		return total;
	}

	async getAvailableBalance(userId: number) {
		let data = { balance: '', shares: 0 };

		const database = new D1QB((this.env as BackeEndEnv).USER_DB)
		const res = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [userId] } }).execute()
		if (res.results != undefined) {
			data.balance = res.results.balance as string
			data.shares = res.results.shares as number
		}

		const db = new D1QB((this.env as BackeEndEnv).USER_DB)
		const userTrade = await db.fetchAll({ tableName: 'trade', where: { conditions: 'userId = ?1 AND orderStatus = 1', params: [userId] } }).execute();

		if (userTrade.results) {
			for (const el of userTrade.results) {
				const pending = (el.amount as number) - (el.executed as number);
				if (el.orderType == 0) data.balance = currency(data.balance).subtract(pending * (el.price as number)).toString();
				if (el.orderType == 1) data.shares -= pending;
			}
		}

		return data;
	}

	async editOwnersBalanceForBuy(affectedShares: AffectedShares[], userId: number, statements: RawStatements, totalOrderMoney: number) {
		const database = new D1QB((this.env as BackeEndEnv).USER_DB)
		let statms = statements

		let newOwnerTotalShares = 0;
		const money = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [userId] } }).execute()

		if (money.results) {
			const user = statms.balances.filter(el => el.userId == userId)
			if (user.length > 0) {
				user[0].balance = currency(money.results.balance as string).subtract(this.tax)
			} else {
				statms.balances.push({
					balance: currency(money.results.balance as string).subtract(this.tax),
					shares: money.results.shares as number,
					userId: userId
				})
			}
		}

		// buy statment => convert shares from sellers to buyer
		let totalExecuted: number = 0;

		for (const { ownerId, amount, price } of affectedShares) {
			totalExecuted += amount

			const sellerShares = await database.fetchAll({
				tableName: 'shares',
				orderBy: { amount: 'DESC' },
				where: { conditions: 'userId = ?1', params: [ownerId] }
			}).execute()
			const sellerBalance = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [ownerId] } }).execute()

			let sellerMoney = currency('0')
			let sellerTotalShares = 0
			if (sellerBalance.results) {
				sellerMoney = currency(sellerBalance.results.balance as string)
				sellerTotalShares = sellerBalance.results.shares as number
			}

			let requiredAmount = amount;

			for (const el of sellerShares.results!) {
				// edit old owner shares and add the shares to the new Owner
				if ((el.amount as number) > requiredAmount) {
					// edit sheres owner
					statms.changes.push(
						database.update({
							tableName: 'shares',
							data: { amount: (el.amount as number) - requiredAmount },
							where: { conditions: 'id = ?1', params: [el.id] }
						})
					)
					// add new owners shares
					statms.changes.push(
						database.insert({
							tableName: 'shares',
							data: { createdAt: Date.now(), taskId: el.taskId, amount: requiredAmount, source: 2, userId: userId }
						})
					)
					// edit old owner shares and balance
					const user = statms.balances.filter(el => el.userId == ownerId)
					if (user.length > 0) {
						user[0].balance = user[0].balance.add(requiredAmount * price)
						user[0].shares -= requiredAmount
					} else {
						statms.balances.push({
							balance: sellerMoney.add(requiredAmount * price),
							shares: sellerTotalShares - requiredAmount,
							userId: ownerId
						})
					}
					break;
				}

				else if ((el.amount as number) == requiredAmount) {
					// convert share owner to the new one
					statms.changes.push(
						database.update({
							tableName: 'shares',
							data: { createdAt: Date.now(), source: 2, userId: userId },
							where: { conditions: 'id = ?1', params: [el.id] }
						})
					)
					// edit old owner shares and balance
					const user = statms.balances.filter(el => el.userId == ownerId)
					if (user.length > 0) {
						user[0].balance = user[0].balance.add(requiredAmount * price)
						user[0].shares -= requiredAmount
					} else {
						statms.balances.push({
							balance: sellerMoney.add(requiredAmount * price),
							shares: sellerTotalShares - requiredAmount,
							userId: ownerId
						})
					}

					break;
				}

				else {
					// convert share owner to the new one
					statms.changes.push(
						database.update({
							tableName: 'shares',
							data: { createdAt: Date.now(), source: 2, userId: userId },
							where: { conditions: 'id = ?1', params: [el.id] }
						})
					)

					// edit old owner shares and balance
					const user = statms.balances.filter(el => el.userId == ownerId)
					if (user.length > 0) {
						user[0].balance = user[0].balance.add(el.amount as number * price)
						user[0].shares -= requiredAmount
					} else {
						statms.balances.push({
							balance: sellerMoney.add(el.amount as number * price),
							shares: sellerTotalShares - (el.amount as number),
							userId: ownerId
						})
					}

					requiredAmount -= el.amount as number
				}
			}
		}

		// minus money balance from the new owner plus tax
		if (affectedShares.length > 0) {
			const buyerBalance = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [userId] } }).execute()
			let buyerMoney = currency('0')
			if (buyerBalance.results) buyerMoney = currency(buyerBalance.results.balance as string)

			const user = statms.balances.filter(el => el.userId == userId)
			if (user.length > 0) {
				user[0].balance = user[0].balance.subtract(totalOrderMoney),
					user[0].shares += totalExecuted
			} else {
				statms.balances.push({
					balance: buyerMoney.subtract(totalOrderMoney),
					shares: newOwnerTotalShares + totalExecuted,
					userId: userId
				})
			}
		}

		return statms;
	}

	async editOwnersBalanceForSell(affectedShares: AffectedShares[], userId: number, statements: RawStatements, totalOrderMoney: number) {
		const database = new D1QB((this.env as BackeEndEnv).USER_DB)

		let statms = statements

		const money = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [userId] } }).execute()
		let sellerTotalShare = 0;
		let sellerMoney = currency('0')

		if (money.results) {
			sellerTotalShare = money.results.shares as number
			sellerMoney = currency(money.results.balance as string)

			const user = statms.balances.filter(el => el.userId == userId)
			if (user.length > 0) {
				user[0].balance = user[0].balance.subtract(this.tax)
			} else {
				statms.balances.push({
					balance: currency(money.results.balance as string).subtract(this.tax),
					shares: sellerTotalShare,
					userId: userId
				})
			}
		}

		const sellerShares = await database.fetchAll({
			tableName: 'shares',
			orderBy: { amount: 'DESC' },
			where: { conditions: 'userId = ?1', params: [userId] }
		}).execute()

		let totalExecuted = 0;

		for (const { ownerId, amount, price } of affectedShares) {
			const buyerBalance = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [ownerId] } }).execute()
			let buyerMoney = currency('0')
			let buyerTotalShares = 0

			if (buyerBalance.results) {
				buyerMoney = currency(buyerBalance.results.balance as string)
				buyerTotalShares = buyerBalance.results.shares as number
			}

			let requiredAmount = amount;

			for (const el of sellerShares.results!) {
				// edit old owner sheres
				if ((el.amount as number) > requiredAmount) {
					totalExecuted += requiredAmount
					statms.changes.push(
						database.update({
							tableName: 'shares',
							data: { amount: (el.amount as number) - requiredAmount },
							where: { conditions: 'id = ?1', params: [el.id] }
						})
					)

					statms.changes.push(
						database.insert({
							tableName: 'shares',
							data: { createdAt: Date.now(), taskId: el.taskId, amount: requiredAmount, source: 2, userId: ownerId }
						})
					)

					// edit new owner shares and balance
					const user = statms.balances.filter(el => el.userId == ownerId)
					if (user.length > 0) {
						user[0].balance = user[0].balance.subtract(requiredAmount * price),
							user[0].shares += requiredAmount
					} else {
						statms.balances.push({
							balance: buyerMoney.subtract(requiredAmount * price),
							shares: buyerTotalShares + requiredAmount,
							userId: ownerId
						})
					}
					break;
				}

				else if ((el.amount as number) == requiredAmount) {
					totalExecuted += requiredAmount

					// convert share owner to the new one
					statms.changes.push(
						database.update({
							tableName: 'shares',
							data: { createdAt: Date.now(), source: 2, userId: ownerId },
							where: { conditions: 'id = ?1', params: [el.id] }
						})
					)
					// edit new owner shares and balance
					const user = statms.balances.filter(el => el.userId == ownerId)
					if (user.length > 0) {
						user[0].balance = user[0].balance.subtract(requiredAmount * price),
							user[0].shares += requiredAmount
					} else {
						statms.balances.push({
							balance: buyerMoney.subtract(requiredAmount * price),
							shares: buyerTotalShares + requiredAmount,
							userId: ownerId
						})
					}
					break;
				}

				// convert share owner to the new one
				else {
					totalExecuted += el.amount as number
					statms.changes.push(
						database.update({
							tableName: 'shares',
							data: { createdAt: Date.now(), source: 2, userId: ownerId },
							where: { conditions: 'id = ?1', params: [el.id] }
						})
					)

					const user = statms.balances.filter(el => el.userId == ownerId)
					if (user.length > 0) {
						user[0].balance = user[0].balance.subtract((el.amount as number) * price),
							user[0].shares += requiredAmount
					} else {
						statms.balances.push({
							balance: buyerMoney.subtract((el.amount as number) * price),
							shares: buyerTotalShares + (el.amount as number),
							userId: ownerId
						})
					}

					requiredAmount -= (el.amount as number)
				}
			}
		}

		if (affectedShares.length > 0) {
			// edit balance shares from old owner
			const user = statms.balances.filter(el => el.userId == userId)
			if (user.length > 0) {
				user[0].balance = user[0].balance.add(totalOrderMoney)
				user[0].shares -= totalExecuted
			} else {
				statms.balances.push({
					balance: sellerMoney.add(totalOrderMoney),
					shares: sellerTotalShare - totalExecuted,
					userId: userId
				})
			}
		}

		return statms;
	}

	convertToQuery(statements: RawStatements): any[] {
		let queries = statements.changes;
		const database = new D1QB((this.env as BackeEndEnv).USER_DB)

		for (const el of statements.balances) {
			queries.push(
				database.update({
					tableName: 'user',
					data: { balance: el.balance.toString(), shares: el.shares },
					where: { conditions: 'id = ?1', params: [el.userId] }
				})
			)
		}

		return queries;
	}
}

interface Session {
	userId: number;
	sessionId?: string;
}

interface OpenOrder {
	amount: number;
	price: number;
	executed: number;
	orderType: number;
}

interface AffectedResult {
	totalPrice: number;
	affected: AffectedShares[];
	statements: RawStatements;
}

interface RawStatements {
	changes: any[]; // hold edit/insert of trade and shares
	balances: UserBalance[];
}

interface UserBalance {
	balance: currency;
	shares: number;
	userId: number;
}

interface AffectedShares {
	ownerId: number;
	amount: number;
	price: number;
}
import { D1QB } from "workers-qb";
import { checkAuth } from '../utils/check_auth'
import { BalanceData, queryBuilderType, BalanceWithHistory, ShareInfo } from "../graphql/types";
import { balanceDataRef, balanceWithHistoryRef, shareInfoRef } from "../graphql/refs";
import { GraphQLError } from "graphql/error";
import AppError from "../utils/error";

export default class Shares {
	static getBalanceData = (t: queryBuilderType) => t.field({
		type: balanceDataRef,
		args: {
			jwtToken: t.arg.string({ required: true }),
		},
                resolve: async (_parent, args, ctx) => {
                        const { id } = await checkAuth(args.jwtToken, ctx.env)

			const result: BalanceData = { balance: '', shares: 0, totalShares: 0, statistics: [], distruibutedProfit: [], sharesData: [] }

			const database = new D1QB(ctx.env.USER_DB)
			const user = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [id] } }).execute()
			if (user.results) {
				result.balance = user.results.balance as string
				result.shares = user.results.shares as number
			}

			const total = await database.fetchOne({ tableName: 'user', fields: 'SUM(shares) AS totalShares' }).execute()
			if (total.results) result.totalShares = total.results.totalShares as number

			const statisticsDB = new D1QB(ctx.env.STATISTICS_DB)
			const res = await statisticsDB.fetchAll({
				tableName: 'statistics',
				where: { conditions: 'createdAt > ?1', params: [Date.now() - (365 * 24 * 60 * 60 * 1000)] }, // yearAgo
				orderBy: { createdAt: 'DESC' }
			}).execute()

			if (res.results && res.results.length > 0) {
				for (const el of res.results) {
					result.statistics.push({ createdAt: el.createdAt as number, price: el.price as number })
				}

				const dayAge = Date.now() - (24 * 60 * 60 * 1000)
				if (res.results[0].createdAt as number < dayAge) {
					const tradeDB = new D1QB(ctx.env.USER_DB)
					const lastDayTrades = await tradeDB.fetchAll({
						tableName: 'trade',
						orderBy: { price: 'ASC' },
						where: { conditions: 'orderType = 1 AND createdAt > ?1', params: [dayAge] },
					}).execute()

					if (lastDayTrades.results && lastDayTrades.results.length > 0) {
						await statisticsDB.insert({ tableName: 'statistics', data: { createdAt: Date.now(), price: lastDayTrades.results[0].price } }).execute()
						result.statistics.push({ createdAt: Date.now(), price: lastDayTrades.results[0].price as number })
					}
				}
			}

			let results = [];
			let snapShots = [];

			const profitDB = new D1QB(ctx.env.PROFIT_DB)
			const snapshotDB = new D1QB(ctx.env.SNAPSHOT_DB)
			const res2 = await profitDB.fetchAll({ tableName: 'profit', orderBy: 'createdAt DESC', limit: 100 }).execute()
			if (res2.results && res2.results.length > 0) {
				results.push(...res2.results)

				const el = res2.results[res2.results.length - 1];

				const res3 = await snapshotDB.fetchAll({
					tableName: 'snapShot',
					orderBy: 'createdAt DESC',
					where: { conditions: `createdAt > ${el.createdAt} AND userId = ${id}` }
				}).execute()

				if (res3.results && res3.results.length > 0) {
					snapShots.push(...res3.results)

					const el = res3.results[res3.results.length - 1];

					const res4 = await snapshotDB.fetchAll({
						tableName: 'snapShot',
						limit: 1,
						where: { conditions: `createdAt < ${el.createdAt} AND userId = ${id}` }
					}).execute()
					if (res4.results && res4.results.length > 0) snapShots.push(...res4.results)
				}
			}

			for (const el of results) {
				let userShare: number = 0;

				for (const snap of snapShots) {
					if ((snap.createdAt as number) < (el.createdAt as number)) {
						userShare = snap.balance as number;
						break;
					}
				}

				result.distruibutedProfit.push({
					id: el.id as number,
					createdAt: el.createdAt as number,
					amount: el.amount as string,
					amountInfo: el.amountInfo as string,
					userShare: userShare,
				})
			}

			let shares: number = 0;

			const res5 = await database.fetchAll({ tableName: 'shares', where: { conditions: 'userId = ?1', params: [id] } }).execute()

			if (res5.results && res5.results.length > 0) {
				for (const el of res5.results) {
					shares += el.amount as number;

					result.sharesData.push({
						id: el.id as number,
						createdAt: el.createdAt as number,
						taskId: el.taskId as number,
						amount: el.amount as number,
						source: el.source as number,
					})
				}
			}

			return result;
		}
	})

	static getbalanceWithHistory = (t: queryBuilderType) => t.field({
		type: balanceWithHistoryRef,
		args: {
			jwtToken: t.arg.string({ required: true }),
		},
                resolve: async (_parent, args, ctx) => {
                        const { id } = await checkAuth(args.jwtToken, ctx.env)

			const data: BalanceWithHistory = { balance: '0', shares: 0, history: [] }

			const database = new D1QB(ctx.env.USER_DB)
			const res = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [id] } }).execute()
			if (res.results) {
				data.balance = res.results.balance as string
				data.shares = res.results.shares as number
			}

			const trades = await database.fetchAll({ tableName: 'trade', where: { conditions: 'userId = ?1', params: [id] } }).execute()
			if (trades.results && trades.results.length > 0) {
				for (const el of trades.results) {
					data.history.push({
						id: el.id as number,
						createdAt: el.createdAt as number,
						amount: el.amount as number,
						price: el.price as number,
						orderType: el.orderType as number,
						orderStatus: el.orderStatus as number,
						executed: el.executed as number,
					})
				}
			}

			return data;
		}
	})

	static getShareInfo = (t: queryBuilderType) => t.field({
		type: shareInfoRef,
		args: {
			jwtToken: t.arg.string({ required: true }),
			shareId: t.arg.int({ required: true }),
		},
                resolve: async (_parent, args, ctx) => {
                        await checkAuth(args.jwtToken, ctx.env)

			const database = new D1QB(ctx.env.TASK_DB)
			const res = await database.fetchOne({ tableName: 'userTask', where: { conditions: 'id = ?1', params: [args.shareId] } }).execute()

			if (!res.results) throw new GraphQLError(AppError.UNKNOW_ERROR);

			let data: ShareInfo = {
				time: res.results.time as number,
				shares: res.results.shares as number,
				userTaskName: res.results.userTaskName as string,
				level: res.results.level as string,
				curriculum: res.results.curriculum as string
			}

			return data;
		}
	})
}
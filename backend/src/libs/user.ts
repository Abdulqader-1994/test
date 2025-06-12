import { D1QB } from 'workers-qb';
import { checkAuth } from '../utils/check_auth'
import { GraphQLError } from 'graphql';
import AppError from '../utils/error';
import currency from 'currency.js';
import { Transection, Account, mutateBuilderType, queryBuilderType } from '../graphql/types';
import { transectionRef } from '../graphql/refs';

export default class User {
	static updateUserName = (t: mutateBuilderType) => t.field({
		type: 'Boolean',
		args: {
			jwtToken: t.arg.string({ required: true }),
			newUsername: t.arg.string({ required: true }),
		},
		resolve: async (_parent, args, ctx) => {
			if (args.newUsername.length < 5) throw new GraphQLError(AppError.USERNAME_CHARS_MIN)

			const { id } = await checkAuth(args.jwtToken)

			const database = new D1QB(ctx.env.USER_DB)
			let res = await database.fetchOne({
				tableName: 'user',
				where: { conditions: 'LOWER(userName) = LOWER(?1)', params: [args.newUsername] }
			}).execute()

			if (res.results) throw new GraphQLError(AppError.DATA_EXIST)

			res = await database.update({
				tableName: 'user',
				data: { userName: args.newUsername },
				where: { conditions: 'id = ?1', params: [id] }
			}).execute()
			if (!res.success) throw new GraphQLError(AppError.UNKNOW_ERROR)

			return true
		},
	})

	static updateDistributePercent = (t: mutateBuilderType) => t.field({
		type: 'Boolean',
		args: {
			jwtToken: t.arg.string({ required: true }),
			newVal: t.arg.int({ required: true }),
		},
		resolve: async (_parent, args, ctx) => {
			const { id } = await checkAuth(args.jwtToken)

			const database = new D1QB(ctx.env.USER_DB)
			await database.update({
				tableName: 'user',
				data: { distributePercent: args.newVal },
				where: { conditions: 'id = ?1', params: [id] },
			}).execute()

			return true
		},
	})

	static convertBuyShareToBalance = (t: mutateBuilderType) => t.field({
		type: 'String',
		args: {
			jwtToken: t.arg.string({ required: true }),
		},
		resolve: async (_parent, args, ctx) => {
			const { id } = await checkAuth(args.jwtToken)

			const database = new D1QB(ctx.env.USER_DB)
			const res = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [id] } }).execute()
			if (res.results == undefined) throw new GraphQLError(AppError.UNKNOW_ERROR)

			let balance = res.results.balance as string;
			let balanceToBuyShare = res.results!.balanceToBuyShare as string

			const newBalance = currency(balance).add(balanceToBuyShare)

			await database.update({
				tableName: 'user',
				data: { balance: balance.toString(), balanceToBuyShare: '0.0' },
				where: { conditions: 'id = ?1', params: [id] }
			}).execute()

			return newBalance.toString()
		},
	})

	static getTransections = (t: queryBuilderType) => t.field({
		type: [transectionRef],
		args: {
			jwtToken: t.arg.string({ required: true }),
			offset: t.arg.int({ required: true }),
		},
		resolve: async (_parent, args, ctx) => {
			const { id } = await checkAuth(args.jwtToken)

			/* await ctx.env.DATA.delete(`1-1-${0}`)
			for (let i = 0; i < 5; i++) {
				console.log(i);
				
				const dutableId = ctx.env.TASK.idFromName(i.toString())
				const durableTask = ctx.env.TASK.get(dutableId);
				await durableTask.deleteAll();
				await ctx.env.DATA.delete(`1-1-${i}`)
			} */

			const database = new D1QB(ctx.env.TRANSECTION_DB)
			const res = await database.fetchAll({
				tableName: 'Transection',
				// limit: 10, TODO: add offset system
				// offset: args.offset,
				where: { conditions: 'userId = ?1', params: [id] },
			}).execute()

			if (res.results == null) return []

			const results: Transection[] = [];

			res.results.forEach(el => results.push({
				id: el.id as number,
				userId: el.userId as number,
				amount: el.amount as string,
				currencyInfo: el.currencyInfo as string,
				time: el.time as number,
				provider: el.provider as string,
				type: el.type as number,
			}))

			return results;
		}
	})
}

import { D1QB } from "workers-qb";
import { ActiveTask, AdminAccount, Curriculum, mutateBuilderType, queryBuilderType } from "../graphql/types";
import { checkAuth } from "../utils/check_auth";
import { GraphQLError } from "graphql";
import AppError from "../utils/error";
import { activeTaskRef, adminAccountRef, curriculumRef } from "../graphql/refs";

export default class Admin {
	static getCurriculums = (t: queryBuilderType) => t.field({
		type: [curriculumRef],
		args: {
			jwtToken: t.arg.string({ required: true }),
		},
		resolve: async (_parent, args, ctx) => {
			const { isAdmin } = await checkAuth(args.jwtToken)
			if (!isAdmin) throw new GraphQLError(AppError.UN_AUTHED.toString());

			const result: Curriculum[] = [];

			const database = new D1QB(ctx.env.TASK_DB)
			const res = await database.fetchAll({ tableName: 'curriculum' }).execute()

			if (res.results == null) return result;

			for (let i = 0; i < res.results.length; i++) {
				result.push({
					id: res.results[i].id as number,
					name: res.results[i].name as string,
					countryId: res.results[i].countryId as number,
					levelType: res.results[i].levelType as number,
					semester: res.results[i].semester as number,
					level: res.results[i].level as string,
					completedPercent: res.results[i].completedPercent as number,
					openToWork: res.results[i].openToWork as number,
				})
			}

			return result;
		}
	})

	static editOrAddCurriculum = (t: mutateBuilderType) => t.field({
		type: 'Boolean',
		args: {
			id: t.arg.int({ required: false }),
			name: t.arg.string({ required: true }),
			countryId: t.arg.int({ required: true }),
			levelType: t.arg.int({ required: true }),
			level: t.arg.string({ required: true }),
			semester: t.arg.int({ required: true }),
			openToWork: t.arg.int({ required: true }),
			jwtToken: t.arg.string({ required: true }),
		},
		resolve: async (_parent, args, ctx) => {
			const { isAdmin } = await checkAuth(args.jwtToken)
			if (!isAdmin) throw new GraphQLError(AppError.UN_AUTHED.toString());

			const database = new D1QB(ctx.env.TASK_DB)
			if (args.id) {
				await database.update({
					tableName: 'curriculum',
					data: {
						name: args.name,
						countryId: args.countryId,
						levelType: args.levelType,
						level: args.level,
						semester: args.semester,
						openToWork: args.openToWork,
					},
					where: { conditions: `id = ${args.id}` }
				}).execute()
			} else {
				await database.insert({
					tableName: 'curriculum',
					data: {
						name: args.name,
						countryId: args.countryId,
						levelType: args.levelType,
						level: args.level,
						semester: args.semester,
						openToWork: args.openToWork,
					},
				}).execute()
			}

			return true;
		}
	})

	static getAllUsers = (t: queryBuilderType) => t.field({
		type: [adminAccountRef],
		args: {
			jwtToken: t.arg.string({ required: true }),
		},
		resolve: async (_parent, args, ctx) => {
			const { isAdmin } = await checkAuth(args.jwtToken)
			if (!isAdmin) throw new GraphQLError(AppError.UN_AUTHED.toString());

			const users: AdminAccount[] = []

			const db = new D1QB(ctx.env.USER_DB)
			const res = await db.fetchAll({ tableName: 'user' }).execute()

			res.results?.forEach(el => {
				users.push({
					id: el.id as number,
					userName: el.userName as string,
					loginType: el.loginType as number,
					loginInfo: el.loginInfo as string,
					country: el.country as number,
					time: el.time as number,
					balance: el.balance as string,
					shares: el.shares as number,
					trustPoint: el.trustPoint as number,
					balanceToBuyShare: el.balanceToBuyShare as string,
					distributePercent: el.distributePercent as number,
					isAdmin: el.isAdmin as number,
					adminPrivileges: el.adminPrivileges as number,
				})
			})

			return users;
		}
	})

	static createTask = (t: mutateBuilderType) => t.field({
		type: 'Boolean',
		args: {
			taskId: t.arg.int({ required: false }),
			status: t.arg.int({ required: false }),
			access: t.arg.int({ required: true }),
			jwtToken: t.arg.string({ required: true }),
			curriculumId: t.arg.int({ required: true }),
			shares: t.arg.int({ required: true }),
			parentId: t.arg.int({ required: true }),
			taskName: t.arg.string({ required: true }),
			taskType: t.arg.int({ required: true }),
			reDoIt: t.arg.int({ required: true }),
		},
		resolve: async (_parent, args, ctx) => {
			const { isAdmin } = await checkAuth(args.jwtToken)
			if (!isAdmin) throw new GraphQLError(AppError.UN_AUTHED.toString());

			const database = new D1QB(ctx.env.TASK_DB)

			// update task data
			if (args.taskId) {
				await database.update({
					tableName: 'task',
					data: {
						parentId: args.parentId,
						shares: args.shares,
						taskName: args.taskName,
						taskType: args.taskType,
						occupied: 0,
						reDoIt: args.reDoIt,
						reDoItNum: 0,
						access: args.access,
						status: args.status!,
					},
					where: { conditions: 'id = ?1', params: [args.taskId] }
				}).execute()
			}
			// create task data
			else {
				await database.insert({
					tableName: 'task',
					data: {
						parentId: args.parentId,
						time: Date.now(),
						shares: args.shares,
						occupied: 0,
						reDoIt: args.reDoIt,
						reDoItNum: 0,
						access: args.access,
						status: -1,
						taskName: args.taskName,
						taskType: args.taskType,
						curriculumId: args.curriculumId,
					},
				}).execute()
			}

			return true;
		}
	})

	static getTasks = (t: queryBuilderType) => t.field({
		type: [activeTaskRef],
		args: {
			jwtToken: t.arg.string({ required: true }),
			curriculumId: t.arg.int({ required: true }),
		},
		resolve: async (_parent, args, ctx) => {
			const { isAdmin } = await checkAuth(args.jwtToken)
			if (!isAdmin) throw new GraphQLError(AppError.UN_AUTHED.toString());

			const database = new D1QB(ctx.env.TASK_DB)

			let res = await database.fetchAll({ tableName: 'task' }).execute()
			if (res.results == undefined || res.results.length == 0) return [];

			const result: ActiveTask[] = [];
			for (let i = 0; i < res.results.length; i++) {
				result.push({
					id: res.results[i].id as number,
					time: res.results[i].time as number,
					shares: res.results[i].shares as number,
					taskType: res.results[i].taskType as number,
					taskName: res.results[i].taskName as string,
					curriculumId: res.results[i].curriculumId as number,
					parentId: res.results[i].parentId as number,
					status: res.results[i].status as number,
					occupied: res.results[i].occupied as number,
					occupiedTime: res.results[i].occupiedTime as number,
					reDoIt: res.results[i].reDoIt as number,
					reDoItNum: res.results[i].reDoItNum as number,
					access: res.results[i].access as number,
				})
			}

			return result;
		}
	})

	static submitShares = (t: mutateBuilderType) => t.field({
		type: 'Boolean',
		args: {
			jwtToken: t.arg.string({ required: true }),
			curriculumId: t.arg.int({ required: true }),
			taskId: t.arg.int({ required: true }),
			data: t.arg.string({ required: true }), // data for user shares
		},
		resolve: async (_parent, args, ctx) => {
			const { isAdmin } = await checkAuth(args.jwtToken)
			if (!isAdmin) throw new GraphQLError(AppError.UN_AUTHED.toString())

			const data: any[] = JSON.parse(args.data)

			const database = new D1QB(ctx.env.USER_DB)

			for (let i = 0; i < data.length; i++) {
				const el = data[i]; /* has these props: shares: the finilized given shares, taskShare: the default task share */

				const user = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [el.id] }, }).execute()
				if (!user.results) continue;

				const db = new D1QB(ctx.env.TASK_DB)
				await db.update({
					tableName: 'userTask',
					data: { userShare: el.shares, status: 2 },
					where: { conditions: 'taskId = ?1 AND curriculumId = ?2 AND userId = ?3', params: [args.taskId, args.curriculumId, el.id] },
				}).execute()

				let trustPoint = user.results.trustPoint as number
				if (!isAdmin) {
					let taskPoint = 3; // default for every task that has more then 80% correct
					if (el.shares < (el.taskShare as number) / 5 * 4) taskPoint = 2 // less than 60 %
					if (el.shares < (el.taskShare as number) / 5 * 2) taskPoint = 1 // less than 40 %
					if (el.shares == 0) taskPoint = 0;

					trustPoint += taskPoint
				}

				await database.insert({
					tableName: 'shares',
					data: { createdAt: Date.now(), taskId: args.taskId, amount: el.shares, source: 1, userId: el.id }
				}).execute()

				let userTotalShares = el.shares + user.results.shares;

				await database.update({
					tableName: 'user',
					data: { shares: userTotalShares, trustPoint: trustPoint },
					where: { conditions: 'id = ?1', params: [el.id] }
				}).execute()
			}

			return true
		}
	})

	static async addUserTransection(args: any, ctx: any) {
		const database = new D1QB(ctx.USER_DB)

		const res = await database.insert({
			tableName: 'Transection',
			data: {
				userId: args.userId,
				time: Date.now(),
				amount: args.amount,
				currencyInfo: args.currencyInfo,
				provider: args.provider,
				type: args.type,
			},
			returning: ['id', 'time'],
		}).execute()

		if (res.results == null) throw new GraphQLError(AppError.UNKNOW_ERROR);

		var trans = {
			id: res.results.id as number,
			userId: args.userId,
			amount: args.amount,
			currencyInfo: args.currencyInfo,
			time: res.results.time as number,
			provider: args.provider,
			type: args.type,
		}

		return trans;
	}
}
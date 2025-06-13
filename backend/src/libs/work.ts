import { D1QB } from "workers-qb"
import { checkAuth } from '../utils/check_auth'
import { Curriculum, ActiveTask, DoneTask, queryBuilderType, mutateBuilderType } from "../graphql/types";
import { activeTaskRef, curriculumRef, doneTaskRef } from "../graphql/refs";
import { GraphQLError } from "graphql";
import AppError from "../utils/error";

export default class Work {
	static getCurriculums = (t: queryBuilderType) => t.field({
		type: [curriculumRef],
		args: {
			jwtToken: t.arg.string({ required: true }),
		},
                resolve: async (_parent, args, ctx) => {
                        const { id, isAdmin } = await checkAuth(args.jwtToken, ctx.env)

			if (!isAdmin) {
				const database = new D1QB(ctx.env.USER_DB)
				let res = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [id] } }).execute()
				if (res.results!.trustPoint == 0) throw new GraphQLError(AppError.ZERO_TRUST);
			}

			const db = new D1QB(ctx.env.TASK_DB)
			const res = await db.fetchAll({ tableName: 'curriculum', where: { conditions: 'openToWork = 1 AND completedPercent != 100' } }).execute()

			if (res.results == null) return [];

			const result: Curriculum[] = [];
			for (let i = 0; i < res.results.length; i++) {
				const el = res.results[i];
				if (el.openToWork == 0) continue;

				result.push({
					id: el.id as number,
					name: el.name as string,
					countryId: el.countryId as number,
					levelType: el.levelType as number,
					level: el.level as string,
					semester: el.semester as number,
					completedPercent: el.completedPercent as number,
					openToWork: el.openToWork as number,
				})
			}

			return result;
		}
	})

	static getActiveTasks = (t: queryBuilderType) => t.field({
		type: [activeTaskRef],
		args: {
			jwtToken: t.arg.string({ required: true }),
			curriculumId: t.arg.int({ required: true })
		},
                resolve: async (_parent, args, ctx) => {
                        const { id, isAdmin } = await checkAuth(args.jwtToken, ctx.env)

			if (!isAdmin) {
				const database = new D1QB(ctx.env.USER_DB)
				let res = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [id] } }).execute()

				if (res.results!.trustPoint == 0) throw new GraphQLError(AppError.WRONG_DATA);
			}

			let tasks: ActiveTask[] = []

			let data: any[] = [];

			if (isAdmin) {
				const database = new D1QB(ctx.env.TASK_DB)

				let res = await database.fetchAll({
					tableName: 'task',
					where: { conditions: '(occupied = 0 OR occupied = ?1) AND status < 3', params: [id] }
				}).execute()

				if (res.results != undefined && res.results.length > 0) data = res.results;
			}
			else {
				const durableId = ctx.env.TASK_LAB.idFromName(`task-${args.curriculumId.toString()}`)
				const durableTask = ctx.env.TASK_LAB.get(durableId)
				await durableTask.resetTasks();

				type returning = {
					// task
					id: number
					parentId: number
					time: number
					shares: number
					status: number
					occupied: number
					occupiedTime: number | null
					reDoIt: number
					reDoItNum: number
					access: number
					taskName: string,
					taskType: number,

					// curriculum
					name: string
					level: string
				}

				const fields = [
					// --- task columns
					'task.id',
					'task.parentId',
					'task.time',
					'task.shares',
					'task.status',
					'task.occupied',
					'task.occupiedTime',
					'task.reDoIt',
					'task.reDoItNum',
					'task.access',

					// curriculum
					'curriculum.name',
					'curriculum.level',
				]

				const database = new D1QB(ctx.env.TASK_DB)
				let res = await database.fetchAll<returning>({
					tableName: 'task',
					fields: fields,
					where: { conditions: 'status = 1 AND access = 0 AND (occupied = 0 OR occupied = ?1)', params: [id] },
					join: { type: 'INNER', table: 'curriculum', on: 'task.curriculumId = curriculum.id' },
				}).execute()

				if (res.results != undefined && res.results.length > 0) {
					data = res.results
				} else {
					res = await database.fetchAll<returning>({
						tableName: 'task',
						fields: fields,
						where: { conditions: 'status = 0 AND access = 0 AND (occupied = 0 OR occupied = ?1)' },
						join: { type: 'INNER', table: 'curriculum', on: 'task.curriculumId = curriculum.id' },
					}).execute()
					if (res.results != undefined && res.results.length > 0) data = res.results;
				}
			}

			if (data.length == 0) return tasks;

			for (let i = 0; i < data.length; i++) {
				if (data[i].userTaskId != null && data[i].status < 2) continue;

				tasks.push({
					id: data[i].id,
					time: data[i].time,
					shares: data[i].shares,
					taskName: data[i].taskName,
					taskType: data[i].taskType,
					curriculumId: data[i].curriculumId,
					parentId: data[i].parentId,
					status: data[i].status,
					occupied: data[i].occupied,
					occupiedTime: data[i].occupiedTime,
					reDoIt: data[i].reDoIt,
					reDoItNum: data[i].reDoItNum,
					access: data[i].access,
				})
			}

			return tasks;
		}
	})

	static getDoneTasks = (t: queryBuilderType) => t.field({
		type: [doneTaskRef],
		args: {
			jwtToken: t.arg.string({ required: true }),
		},
                resolve: async (_parent, args, ctx) => {
                        const { id } = await checkAuth(args.jwtToken, ctx.env)

			const result: DoneTask[] = [];

			const database = new D1QB(ctx.env.TASK_DB)
			const res = await database.fetchAll({
				tableName: 'userTask',
				where: { conditions: 'userId = ?1', params: [id] },
				join: { type: 'INNER', table: 'curriculum', on: 'userTask.curriculumId = curriculum.id' },
			}).execute()

			if (res.results == null || res.results.length == 0) return result;

			res.results.forEach(el => {
				result.push({
					id: el.id as number,
					curriculumId: el.curriculumId as number,
					taskId: el.taskId as number,
					time: el.time as number,
					shares: el.shares as number,
					userTaskName: el.userTaskName as string,
					doItNum: el.doItNum as number,
					status: el.status as number,
					level: el.level as string,
					curriculum: el.name as string,
					userShare: el.userShare as number
				})
			})

			return result;
		}
	})

	static doTask = (t: mutateBuilderType) => t.field({
		type: ['String'],
		args: {
			taskId: t.arg.int({ required: true }),
			curriculumId: t.arg.int({ required: true }),
			jwtToken: t.arg.string({ required: true }),
		},
                resolve: async (_parent, args, ctx) => {
                        const { id, isAdmin } = await checkAuth(args.jwtToken, ctx.env)

			const durableId = ctx.env.TASK_LAB.idFromName(args.curriculumId.toString())
			console.log('durableId ', durableId);

			const durableTask = ctx.env.TASK_LAB.get(durableId)
			const rawData = await durableTask.doTask(args.taskId, id)
			const data = JSON.parse(rawData)

			if (data.result == -1) throw new GraphQLError(AppError.TASK_UNAVAILABLE)
			if (data.result == -2) throw new GraphQLError(AppError.DO_YOUR_TASK)

			if (data.result == 1) {
				const database = new D1QB(ctx.env.TASK_DB)
				await database.insert({
					tableName: 'userTask',
					data: {
						taskId: args.taskId,
						time: Date.now(),
						doItNum: data.reDoItNum,
						status: 0,
						userId: id,
						curriculumId: args.curriculumId,
						userShare: data.shares,
					},
				}).execute()

				if (!isAdmin) {
					const database = new D1QB(ctx.env.USER_DB)
					let res = await database.fetchOne({ tableName: 'user', where: { conditions: 'id = ?1', params: [id] } }).execute()

					var userTrustPoint = res.results!.trustPoint as number
					if (res.results!.trustPoint == 0) throw new GraphQLError(AppError.ZERO_TRUST);

					userTrustPoint -= 2;
					if (userTrustPoint < 0) userTrustPoint = 0;

					await database.update({ tableName: 'user', data: { trustPoint: userTrustPoint }, where: { conditions: 'id = ?1', params: [id] } }).execute()
				}
			}

			const result: string[] = []

			if (data.reDoItNum >= 0) {
				for (let i = 0; i <= data.reDoItNum; i++) {
					var d = await ctx.env.DATA.get(`${args.curriculumId}-${args.taskId}-${i}`)					
					if (d != null) result.push(d)
				}
			}

			return result;
		}
	})

	static submitTask = (t: mutateBuilderType) => t.field({
		type: 'Boolean',
		args: {
			taskId: t.arg.int({ required: true }),
			curriculumId: t.arg.int({ required: true }),
			jwtToken: t.arg.string({ required: true }),
			data: t.arg.string({ required: true }),
		},
                resolve: async (_parent, args, ctx) => {
                        const { id } = await checkAuth(args.jwtToken, ctx.env)

			const database = new D1QB(ctx.env.TASK_DB)
			const res = await database.fetchOne({
				tableName: 'task',
				join: {
					type: 'INNER',
					table: 'curriculum',
					on: `curriculum.id = task.curriculumId AND curriculum.id = ?1 AND curriculum.openToWork = 1 AND curriculum.completedPercent != 100`
				},
				where: { conditions: 'task.id = ?2 AND task.occupied = ?3 AND task.status < 3', params: [args.curriculumId, args.taskId, id] },
			}).execute()
			if (res.results == undefined) throw new GraphQLError(AppError.UNKNOW_ERROR) // no task

			// check if it exceed it time
			const occupiedTime = res.results!.occupiedTime as number
			const reversedTime = (res.results!.shares as number) * 3 * 60 * 1000
			if (Date.now() - occupiedTime > reversedTime) throw new GraphQLError(AppError.TASK_TIME_EXCEEDED)

			let reDoItNum = res.results.reDoItNum as number;

			// first submit task
			if (res.results.status == 0) {
				await database.update({
					tableName: 'task',
					data: { status: 1, occupied: 0, occupiedTime: null },
					where: { conditions: 'id = ?1', params: [args.taskId] },
				}).execute()

				await database.insert({
					tableName: 'userTask',
					data: {
						taskId: args.taskId,
						time: Date.now(),
						doItNum: reDoItNum,
						status: 0,
						userId: id,
						curriculumId: args.curriculumId,
						userShare: res.results.shares,
					},
				}).execute()

				// first number for any currucilum id of any meterial in any level
				// secound number for the specific task
				// third number to check if the task to verify or new one
				const key = `${args.curriculumId}-${args.taskId}-${reDoItNum}`
				await ctx.env.DATA.put(key, args.data);
			}

			// check task
			else if (res.results.status == 1) {
				const reDoIt = res.results.reDoIt as number;
				reDoItNum++
				if (reDoItNum == reDoIt) {
					await database.update({
						tableName: 'task',
						data: { status: 2, occupied: 0, occupiedTime: null, reDoItNum: reDoItNum },
						where: { conditions: 'id = ?1', params: [args.taskId] },
					}).execute()
				} else {
					await database.update({
						tableName: 'task',
						data: { occupied: 0, occupiedTime: null, reDoItNum: reDoItNum },
						where: { conditions: 'id = ?1', params: [args.taskId] },
					}).execute()
				}

				await database.insert({
					tableName: 'userTask',
					data: {
						taskId: args.taskId,
						time: Date.now(),
						doItNum: reDoItNum,
						status: 0,
						userId: id,
						curriculumId: args.curriculumId,
						userShare: res.results.shares as number / 5,
					},
				}).execute()

				// first number for any currucilum id of any meterial in any level
				// secound number for the specific task
				// third number to check if the task to verify or new one
				const key = `${args.curriculumId}-${args.taskId}-${reDoItNum}`
				await ctx.env.DATA.put(key, args.data);
			}

			// admin verify task, status = 2
			else {
				await database.update({
					tableName: 'task',
					data: { status: 3, occupied: 0, occupiedTime: null },
					where: { conditions: 'id = ?1', params: [args.taskId] },
				}).execute()

				if (res.results.taskType == 0) {
					const tree = JSON.parse(args.data)
					const key = `${args.curriculumId}-index`
					await ctx.env.DATA.put(key, JSON.stringify(tree.map));
				}
			}

			return true;
		}
	})
}
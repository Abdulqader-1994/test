import { DurableObject } from "cloudflare:workers";
import { D1QB } from "workers-qb";
import { BackeEndEnv } from "../graphql/builder";

export class TaskLab extends DurableObject {
	constructor(private state: DurableObjectState, env: BackeEndEnv) {
		super(state, env);

		this.state.storage.put('lastCheck', Date.now());
	}

	async resetTasks() {
		// check if the function has been run for less than one hour
		const now = Date.now();
		const lastCheck: number = await this.state.storage.get("lastCheck") as number;
		const oneHour = 3600000
		if (now - lastCheck < oneHour) return;

		await this.state.storage.put("lastCheck", now);

		// reset the task
		const database = new D1QB((this.env as BackeEndEnv).TASK_DB)
		await database.update({
			tableName: 'task',
			data: { occupied: 0, occupiedTime: null },
			where: { conditions: `occupied > 0 AND (${now} - occupiedTime) > (3 * shares * 60000)` },
			returning: 'id',
		}).execute()
	}

	async doTask(taskId: number, userId: number): Promise<string> {
		const res = await this.state.blockConcurrencyWhile(async () => {
			const db = new D1QB((this.env as BackeEndEnv).TASK_DB)

			let res = await db.fetchOne({ tableName: 'task', where: { conditions: 'id = ?1', params: [taskId] } }).execute()
			if (res.results != undefined) {
				if (res.results.occupied == userId) return JSON.stringify({ result: 0, reDoItNum: res.results!.reDoItNum }) // if user reEnter same task
				if (res.results.occupied as number > 0 && res.results.occupied != userId) return JSON.stringify({ result: -1 }) // TASK_UNAVAILABLE
			}

			// if user already has one task => then reject doing another task
			res = await db.fetchOne({ tableName: 'task', where: { conditions: 'id != ?1 AND occupied = ?2', params: [taskId, userId] } }).execute()
			if (res.results) return JSON.stringify({ result: -2 }) // DO_YOUR_TASK

			const data = await db.update({
				tableName: 'task',
				data: { occupied: userId, occupiedTime: Date.now() },
				where: { conditions: 'id = ?1', params: [taskId] },
				returning: '*',
			}).execute()

			return JSON.stringify({
				result: 1,
				shares: data.results![0].shares,
				taskName: data.results![0].taskName,
				reDoItNum: data.results![0].reDoItNum,
			})
		})

		return res;
	}

	async deleteAll() {
		await this.state.storage.deleteAll();
	}
}

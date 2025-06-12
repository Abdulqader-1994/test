import SchemaBuilder from '@pothos/core';
import { TradeShare } from '../durable/trade';
import { TaskLab } from '../durable/task';

export interface BackeEndEnv {
	USER_DB: D1Database;
	TASK_DB: D1Database;
	STATISTICS_DB: D1Database;
	TRANSECTION_DB: D1Database;
	PROFIT_DB: D1Database;
	SNAPSHOT_DB: D1Database;
	DATA: KVNamespace;
	TRADE_SHARE: DurableObjectNamespace<TradeShare>;
	TASK_LAB: DurableObjectNamespace<TaskLab>;
}

export interface AppContext { env: BackeEndEnv }

export const builder = new SchemaBuilder<{ Context: AppContext }>({});

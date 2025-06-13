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
        MAILTRAP_TOKEN: string;
        GOOGLE_CLIENT_ID_DESKTOP: string;
        GOOGLE_CLIENT_SECRET_DESKTOP: string;
        GOOGLE_CLIENT_ID_WEB: string;
        GOOGLE_CLIENT_SECRET_WEB: string;
        JWT_SECRET: string;
}

export interface AppContext { env: BackeEndEnv }

export const builder = new SchemaBuilder<{ Context: AppContext }>({});

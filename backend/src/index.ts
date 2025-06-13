import { createYoga } from 'graphql-yoga';
import { checkAuth } from './utils/check_auth';
import { BackeEndEnv, builder } from './graphql/builder';
export { TradeShare } from './durable/trade';
export { TaskLab } from './durable/task';
import './graphql/query';
import './graphql/mutate';

export default {
	async fetch(request: Request, env: BackeEndEnv, ctx: ExecutionContext): Promise<Response> {
		const url = new URL(request.url);

		if (url.pathname.startsWith('/trade')) {
			const url = new URL(request.url);
			const token = url.searchParams.get("token");

                        if (token) await checkAuth(token, env, 'websocket');
			else return new Response('Unauthorized', { status: 401 })

			const upgradeHeader = request.headers.get('Upgrade');
			if (!upgradeHeader || upgradeHeader.toLowerCase() !== 'websocket') {
				return new Response('Expected Upgrade to WebSocket', { status: 426 });
			}

			const durableId = env.TRADE_SHARE.idFromName('trade');
			const tradeShare = env.TRADE_SHARE.get(durableId);
			return tradeShare.fetch(request);
		}

		const schema = builder.toSchema();
		const yoga = createYoga({ schema, graphqlEndpoint: '/api', context: async () => ({ env }) });

		return yoga.fetch(request, env, ctx);
	},
}

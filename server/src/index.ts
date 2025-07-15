import { BackeEndEnv, builder } from "./graphql/builder";
import { createYoga } from "graphql-yoga";
import './graphql/query';
import './graphql/mutate';

export default {
	async fetch(request: Request, env: BackeEndEnv, ctx: ExecutionContext): Promise<Response> {
		const schema = builder.toSchema();
		const yoga = createYoga({ schema, graphqlEndpoint: '/api', context: async () => ({ env }) });

		return yoga.fetch(request, env, ctx);
	},
}

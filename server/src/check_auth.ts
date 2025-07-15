import jwt from '@tsndr/cloudflare-worker-jwt';
import { GraphQLError } from 'graphql';
import { BackeEndEnv } from './graphql/builder';

export async function checkAuth(jwtToken: string, env: BackeEndEnv): Promise<any> {
	try {
		const decoded = await jwt.verify(jwtToken, env.JWT_SECRET) as any;
		if (!decoded || !decoded.payload) throw new GraphQLError('404');
		return decoded.payload;
	} catch (error: any) {
		throw new GraphQLError('404');
	}
}

import jwt from '@tsndr/cloudflare-worker-jwt';
import { GraphQLError } from 'graphql';
import AppError from './error';
import { BackeEndEnv } from '../graphql/builder';

export async function checkAuth(jwtToken: string, env: BackeEndEnv, requestType: string = 'graphql'): Promise<any> {
        try {
                const decoded = await jwt.verify(jwtToken, env.JWT_SECRET) as any;

		if (!decoded || !decoded.payload) {
			if (requestType === 'graphql') throw new GraphQLError(AppError.UN_AUTHED.toString());
			if (requestType === 'websocket') return new Response('Unauthorized', { status: 401 })
			return false;
		}

		return decoded.payload;
	} catch (error: any) {
		if (requestType === 'graphql') throw new GraphQLError(AppError.UN_AUTHED.toString());
		return false;
	}
}

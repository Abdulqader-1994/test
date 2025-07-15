import { GraphQLError } from "graphql";
import { Account, accountRef, queryBuilderType } from "../graphql/builder";
import { D1QB } from "workers-qb";
import jwt from "@tsndr/cloudflare-worker-jwt";

export default class User {
	static socialLogin = (t: queryBuilderType) => t.field({
		type: accountRef,
		args: {
			code: t.arg.string({ required: true }),
		},
		resolve: async (_parent, args, ctx) => {
			let client_id = ctx.env.GOOGLE_CLIENT_ID;
			let client_secret = ctx.env.GOOGLE_CLIENT_SECRET;

			const params = new URLSearchParams();
			params.append('code', args.code);
			params.append('client_id', client_id);
			params.append('client_secret', client_secret);
			params.append('redirect_uri', 'http://localhost:5173/chat');
			params.append('grant_type', 'authorization_code');

			const url = await fetch('https://oauth2.googleapis.com/token', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/x-www-form-urlencoded',
				},
				body: params.toString(),
			});

			const access: any = await url.json();
			const token = access.access_token;

			let data = await fetch("https://www.googleapis.com/oauth2/v2/userinfo", { headers: { authorization: `Bearer ${token}` } });

			let userInfo: any = await data.json();

			if (!userInfo.id) throw new GraphQLError('error');

			const database = new D1QB(ctx.env.USERS_DB);
			let res = await database.fetchOne({ tableName: "user", where: { conditions: "email = ?1", params: [userInfo.email] } }).execute();

			let user: Account;

			// user exist => sign in
			if (res.results) {
				user = {
					id: res.results.id as number,
					balance: res.results.balance as string,
					email: res.results.email as string,
					name: res.results.name as string | null,
					image: res.results.image as string | null,
					jwtToken: null,
				};
			}

			// user not exist => sign up
			else {
				res = await database
					.insert({
						tableName: "user",
						data: {
							email: userInfo.email,
							name: userInfo.name,
							image: userInfo.picture,
							balance: '150.00',
						},
						returning: "id",
					})
					.execute();

				if (res.results == null) throw new GraphQLError('error');

				user = {
					id: res.results!.id as number,
					balance: '150.00',
					email: userInfo.email,
					name: userInfo.name,
					image: userInfo.picture,
					jwtToken: null,
				}
			}

			user.jwtToken = await jwt.sign({ id: user.id }, ctx.env.JWT_SECRET);
			return user;
		},
	});
}

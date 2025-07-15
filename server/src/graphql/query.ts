import User from "../lib/user"
import { builder } from "./builder"

builder.queryType({
	fields: (t) => ({
		socialLogin: User.socialLogin(t),
	})
})

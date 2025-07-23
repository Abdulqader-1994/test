import { builder } from "./builder"
import User from "../lib"

builder.queryType({
	fields: (t) => ({
		socialLogin: User.socialLogin(t),
		initChat: User.initChat(t)
	})
})

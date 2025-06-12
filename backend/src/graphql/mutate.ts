import { builder } from "./builder";
import User from "../libs/user";
import Admin from "../libs/admin";
import Auth from "../libs/auth";
import Work from "../libs/work";

builder.mutationType({
	fields: (t) => ({
		createEmailAccount: Auth.createEmailAccount(t),
		verifyEmail: Auth.verifyEmail(t),
		verifyPasswordCode: Auth.verifyPasswordCode(t),

		updateUserName: User.updateUserName(t),
		updateDistributePercent: User.updateDistributePercent(t),
		convertBuyShareToBalance: User.convertBuyShareToBalance(t),

		doTask: Work.doTask(t),
		submitTask: Work.submitTask(t),

		adminAddCurriculum: Admin.editOrAddCurriculum(t),
		adminCreateTask: Admin.createTask(t),
		adminSubmitShares: Admin.submitShares(t),
	}),
})

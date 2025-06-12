import { builder } from "./builder"
import Work from '../libs/work'
import User from "../libs/user";
import Admin from "../libs/admin";
import Auth from "../libs/auth";
import Shares from "../libs/shares";
import Study from "../libs/study";

builder.queryType({
	fields: (t) => ({
		emailLogin: Auth.emailLogin(t),
		socialLogin: Auth.socialLogin(t),
		sendVerificationEmail: Auth.sendVerificationEmail(t),
		restorePassword: Auth.restorePassword(t),

		adminGetCurriculums: Admin.getCurriculums(t),
		adminGetAllUsers: Admin.getAllUsers(t),
		adminGetAllTasks: Admin.getTasks(t),

		getTransections:  User.getTransections(t),

		getCurriculums: Work.getCurriculums(t),
		getActiveTasks: Work.getActiveTasks(t),
		getDoneTasks: Work.getDoneTasks(t),

		getBalanceData: Shares.getBalanceData(t),
		getbalanceWithHistory: Shares.getbalanceWithHistory(t),
		getShareInfo: Shares.getShareInfo(t),

		getSubscribedMaterials: Study.getSubscribedMaterials(t),
		getMaterials: Study.getMaterials(t),
	})
})
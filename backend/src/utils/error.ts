enum AppError {
	UNKNOW_ERROR = 'UNKNOW_ERROR',
	INVALID_TOKEN = 'INVALID_TOKEN', // google access token
	UN_AUTHED = 'UN_AUTHED', // auth error
	USERNAME_CHARS_MIN = 'USERNAME_CHARS_MIN', // username less than 5 chars
	DATA_EXIST = 'DATA_EXIST', // email or username already exists
	TOO_MANY_EMAIL = 'TOO_MANY_EMAIL', // email already exist
	CODE_INVALID = 'CODE_INVALID', // the code sent is wrong or excede it it the email time
	WRONG_DATA = 'WRONG_DATA', // user credential is wrong
	UNVERIFIED_EMAIL = 'UNVERIFIED_EMAIL', // user hasn't verified email
	TASK_UNAVAILABLE = 'TASK_UNAVAILABLE', // task already occupied or not exist
	TASK_TIME_EXCEEDED = 'TASK_TIME_EXCEEDED', // task reversed time already done
	DO_YOUR_TASK = 'DO_YOUR_TASK', // user has to submit thier task first before doing the next task
	ZERO_TRUST = 'ZERO_TRUST', // user has zero point in trustPoint either he isn's qualified or tempreray untill verify his task
}

export default AppError;

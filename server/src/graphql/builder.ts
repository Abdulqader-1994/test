import SchemaBuilder from '@pothos/core';
import { ChatRoom } from '../chat_do';

export interface BackeEndEnv {
	USERS_DB: D1Database;
	JWT_SECRET: string;
	CHAT_ROOM: DurableObjectNamespace<ChatRoom>;
	GOOGLE_CLIENT_ID: string;
	GOOGLE_CLIENT_SECRET: string;
	GEMINI_API_KEY: string;
}

export interface AppContext { env: BackeEndEnv }

export const builder = new SchemaBuilder<{ Context: AppContext }>({});

export type queryBuilderType = PothosSchemaTypes.QueryFieldBuilder<PothosSchemaTypes.ExtendDefaultTypes<{ Context: AppContext }>, {}>;
export type mutateBuilderType = PothosSchemaTypes.MutationFieldBuilder<PothosSchemaTypes.ExtendDefaultTypes<{ Context: AppContext }>, {}>;

export interface Account {
	id: number;
	email: string;
	balance: string;
	name: string | null;
	image: string | null;
	jwtToken: string | null;
}
const AccountRef = () => {
	const AccountRef = builder.objectRef<Account>("Account");
	AccountRef.implement({
		fields: (t) => ({
			id: t.int({ resolve: (Account: Account) => Account.id }),
			email: t.string({ resolve: (Account: Account) => Account.email }),
			balance: t.string({ resolve: (Account: Account) => Account.balance }),
			image: t.string({ resolve: (Account: Account) => Account.image, nullable: true }),
			name: t.string({ resolve: (Account: Account) => Account.name, nullable: true }),
			jwtToken: t.string({ resolve: (Account: Account) => Account.jwtToken, nullable: true }),
		}),
	});

	return AccountRef;
};
export const accountRef = AccountRef()

export interface InitChat {
	url: string;
	massage: string;
	balance: string;
	mark: number;
	fullMark: number;
}
const InitChatRef = () => {
	const InitChatRef = builder.objectRef<InitChat>("InitChat");

	InitChatRef.implement({
		fields: (t) => ({
			url: t.string({ resolve: (InitChat: InitChat) => InitChat.url }),
			massage: t.string({ resolve: (InitChat: InitChat) => InitChat.massage }),
			balance: t.string({ resolve: (InitChat: InitChat) => InitChat.balance }),
			mark: t.int({ resolve: (InitChat: InitChat) => InitChat.mark }),
			fullMark: t.int({ resolve: (InitChat: InitChat) => InitChat.fullMark }),
		}),
	});

	return InitChatRef;
};

export const initChatRef = InitChatRef()

export interface ChatMassage {
	massage: string;
	balance: string;
	mark: number;
	fullMark: number;
}
const ChatMassageRef = () => {
	const ChatMassageRef = builder.objectRef<ChatMassage>("ChatMassage");

	ChatMassageRef.implement({
		fields: (t) => ({
			massage: t.string({ resolve: (ChatMassage: ChatMassage) => ChatMassage.massage }),
			balance: t.string({ resolve: (ChatMassage: ChatMassage) => ChatMassage.balance }),
			mark: t.int({ resolve: (ChatMassage: ChatMassage) => ChatMassage.mark }),
			fullMark: t.int({ resolve: (ChatMassage: ChatMassage) => ChatMassage.fullMark }),
		}),
	});

	return ChatMassageRef;
};
export const chatMassageRef = ChatMassageRef()

import { DurableObject } from "cloudflare:workers";
import { D1QB } from "workers-qb";
import { BackeEndEnv } from "./graphql/builder";
import currency from "currency.js";

export class ChatRoom extends DurableObject {
	constructor(private state: DurableObjectState, env: BackeEndEnv) {
		super(state, env);
	}

	async createChat(material: string, userId: number): Promise<string> {
		/* const database = new D1QB((this.env as BackeEndEnv).USERS_DB);
		let res1 = await database.fetchOne({ tableName: "user", where: { conditions: "id = ?1", params: [userId] } }).execute();
		if (!res1.results) return JSON.stringify({ success: false, msg: AppError.UN_AUTHED.toString() });

		const balance = new currency(res1.results.balance as string)
		if (balance < currency(25)) return JSON.stringify({ success: false, msg: AppError.INSUFFICIENT_BALANCE.toString() }); */

		if (material == 'علم الإحياء') {
			let a = await this.initIhiaaMsg('10');
			return a
		}

		return JSON.stringify({ success: false, msg: "UN_AUTHED" });
	}

	async initIhiaaMsg(balance: string): Promise<string> {
		let msg = `
		أنت أستاذ في علم الإحياء لطلاب البكلوريا العلمي في سوريا
		سأضيف لك فقرة من المادة وعليك أن تستخرج سؤال واحد اختيار من متعدد بشكل احترافي
		`

		const paraDB = new D1QB((this.env as BackeEndEnv).USERS_DB);
		let res1 = await paraDB.fetchOne({ tableName: "parts", orderBy: 'RANDOM()' }).execute();
		if (res1.results == undefined || res1.results.length == 0) {
			return JSON.stringify({ success: false, msg: "UN_AUTHED" });
		}

		msg += `
		هذه الفقرة من قسم: ${res1.results.title}
		`

		const strChat = await this.ctx.storage.get('chat')
		const chat: Chat = strChat ? Chat.fromString(strChat) : new Chat('علم الإحياء');

		let sentMsg = '';
		for (const el of chat.sentPart) {
			if (el.partId != res1.results.id) continue
			sentMsg += `
			${chat.massages[el.msgIndex]}
			`
		}

		if (sentMsg.length > 0) {
			msg += `
			${sentMsg}
			انتبه لقد قمت مسبقاً بإدراج هذه الأسئلة
			والآن عليك أن تضيف سؤال آخر للاختيار من متعدد أو قم بتغيير شكل سؤال بإجابات أخرى
			`
		} else {
			msg += `
			الفقرة هي: ${res1.results.part}
			`
		}

		const geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent";
		const apiKey = (this.env as BackeEndEnv).GEMINI_API_KEY;

		const requestBody = {
			contents: [
				{
					parts: [
						{
							"text": msg
						}
					]
				}
			]
		};

		const geminiResponse = await fetch(geminiUrl, {
			method: 'POST',
			headers: { 'Content-Type': 'application/json', 'X-goog-api-key': apiKey },
			body: JSON.stringify(requestBody),
		});

		if (!geminiResponse.ok) return JSON.stringify({ success: false, msg: "GEMINI_ERROR" });

		const responseData: any = await geminiResponse.json();

		const generatedText = responseData.candidates?.[0]?.content?.parts?.[0]?.text;
		if (!generatedText) return JSON.stringify({ success: false, msg: "GEMINI_ERROR" });

		return JSON.stringify({ success: true, msg: generatedText, mark: 0, fullMark: 0, balance: balance });
	}
}

class Chat {
	massages: ChatMassage[] = []
	mark: number = 0;
	fullMark: number = 0;
	sentPart: SentPart[] = []
	material: string;

	constructor(material: string) {
		this.material = material;
	}

	toJsonString() {
		return JSON.stringify({
			mark: this.mark,
			fullMark: this.fullMark,
			sentPart: this.sentPart.map(s => s.toJSON()),
			massages: this.massages.map(m => m.toJSON()),
			material: this.material,
		});
	}

	static fromString(stringChat: any): Chat {
		const json = JSON.parse(stringChat);
		const chat = new Chat(json.material);
		chat.mark = json.mark;
		chat.fullMark = json.fullMark;
		chat.sentPart = (json.sentPart || []).map((m: any) => SentPart.fromJSON(m));;
		chat.massages = (json.massages || []).map((m: any) => ChatMassage.fromJSON(m));
		return chat;
	}
}

type Role = 'ai' | 'user';

class ChatMassage {
	role: Role;
	massage: string;

	constructor(role: Role, msg: string) {
		this.role = role;
		this.massage = msg
	}

	toJSON() {
		return {
			role: this.role,
			massage: this.massage,
		};
	}

	static fromJSON(o: any): ChatMassage {
		return new ChatMassage(o.role, o.massage);
	}
}

class SentPart {
	partId: number;
	msgIndex: number;

	constructor(partId: number, msgIndex: number) {
		this.partId = partId;
		this.msgIndex = msgIndex;
	}

	toJSON() {
		return {
			partId: this.partId,
			msgIndex: this.msgIndex,
		};
	}

	static fromJSON(o: any): SentPart {
		return new SentPart(o.partId, o.msgIndex);
	}
}

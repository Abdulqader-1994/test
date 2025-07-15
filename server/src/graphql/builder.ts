import SchemaBuilder from '@pothos/core';

export interface BackeEndEnv {
	USERS_DB: D1Database;
	JWT_SECRET: string;
	GOOGLE_CLIENT_ID: string;
	GOOGLE_CLIENT_SECRET: string;
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
			image: t.string({ resolve: (Account: Account) => Account.image, nullable: true}),
			name: t.string({ resolve: (Account: Account) => Account.name, nullable: true}),
      jwtToken: t.string({ resolve: (Account: Account) => Account.jwtToken, nullable: true}),
    }),
  });

  return AccountRef;
};

export const accountRef = AccountRef()

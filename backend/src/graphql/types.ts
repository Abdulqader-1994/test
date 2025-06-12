import { AppContext } from "./builder";

export type queryBuilderType = PothosSchemaTypes.QueryFieldBuilder<PothosSchemaTypes.ExtendDefaultTypes<{ Context: AppContext }>, {}>;
export type mutateBuilderType = PothosSchemaTypes.MutationFieldBuilder<PothosSchemaTypes.ExtendDefaultTypes<{ Context: AppContext }>, {}>;

export interface EmailSignUp {
  email: string;
  userName: string;
  password: string;
}

export interface Account {
  id: number;
  userName: string | null;
  password: string | null;
  verified: number;
  lastEmailTime: number | null;
  sentCode: number | null;
  loginType: number;
  loginInfo: string | null;
  country: number;
  time: number;
  balance: string;
  shares: number;
  balanceToBuyShare: string;
  trustPoint: number;
  distributePercent: number;
  isAdmin: number;
  adminPrivileges: number;
  jwtToken: string | null;
}

export interface AdminAccount {
  id: number;
  userName: string | null;
  loginType: number;
  loginInfo: string;
  country: number;
  time: number;
  balance: string;
  shares: number;
  trustPoint: number;
  balanceToBuyShare: string;
  distributePercent: number;
  isAdmin: number;
  adminPrivileges: number;
}

export interface Transection {
  id: number | null;
  userId: number;
  time: number;
  amount: string;
  currencyInfo: string;
  provider: string;
  type: number; // 0 for withdraww, 1 for add
}

export interface Curriculum {
  id: number;
  name: string;
  countryId: number;
  levelType: number;
  level: string;
  semester: number;
  completedPercent: number;
  openToWork: number;
}

export interface ActiveTask {
  id: number;
  time: number;
  shares: number;
  taskType: number,
  taskName: string;
  curriculumId: number;
  parentId: number;
  status: number;
  occupied: number;
  occupiedTime: number;
  reDoIt: number;
  reDoItNum: number;
  access: number;
}

export interface DoneTask {
  id: number;
  curriculumId: number;
  taskId: number;
  time: number;
  shares: number;
  userTaskName: string;
  doItNum: number;
  status: number;
  level: string;
  curriculum: string;
  userShare: number;
}

export interface ProfitData {
  id: number;
  createdAt: number;
  amount: string;
  amountInfo: string;
  userShare: number;
}

export interface ShareData {
  id: number;
  createdAt: number;
  taskId: number;
  amount: number;
  source: number;
}

export interface Statistic {
  createdAt: number;
  price: number;
}

export interface BalanceData {
  balance: string;
  shares: number;
  totalShares: number;
  statistics: Statistic[];
  distruibutedProfit: ProfitData[];
  sharesData: ShareData[];
}

export interface HistoryOrder {
  id: number;
  createdAt: number;
  amount: number;
  price: number;
  orderType: number;
  orderStatus: number;
  executed: number;
}

export interface BalanceWithHistory {
  balance: string;
  shares: number;
  history: HistoryOrder[];
}

export interface ShareInfo {
  time: number;
  shares: number;
  userTaskName: string;
  level: string;
  curriculum: string;
}

export interface Subscribed {
  id: number;
  createdAt: number;
  name: string;
  countryId: number;
  levelType: number;
  level: string;
  semester: number;
  finished: string;
  purchased: number;
}
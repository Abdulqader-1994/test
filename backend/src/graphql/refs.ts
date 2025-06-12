import { builder } from "./builder";
import { ActiveTask, Curriculum, DoneTask, Transection, Account, AdminAccount, BalanceData, ProfitData, ShareData, Statistic, HistoryOrder, BalanceWithHistory, ShareInfo, Subscribed } from "./types";

const AccountRef = () => {
  const AccountRef = builder.objectRef<Account>("Account");

  AccountRef.implement({
    fields: (t) => ({
      id: t.int({ resolve: (Account: Account) => Account.id }),
      userName: t.string({ resolve: (Account: Account) => Account.userName, nullable: true }),
      loginType: t.int({ resolve: (Account: Account) => Account.loginType }),
      loginInfo: t.string({ resolve: (Account: Account) => Account.loginInfo, nullable: true }),
      country: t.int({ resolve: (Account: Account) => Account.country }),
      time: t.float({ resolve: (Account: Account) => Account.time }),
      balance: t.string({ resolve: (Account: Account) => Account.balance }),
      shares: t.int({ resolve: (Account: Account) => Account.shares }),
      trustPoint: t.int({ resolve: (Account: Account) => Account.trustPoint }),
      balanceToBuyShare: t.string({ resolve: (Account: Account) => Account.balanceToBuyShare }),
      distributePercent: t.float({ resolve: (Account: Account) => Account.distributePercent }),
      jwtToken: t.string({ resolve: (Account: Account) => Account.jwtToken, nullable: true }),
    }),
  });

  return AccountRef;
};

const AdminAccountRef = () => {
  const AdminAccountRef = builder.objectRef<AdminAccount>("AdminAccount");

  AdminAccountRef.implement({
    fields: (t) => ({
      id: t.int({ resolve: (AdminAccount: AdminAccount) => AdminAccount.id }),
      userName: t.string({ resolve: (AdminAccount: AdminAccount) => AdminAccount.userName, nullable: true }),
      loginType: t.int({ resolve: (AdminAccount: AdminAccount) => AdminAccount.loginType, }),
      loginInfo: t.string({ resolve: (AdminAccount: AdminAccount) => AdminAccount.loginInfo, }),
      country: t.int({ resolve: (AdminAccount: AdminAccount) => AdminAccount.country, }),
      time: t.float({ resolve: (AdminAccount: AdminAccount) => AdminAccount.time, }),
      balance: t.string({ resolve: (AdminAccount: AdminAccount) => AdminAccount.balance, }),
      shares: t.int({ resolve: (AdminAccount: AdminAccount) => AdminAccount.shares }),
      trustPoint: t.int({ resolve: (AdminAccount: AdminAccount) => AdminAccount.trustPoint, }),
      balanceToBuyShare: t.string({ resolve: (AdminAccount: AdminAccount) => AdminAccount.balanceToBuyShare, }),
      distributePercent: t.float({ resolve: (AdminAccount: AdminAccount) => AdminAccount.distributePercent, }),
      isAdmin: t.int({ resolve: (AdminAccount: AdminAccount) => AdminAccount.isAdmin, }),
      adminPrivileges: t.int({ resolve: (AdminAccount: AdminAccount) => AdminAccount.adminPrivileges, }),
    }),
  });

  return AdminAccountRef;
};

const TransectionRef = () => {
  const TransectionRef = builder.objectRef<Transection>("Transection");

  TransectionRef.implement({
    fields: (t) => ({
      id: t.int({ resolve: (transection: Transection) => transection.id, nullable: true, }),
      amount: t.string({ resolve: (transection: Transection) => transection.amount, }),
      currencyInfo: t.string({ resolve: (transection: Transection) => transection.currencyInfo, }),
      time: t.float({ resolve: (transection: Transection) => transection.time, }),
      provider: t.string({ resolve: (user: Transection) => user.provider }),
      type: t.int({ resolve: (transection: Transection) => transection.type, nullable: true, }),
    }),
  });

  return TransectionRef;
};

const CurriculumRef = () => {
  const CurriculumRef = builder.objectRef<Curriculum>("Curriculum");

  CurriculumRef.implement({
    fields: (t) => ({
      id: t.int({ resolve: (Curriculum: Curriculum) => Curriculum.id }),
      name: t.string({ resolve: (Curriculum: Curriculum) => Curriculum.name }),
      countryId: t.int({ resolve: (Curriculum: Curriculum) => Curriculum.countryId, }),
      completedPercent: t.int({ resolve: (Curriculum: Curriculum) => Curriculum.completedPercent, }),
      semester: t.int({ resolve: (Curriculum: Curriculum) => Curriculum.semester, }),
      levelType: t.int({ resolve: (Curriculum: Curriculum) => Curriculum.levelType, }),
      level: t.string({ resolve: (Curriculum: Curriculum) => Curriculum.level, }),
      openToWork: t.int({ resolve: (Curriculum: Curriculum) => Curriculum.openToWork, }),
    }),
  });

  return CurriculumRef;
};

const ActiveTaskRef = () => {
  const ActiveTaskRef = builder.objectRef<ActiveTask>("ActiveTask");

  ActiveTaskRef.implement({
    fields: (t) => ({
      id: t.int({ resolve: (ActiveTask: ActiveTask) => ActiveTask.id }),
      time: t.float({ resolve: (ActiveTask: ActiveTask) => ActiveTask.time }),
      shares: t.float({ resolve: (ActiveTask: ActiveTask) => ActiveTask.shares, }),
      taskType: t.int({ resolve: (user: ActiveTask) => user.taskType }),
      taskName: t.string({ resolve: (user: ActiveTask) => user.taskName }),
      curriculumId: t.int({ resolve: (ActiveTask: ActiveTask) => ActiveTask.curriculumId, }),
      parentId: t.int({ resolve: (ActiveTask: ActiveTask) => ActiveTask.parentId, }),
      status: t.int({ resolve: (ActiveTask: ActiveTask) => ActiveTask.status, }),
      occupied: t.int({ resolve: (ActiveTask: ActiveTask) => ActiveTask.occupied, }),
      occupiedTime: t.float({ resolve: (ActiveTask: ActiveTask) => ActiveTask.occupiedTime, }),
      reDoIt: t.int({ resolve: (ActiveTask: ActiveTask) => ActiveTask.reDoIt, }),
      reDoItNum: t.int({ resolve: (ActiveTask: ActiveTask) => ActiveTask.reDoItNum, }),
      access: t.int({ resolve: (ActiveTask: ActiveTask) => ActiveTask.access, }),
    }),
  });

  return ActiveTaskRef;
};

const DoneTaskRef = () => {
  const DoneTaskRef = builder.objectRef<DoneTask>("DoneTask");

  DoneTaskRef.implement({
    fields: (t) => ({
      id: t.int({ resolve: (DoneTask: DoneTask) => DoneTask.id }),
      curriculumId: t.int({ resolve: (DoneTask: DoneTask) => DoneTask.curriculumId }),
      taskId: t.int({ resolve: (DoneTask: DoneTask) => DoneTask.taskId }),
      time: t.float({ resolve: (DoneTask: DoneTask) => DoneTask.time }),
      shares: t.float({ resolve: (DoneTask: DoneTask) => DoneTask.shares }),
      userTaskName: t.string({ resolve: (DoneTask: DoneTask) => DoneTask.userTaskName }),
      doItNum: t.int({ resolve: (DoneTask: DoneTask) => DoneTask.doItNum }),
      status: t.int({ resolve: (DoneTask: DoneTask) => DoneTask.status }),
      level: t.string({ resolve: (DoneTask: DoneTask) => DoneTask.level }),
      curriculum: t.string({ resolve: (DoneTask: DoneTask) => DoneTask.curriculum, }),
      userShare: t.int({ resolve: (DoneTask: DoneTask) => DoneTask.userShare }),
    }),
  });

  return DoneTaskRef;
};

const ShareDataRef = () => {
  const ShareDataRef = builder.objectRef<ShareData>("ShareData");

  ShareDataRef.implement({
    fields: (t) => ({
      id: t.int({ resolve: (shareData: ShareData) => shareData.id }),
      createdAt: t.float({ resolve: (shareData: ShareData) => shareData.createdAt }),
      taskId: t.int({ resolve: (shareData: ShareData) => shareData.taskId }),
      amount: t.int({ resolve: (shareData: ShareData) => shareData.amount }),
      source: t.int({ resolve: (shareData: ShareData) => shareData.source }),
    }),
  });

  return ShareDataRef;
}

const ProfitDataRef = () => {
  const ProfitDataRef = builder.objectRef<ProfitData>("ProfitData");

  ProfitDataRef.implement({
    fields: (t) => ({
      id: t.int({ resolve: (ProfitData: ProfitData) => ProfitData.id }),
      createdAt: t.float({ resolve: (ProfitData: ProfitData) => ProfitData.createdAt }),
      amount: t.string({ resolve: (ProfitData: ProfitData) => ProfitData.amount }),
      amountInfo: t.string({ resolve: (ProfitData: ProfitData) => ProfitData.amountInfo }),
      userShare: t.int({ resolve: (ProfitData: ProfitData) => ProfitData.userShare }),
    }),
  });

  return ProfitDataRef;
}

const StatisticsRef = () => {
  const StatisticsRef = builder.objectRef<Statistic>("Statistic");

  StatisticsRef.implement({
    fields: (t) => ({
      createdAt: t.float({ resolve: (Statistic: Statistic) => Statistic.createdAt }),
      price: t.int({ resolve: (Statistic: Statistic) => Statistic.price }),
    }),
  });

  return StatisticsRef;
}

const BalanceDataRef = () => {
  const BalanceDataRef = builder.objectRef<BalanceData>("BalanceData");

  BalanceDataRef.implement({
    fields: (t) => ({
      balance: t.string({ resolve: (BalanceData: BalanceData) => BalanceData.balance }),
      shares: t.int({ resolve: (BalanceData: BalanceData) => BalanceData.shares }),
      totalShares: t.int({ resolve: (BalanceData: BalanceData) => BalanceData.totalShares }),
      statistics: t.field({ type: [statisticsRef], resolve: (balanceData: BalanceData) => balanceData.statistics }),
      distruibutedProfit: t.field({ type: [profitDataRef], resolve: (balanceData: BalanceData) => balanceData.distruibutedProfit }),
      shareData: t.field({ type: [shareDataRef], resolve: (balanceData: BalanceData) => balanceData.sharesData }),
    }),
  });

  return BalanceDataRef;
};

const HistoryOrderRef = () => {
  const HistoryOrderRef = builder.objectRef<HistoryOrder>("HistoryOrder");

  HistoryOrderRef.implement({
    fields: (t) => ({
      id: t.int({ resolve: (HistoryOrder: HistoryOrder) => HistoryOrder.id }),
      createdAt: t.float({ resolve: (HistoryOrder: HistoryOrder) => HistoryOrder.createdAt }),
      amount: t.int({ resolve: (HistoryOrder: HistoryOrder) => HistoryOrder.amount }),
      price: t.int({ resolve: (HistoryOrder: HistoryOrder) => HistoryOrder.price }),
      orderType: t.int({ resolve: (HistoryOrder: HistoryOrder) => HistoryOrder.orderType }),
      orderStatus: t.int({ resolve: (HistoryOrder: HistoryOrder) => HistoryOrder.orderStatus }),
      executed: t.int({ resolve: (HistoryOrder: HistoryOrder) => HistoryOrder.executed }),
    }),
  });

  return HistoryOrderRef;
}

const BalanceWithHistoryRef = () => {
  const BalanceWithHistoryRef = builder.objectRef<BalanceWithHistory>("BalanceWithHistory");

  BalanceWithHistoryRef.implement({
    fields: (t) => ({
      balance: t.string({ resolve: (BalanceWithHistory: BalanceWithHistory) => BalanceWithHistory.balance }),
      shares: t.int({ resolve: (BalanceWithHistory: BalanceWithHistory) => BalanceWithHistory.shares }),
      history: t.field({ type: [hstoryOrderRef], resolve: (BalanceWithHistory: BalanceWithHistory) => BalanceWithHistory.history }),
    })
  })

  return BalanceWithHistoryRef;
}

const ShareInfoRef = () => {
  const ShareInfoRef = builder.objectRef<ShareInfo>("ShareInfo");

  ShareInfoRef.implement({
    fields: (t) => ({
      time: t.float({ resolve: (ShareInfo: ShareInfo) => ShareInfo.time }),
      shares: t.int({ resolve: (ShareInfo: ShareInfo) => ShareInfo.shares }),
      userTaskName: t.string({ resolve: (ShareInfo: ShareInfo) => ShareInfo.userTaskName }),
      level: t.string({ resolve: (ShareInfo: ShareInfo) => ShareInfo.level }),
      curriculum: t.string({ resolve: (ShareInfo: ShareInfo) => ShareInfo.curriculum }),
    }),
  });

  return ShareInfoRef;
}

const SubscribedRef = () => {
  const SubscribedRef = builder.objectRef<Subscribed>("Subscribed");

  SubscribedRef.implement({
    fields: (t) => ({
      id: t.int({ resolve: (Subscribed: Subscribed) => Subscribed.id }),
      createdAt: t.float({ resolve: (Subscribed: Subscribed) => Subscribed.createdAt }),
      name: t.string({ resolve: (Subscribed: Subscribed) => Subscribed.name }),
      countryId: t.int({ resolve: (Subscribed: Subscribed) => Subscribed.countryId }),
      levelType: t.int({ resolve: (Subscribed: Subscribed) => Subscribed.levelType }),
      level: t.string({ resolve: (Subscribed: Subscribed) => Subscribed.level }),
      semester: t.int({ resolve: (Subscribed: Subscribed) => Subscribed.semester }),
      finished: t.string({ resolve: (Subscribed: Subscribed) => Subscribed.finished }),
      purchased: t.int({ resolve: (Subscribed: Subscribed) => Subscribed.purchased })
    }),
  });

  return SubscribedRef;
}

export const accountRef = AccountRef()
export const adminAccountRef = AdminAccountRef()
export const transectionRef = TransectionRef()
export const curriculumRef = CurriculumRef()
export const activeTaskRef = ActiveTaskRef()
export const doneTaskRef = DoneTaskRef()
export const shareDataRef = ShareDataRef()
export const profitDataRef = ProfitDataRef()
export const statisticsRef = StatisticsRef()
export const hstoryOrderRef = HistoryOrderRef()
export const balanceDataRef = BalanceDataRef()
export const balanceWithHistoryRef = BalanceWithHistoryRef()
export const shareInfoRef = ShareInfoRef()
export const subscribedRef =  SubscribedRef()
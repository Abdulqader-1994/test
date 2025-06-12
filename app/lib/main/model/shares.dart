import 'package:ailence/main/main_controller.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'api.dart';

class Shares {
  int totalShares = 0;
  int bestToday = 0;
  int bestMonth = 0;
  int bestYear = 0;
  List<Statistics> statistics = [];
  List<DistruibutedProfit> distruibutedShares = [];
  List<SharesData> sharesData = [];

  getData() async {
    final c = Get.find<MainController>();

    var result = await c.client.query(
      QueryOptions(
        document: gql(r'''query getBalanceData($jwtToken: String!) {
          getBalanceData(jwtToken: $jwtToken) {
            balance
            shares
            totalShares
            statistics {
              createdAt
              price
            }
            distruibutedProfit {
              createdAt
              amount
              userShare
            }
            shareData {
              id
              createdAt
              taskId
              amount
              source
            }
          }
        }'''),
        variables: {"jwtToken": c.user.value.jwtToken},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.exception != null) return ApiResponse.handleError(error: result.exception!);
    if (result.data?['getBalanceData'] == null) return;

    sharesData.clear();
    distruibutedShares.clear();

    var res = result.data?['getBalanceData'];

    if (res['balance'] != null) c.user.value.balance = res['balance'];
    if (res['shares'] != null) c.user.value.shares = res['shares'];
    c.user.value.save();
    c.user.refresh();
    if (res['totalShares'] != null) totalShares = res['totalShares'];
    if (res['statistics'] != null && res['statistics'].length > 0) {
      // sort and correct time format
      statistics = Statistics.setStatistics(res['statistics']);

      // set best today, month, year
      bestToday = statistics.first.price;

      if (statistics.length >= 30) {
        var lastMonth = statistics.sublist(0, 31);
        for (var el in lastMonth) {
          if (bestMonth < el.price) bestMonth = el.price;
        }
      } else {
        bestMonth = bestToday;
      }

      if (statistics.length > 30) {
        for (var el in statistics) {
          if (bestYear < el.price) bestYear = el.price;
        }
      } else {
        bestYear = bestToday;
      }
    }

    if (res['distruibutedProfit'] != null) {
      for (var el in res['distruibutedProfit']) {
        double userAmount = (el['amount'] / totalShares) * el['userShare'];
        distruibutedShares.add(DistruibutedProfit(createdAt: el['createdAt'], amount: el['amount'], userAmount: userAmount));
      }
    }
    distruibutedShares.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (res['shareData'] != null) {
      for (var el in res['shareData']) {
        String source = 'عمل'; // el['source'] == 1
        if (el['source'] == 2) source = 'استثمار';
        sharesData.add(SharesData(id: el['id'], createdAt: el['createdAt'], amount: el['amount'], source: source, taskId: el['taskId']));
      }
    }
    sharesData.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    c.shares.refresh();
  }

  static Future<ShareInfo?> getShareInfo(int shareId) async {
    final c = Get.find<MainController>();

    var result = await c.client.query(
      QueryOptions(
        document: gql(r'''query getShareInfo($jwtToken: String!, $shareId: Int!) {
          getShareInfo(jwtToken: $jwtToken, shareId: $shareId) {
            time
            shares
            userTaskName
            level
            curriculum
          }
        }'''),
        variables: {"jwtToken": c.user.value.jwtToken, "shareId": shareId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.exception != null) ApiResponse.handleError(error: result.exception!);
    if (result.data?['getShareInfo'] == null) return null;

    var res = result.data?['getShareInfo'];

    final createdAt = DateTime.fromMillisecondsSinceEpoch(res['time']);
    var time = '${DateFormat('HH:mm').format(createdAt)}   ${DateFormat('dd/MM/yyyy').format(createdAt)}';

    return ShareInfo(time: time, shares: res['shares'], userTaskName: res['userTaskName'], level: res['level'], curriculum: res['curriculum']);
  }
}

class DistruibutedProfit {
  final int createdAt;
  final int amount;
  final double userAmount;

  DistruibutedProfit({required this.createdAt, required this.amount, required this.userAmount});
}

class SharesData {
  final int id;
  final int createdAt;
  final int amount;
  final String source;
  final int taskId;

  SharesData({required this.id, required this.createdAt, required this.amount, required this.source, required this.taskId});
}

class Statistics {
  final DateTime createdAt;
  final int price;

  Statistics({required this.createdAt, required this.price});

  static setStatistics(List statisticsData) {
    List<Statistics> statistics = [];

    for (var el in statisticsData) {
      final dateMillis = el['createdAt'] ?? 0;
      var s = Statistics(createdAt: DateTime.fromMillisecondsSinceEpoch(dateMillis), price: el['price'] as int);
      statistics.add(s);
    }

    statistics.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return statistics;
  }
}

class ShareInfo {
  final String time;
  final int shares;
  final String userTaskName;
  final String level;
  final String curriculum;

  ShareInfo({required this.time, required this.shares, required this.userTaskName, required this.level, required this.curriculum});
}

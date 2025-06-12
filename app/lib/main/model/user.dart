import 'api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../main_controller.dart';

class User {
  int id;
  String jwtToken;
  String userName;
  int loginType;
  String loginInfo;
  int country;
  int time;
  String balance;
  int shares;
  int trustPoint;
  String balanceToBuyShare;
  int distributePercent;
  List<UserTransection> transection = [];

  User({
    this.id = -1,
    this.jwtToken = '',
    this.userName = '',
    this.loginType = -1,
    this.loginInfo = '',
    this.country = -1,
    this.time = -1,
    this.balance = '',
    this.shares = -1,
    this.trustPoint = -1,
    this.balanceToBuyShare = '',
    this.distributePercent = -1,
  });

  @override
  String toString() {
    return 'User(id: $id, jwtToken: $jwtToken, userName: $userName, loginType: $loginType, loginInfo: $loginInfo, time: $time, balance: $balance, shares: $shares, trustPoint: $trustPoint, balanceToBuyShare: $balanceToBuyShare, distributePercent: $distributePercent)';
  }

  Map toJson() {
    return {
      'id': id,
      'jwtToken': jwtToken,
      'userName': userName,
      'loginType': loginType,
      'loginInfo': loginInfo,
      'country': country,
      'time': time,
      'balance': balance,
      'shares': shares,
      'trustPoint': trustPoint,
      'balanceToBuyShare': balanceToBuyShare,
      'distributePercent': distributePercent,
    };
  }

  void updateData({required Map data}) async {
    if (data['id'] != null) id = data['id'];
    if (data['userName'] != null) userName = data['userName'];
    if (data['loginType'] != null) loginType = data['loginType'];
    if (data['loginInfo'] != null) loginInfo = data['loginInfo'];
    if (data['country'] != null) country = data['country'];
    if (data['time'] != null) time = data['time'];
    if (data['balance'] != null) balance = data['balance'];
    if (data['shares'] != null) shares = data['shares'];
    if (data['trustPoint'] != null) trustPoint = data['trustPoint'];
    if (data['balanceToBuyShare'] != null) balanceToBuyShare = data['balanceToBuyShare'];
    if (data['distributePercent'] != null) distributePercent = data['distributePercent'];
    if (data['jwtToken'] != null) jwtToken = data['jwtToken'];

    save();
  }

  static Future<User> checkData() async {
    var user = User();

    const storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
    var res = await storage.read(key: 'user');

    if (res == null) return user;

    user.updateData(data: jsonDecode(res));
    return user;
  }

  void save() async {
    const storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
    await storage.write(key: 'user', value: jsonEncode(toJson()));
  }

  static Future<ApiResponse> updateUserName({required String newValue}) async {
    final c = Get.find<MainController>();

    final QueryResult result = await c.client.mutate(
      MutationOptions(
        variables: {'jwtToken': c.user.value.jwtToken, 'newUsername': newValue},
        document: gql(r'''
        mutation updateUserName($jwtToken: String!, $newUsername: String!) {
          updateUserName(jwtToken: $jwtToken, newUsername: $newUsername)
        }
      '''),
      ),
    );

    if (result.exception != null) return ApiResponse.handleError(error: result.exception!);

    c.user.value.updateData(data: {'userName': newValue});
    c.user.refresh();
    return ApiResponse(data: null, success: true);
  }

  static Future<ApiResponse> getTransections({required String jwtToken, required int userId, required int offset}) async {
    MainController c = Get.find<MainController>();

    final result = await c.client.query(
      QueryOptions(
        document: gql(r'''query GetTransections($jwtToken: String!, $offset: Int!) {
          getTransections( jwtToken: $jwtToken, offset: $offset) {
            id amount currencyInfo time provider type
          }
        }
      '''),
        variables: {"jwtToken": jwtToken, "offset": offset},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.exception != null) return ApiResponse.handleError(error: result.exception!);

    var dataList = result.data!['getTransections'] as List;
    List<UserTransection> res = dataList.map((el) {
      return UserTransection(
        id: el['id'],
        time: el['time'],
        amount: el['amount'],
        currencyInfo: el['currencyInfo'],
        provider: el['provider'],
        type: el['type'],
      );
    }).toList();

    c.user.value.transection.clear();
    c.user.value.transection.addAll(res);
    c.user.refresh();

    return ApiResponse(data: null, success: true);
  }

  updateDistributePercent(int newVal) async {
    final c = Get.find<MainController>();
    var result = await c.client.mutate(
      MutationOptions(
        variables: {"jwtToken": c.user.value.jwtToken, 'newVal': newVal},
        document: gql(r'''mutation updateDistributePercent($jwtToken: String!, $newVal: Int!) {
          updateDistributePercent(jwtToken: $jwtToken, newVal: $newVal)
        }'''),
      ),
    );

    if (result.exception != null) return ApiResponse.handleError(error: result.exception!);
    if (result.data?['updateDistributePercent'] == null) return;

    distributePercent = newVal;
    save();
    c.user.refresh();
  }

  convertBuyShareToBalance() async {
    final c = Get.find<MainController>();
    var result = await c.client.mutate(
      MutationOptions(
        variables: {"jwtToken": c.user.value.jwtToken},
        document: gql(r'''mutation convertBuyShareToBalance($jwtToken: String!) {
          convertBuyShareToBalance(jwtToken: $jwtToken)
        }'''),
      ),
    );

    if (result.exception != null) return ApiResponse.handleError(error: result.exception!);
    if (result.data?['convertBuyShareToBalance'] == null) return;

    balance = result.data!['convertBuyShareToBalance'];
    balanceToBuyShare = '0';

    save();
    c.user.refresh();
  }
}

class UserTransection {
  int id;
  int time;
  double amount;
  String currencyInfo;
  String provider;
  int type;

  UserTransection({
    required this.id,
    required this.time,
    required this.amount,
    required this.currencyInfo,
    required this.provider,
    required this.type,
  });
}

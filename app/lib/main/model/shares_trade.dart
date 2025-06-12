import 'dart:async';
import 'dart:convert';
import 'package:ailence/main/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import 'api.dart';

class SharesTrade {
  int bestBuyPrice = 0;
  int bestSellPrice = 0;
  int totalBuyAmount = 0;
  int totalSellAmount = 0;
  bool waiting = false;

  List<Order> buyOrders = [];
  List<Order> sellOrders = [];
  List<HistoryOrder> history = [];

  WebSocketChannel? channel;
  StreamSubscription? subscription;
  bool isConnected = false;
  bool isConnecting = false;
  Timer? reconnectTimer;

  Future<void> connect() async {
    if (isConnected || isConnecting) {
      if (isConnected) getMainData();
      return;
    }

    closeConnection();

    isConnecting = true;

    final c = Get.find<MainController>();

    try {
      channel = WebSocketChannel.connect(c.wsUrl);
      await channel?.ready;
      isConnected = true;
    } catch (_) {
      handleDisconnect();
      return;
    } finally {
      isConnecting = false;
    }

    subscription = channel?.stream.listen(
      handleMessage,
      onError: (error) => handleDisconnect(),
      onDone: handleDisconnect,
      cancelOnError: true,
    );

    getMainData();
    getbalanceWithHistory();
  }

  void closeConnection() {
    isConnected = false;
    isConnecting = false;
    subscription?.cancel();
    subscription = null;
    channel?.sink.close();
    channel = null;
    reconnectTimer?.cancel();
    reconnectTimer = null;
  }

  void handleDisconnect([Object? error]) {
    // Clean up everything first …
    isConnected = false;
    isConnecting = false;
    subscription?.cancel();
    subscription = null;
    channel?.sink.close();
    channel = null;

    reconnectTimer?.cancel(); // Already waiting? Don’t stack timers

    // 0.5 s later, try to connect again
    reconnectTimer = Timer(const Duration(milliseconds: 500), () {
      if (!isConnected && !isConnecting) connect(); // Guard: don’t start two parallel connects
    });
  }

  Future<void> handleMessage(dynamic message) async {
    final data = jsonDecode(message as String);
    if (data['result'] == true && data['type'] == 'newOrders') {
      updateOrders(data['data']);
      await getbalanceWithHistory();
      waiting = false;
    }

    if (data['result'] == true && data['type'] == 'mainData') {
      updateOrders(data['data']['orders']);
    }

    final c = Get.find<MainController>();
    c.trade.refresh();
  }

  void updateOrders(List openOrdersData) {
    buyOrders.clear();
    sellOrders.clear();

    for (var el in openOrdersData) {
      if (el['orderType'] == 0) {
        Order? existed = buyOrders.firstWhereOrNull((element) => element.price == el['price']);
        if (existed == null) {
          buyOrders.add(Order(amount: el['amount'], price: el['price'], executed: el['executed']));
        } else {
          existed.amount += el['amount'] as int;
          existed.executed += el['executed'] as int;
        }
      }

      if (el['orderType'] == 1) {
        Order? existed = sellOrders.firstWhereOrNull((element) => element.price == el['price']);
        if (existed == null) {
          sellOrders.add(Order(amount: el['amount'], price: el['price'], executed: el['executed']));
        } else {
          existed.amount += el['amount'] as int;
          existed.executed += el['executed'] as int;
        }
      }
    }

    buyOrders.sort((a, b) => a.price.compareTo(b.price));
    sellOrders.sort((a, b) => a.price.compareTo(b.price));

    totalBuyAmount = buyOrders.fold(0, (sum, order) => sum + (order.amount - order.executed));
    totalSellAmount = sellOrders.fold(0, (sum, order) => sum + (order.amount - order.executed));

    bestBuyPrice = buyOrders.isNotEmpty ? buyOrders.first.price : 0;
    bestSellPrice = sellOrders.isNotEmpty ? sellOrders.first.price : 0;
  }

  void updateHistoryOrder(List historyData) {
    history.clear();

    for (var el in historyData) {
      final createdAt = DateTime.fromMillisecondsSinceEpoch(el['createdAt']);

      history.add(HistoryOrder(
        id: el['id'],
        amount: el['amount'],
        price: el['price'],
        executed: el['executed'],
        hourDate: DateFormat('HH:mm:ss').format(createdAt),
        dayDate: DateFormat('dd/MM/yyyy').format(createdAt),
        orderType: el['orderType'],
        orderStatus: el['orderStatus'],
      ));

      history.sort((a, b) {
        final dateA = DateTime.tryParse("${a.dayDate.split('/').reversed.join('-')} ${a.hourDate}");
        final dateB = DateTime.tryParse("${b.dayDate.split('/').reversed.join('-')} ${b.hourDate}");
        if (dateA != null && dateB != null) return dateB.compareTo(dateA);
        return 0;
      });
    }
  }

  Future<void> getMainData() async {
    if (channel == null || !isConnected) return;

    try {
      final jsonMessage = jsonEncode({'reqType': 'getMainData'});
      channel!.sink.add(jsonMessage);
    } catch (e) {
      e;
    }
  }

  void placeOrder({required int amount, required int price, required int orderType}) {
    if (channel == null || !isConnected) return;

    waiting = true;

    try {
      final jsonMessage = jsonEncode({'reqType': 'newOrder', 'amount': amount, 'price': price, 'type': orderType});
      channel!.sink.add(jsonMessage);
    } catch (e) {
      e;
    }

    getMainData();
  }

  void cancelOrder(int orderId) {
    if (channel == null || !isConnected) return;

    try {
      final jsonMessage = jsonEncode({'reqType': 'cancelOrder', 'orderId': orderId});
      channel!.sink.add(jsonMessage);
    } catch (e) {
      e;
    }

    getMainData();
  }

  bool validateOrder({required int? amount, required int total, required int orderType, required int balance, required int shares}) {
    // check null amount
    if (amount == null) {
      if (Get.isSnackbarOpen) return false;
      Get.snackbar(
        'خطأ',
        'يجب إضافة قيم للكمية',
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
        maxWidth: 300,
        colorText: Colors.white,
      );
      return false;
    }

    // insufficnt balance for sell + tax
    if (orderType == 0) {
      if ((total + 1) > balance) {
        if (Get.isSnackbarOpen) return false;
        Get.snackbar(
          'خطأ',
          'لا تملك رصيد كافي',
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.TOP,
          maxWidth: 300,
          colorText: Colors.white,
        );
        return false;
      }
    }

    // insufficient shares for buy
    else {
      if (amount > shares) {
        if (Get.isSnackbarOpen) return false;
        Get.snackbar(
          'خطأ',
          'لا تملك أسهم كافية',
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.TOP,
          maxWidth: 300,
          colorText: Colors.white,
        );
        return false;
      }

      // insufficnt balance for tax
      if (balance < 1) {
        if (Get.isSnackbarOpen) return false;
        Get.snackbar(
          'خطأ',
          'لا تملك رصيد كافي لدفع الضريبة',
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.TOP,
          maxWidth: 300,
          colorText: Colors.white,
        );
        return false;
      }
    }
    return true;
  }

  Future getbalanceWithHistory() async {
    final c = Get.find<MainController>();

    var result = await c.client.query(
      QueryOptions(
        document: gql(r'''query getbalanceWithHistory($jwtToken: String!) {
          getbalanceWithHistory(jwtToken: $jwtToken) {
            balance
            shares
            history {
              id
              createdAt
              amount
              price
              orderType
              orderStatus
              executed
            }
          }
        }'''),
        variables: {"jwtToken": c.user.value.jwtToken},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.exception != null) return ApiResponse.handleError(error: result.exception!);
    if (result.data?['getbalanceWithHistory'] == null) return;

    history.clear();

    c.user.value.balance = result.data?['getbalanceWithHistory']['balance'];
    c.user.value.shares = result.data?['getbalanceWithHistory']['shares'];
    c.user.value.save();
    c.user.refresh();
    c.shares.refresh();

    if (result.data?['getbalanceWithHistory'] != null) {
      Map data = result.data?['getbalanceWithHistory'];
      List his = data['history'].toList();
      for (var el in his) {
        final createdAt = DateTime.fromMillisecondsSinceEpoch(el['createdAt']);

        history.add(HistoryOrder(
          id: el['id'],
          amount: el['amount'],
          price: el['price'],
          executed: el['executed'],
          hourDate: DateFormat('HH:mm:ss').format(createdAt),
          dayDate: DateFormat('dd/MM/yyyy').format(createdAt),
          orderType: el['orderType'],
          orderStatus: el['orderStatus'],
        ));

        history.sort((a, b) {
          final dateA = DateTime.tryParse("${a.dayDate.split('/').reversed.join('-')} ${a.hourDate}");
          final dateB = DateTime.tryParse("${b.dayDate.split('/').reversed.join('-')} ${b.hourDate}");
          if (dateA != null && dateB != null) return dateB.compareTo(dateA);
          return 0;
        });
      }
    }
  }
}

class Order {
  int amount;
  int price;
  int executed;

  Order({required this.amount, required this.price, required this.executed});
}

class HistoryOrder extends Order {
  int id;
  String hourDate;
  String dayDate;
  int orderType;
  int orderStatus;

  HistoryOrder({
    required super.amount,
    required super.price,
    required super.executed,
    required this.id,
    required this.hourDate,
    required this.dayDate,
    required this.orderType,
    required this.orderStatus,
  });
}

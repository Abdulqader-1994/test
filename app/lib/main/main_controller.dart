import 'package:ailence/main/model/workdata.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'model/auth.dart';
import 'model/shares.dart';
import 'model/shares_trade.dart';
import 'model/studydata.dart';
import 'model/user.dart';

class MainController extends GetxController {
  var auth = Auth();
  var user = User().obs;
  var tasks = WorkData().obs;
  var shares = Shares().obs;
  var trade = SharesTrade().obs;
  var studyData = StudyData().obs;

  var profitTab = 1.obs;

  bool drawerExpanded = true;

  /* 
  'server.mar1994-egypt.workers.dev'
  '192.168.1.13:8787'
  */

  String url = '192.168.1.13:8787';
  GraphQLClient get client => GraphQLClient(link: HttpLink('http://$url/api'), cache: GraphQLCache(store: HiveStore()));
  Uri get wsUrl => Uri.parse('ws://$url/trade?userId=${user.value.id}&token=${user.value.jwtToken}');

  @override
  void onInit() {
    checkUserData();
    super.onInit();
  }

  Future<void> checkUserData() async {
    var val = await User.checkData();
    user.value = val;
    user.refresh();
  }
}

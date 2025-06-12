import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../main_controller.dart';
import 'api.dart';

class StudyData {
  List<SubscribedMaterials> subscribed = [];

  getSubscribedMaterials() async {
    final c = Get.find<MainController>();

    var result = await c.client.query(
      QueryOptions(
        document: gql(r'''query getSubscribedMaterials($jwtToken: String!) {
          getSubscribedMaterials(jwtToken: $jwtToken) {
            id
            createdAt
            name
            countryId
            levelType
            level
            semester
            finished
            purchased
          }
        }'''),
        variables: {"jwtToken": c.user.value.jwtToken},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.exception != null) return ApiResponse.handleError(error: result.exception!);
    if (result.data?['getSubscribedMaterials'] == null) return;

    subscribed.clear();
    for (var el in result.data?['getSubscribedMaterials']) {
      subscribed.add(SubscribedMaterials(
        id: el['id'],
        createdAt: el['createdAt'],
        name: el['name'],
        countryId: el['countryId'],
        levelType: el['levelType'],
        level: el['level'],
        semester: el['semester'],
        finished: el['finished'],
        purchased: el['purchased'],
      ));
    }

    c.studyData.refresh();
  }
}

class SubscribedMaterials {
  int id;
  int createdAt;
  String name;
  int countryId;
  int levelType;
  String level;
  int semester;
  String finished;
  bool purchased;

  SubscribedMaterials({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.countryId,
    required this.levelType,
    required this.level,
    required this.semester,
    required this.finished,
    required this.purchased,
  });
}

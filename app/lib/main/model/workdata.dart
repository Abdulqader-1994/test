import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../pages/work/entidio/controller.dart';
import '../pages/work/entidio/model/edit_note.dart';
import '../pages/work/entidio/model/lesson.dart';
import '../main_controller.dart';
import 'api.dart';

class WorkData {
  List<Curriculum> curriculums = [];
  List<DoneTask> doneTasks = [];
  List<ActiveTask> activeTasks = [];

  int cancelledNum = 0;
  int rejectedNum = 0;
  int pendingNum = 0;
  int verfiedNum = 0;

  void setTasksNum() {
    int cancelledMinutes = 0;
    int rejectedMinutes = 0;
    int pendingMinutes = 0;
    int verfiedMinutes = 0;

    for (DoneTask el in doneTasks) {
      if (el.status == 1) pendingMinutes += el.shares;
      if (el.status == -1) rejectedMinutes += el.shares;
      if (el.status == 2) {
        rejectedMinutes += el.shares - el.userShare;
        verfiedMinutes += el.userShare;
      }
    }

    if (cancelledMinutes < 0) cancelledMinutes = 0;
    if (rejectedMinutes < 0) rejectedMinutes = 0;
    if (pendingMinutes < 0) pendingMinutes = 0;
    if (verfiedMinutes < 0) verfiedMinutes = 0;

    cancelledNum = cancelledMinutes;
    rejectedNum = rejectedMinutes;
    pendingNum = pendingMinutes;
    verfiedNum = verfiedMinutes;
  }

  getDoneTask() async {
    var c = Get.find<MainController>();
    var result = await c.client.query(
      QueryOptions(
        document: gql(r'''query getDoneTasks($jwtToken: String!) {
          getDoneTasks(jwtToken: $jwtToken) {
            id
            time
            shares
            userTaskName
            status
            level
            curriculum
            doItNum
            userShare
          }
        }'''),
        variables: {"jwtToken": c.user.value.jwtToken},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.exception != null) return ApiResponse.handleError(error: result.exception!);
    if (result.data?['getDoneTasks'] == null) return;

    List<DoneTask> res = [];

    for (var el in result.data?['getDoneTasks']) {
      if (el['status'] == 0) continue;

      res.add(DoneTask(
        id: el['id'],
        time: el['time'],
        shares: el['shares'],
        doItNum: el['doItNum'],
        userTaskName: el['userTaskName'],
        status: el['status'],
        level: el['level'],
        curriculum: el['curriculum'],
        userShare: el['userShare'],
      ));
    }

    doneTasks = res;
    setTasksNum();
    c.tasks.refresh();
  }

  static getCurriculums({required String jwtToken}) async {
    MainController c = Get.find<MainController>();

    var result = await c.client.query(
      QueryOptions(
        document: gql(r'''query getCurriculums($jwtToken: String!) {
          getCurriculums(jwtToken: $jwtToken) {
            id
            name
            countryId
            levelType
            completedPercent
            level
            semester
          }
        }'''),
        variables: {"jwtToken": jwtToken},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.exception != null) {
      var res = ApiResponse.handleError(error: result.exception!);
      if (result.exception!.graphqlErrors[0].message == 'ZERO_TRUST') {
        if (Get.isSnackbarOpen) return;

        Get.snackbar(
          'خطأ',
          res.data,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.TOP,
          maxWidth: 300,
          colorText: Colors.white,
        );

        await Get.toNamed('/work');
        return;
      }
      return;
    }
    if (result.data?['getCurriculums'] == null) return;

    List<Curriculum> res = [];

    for (var el in result.data?['getCurriculums']) {
      String levelType = 'مدرسي'; // levelType = 0
      res.add(Curriculum(
        id: el['id'],
        name: el['name'],
        countryId: el['countryId'],
        levelType: levelType,
        completedPercent: el['completedPercent'],
        level: el['level'],
        semester: el['semester'],
      ));
    }

    c.tasks.value.curriculums = res;
    c.tasks.refresh();
  }

  static getActiveTasks({required String jwtToken, required int curriculumId}) async {
    MainController c = Get.find<MainController>();

    var result = await c.client.query(
      QueryOptions(
        document: gql(r'''query getActiveTasks($jwtToken: String!, $curriculumId: Int!) {
          getActiveTasks(jwtToken: $jwtToken, curriculumId: $curriculumId) {
            id
            shares
            taskName
            taskType
            status
            curriculumId
            occupied
            occupiedTime
          }
        }'''),
        variables: {"jwtToken": jwtToken, 'curriculumId': curriculumId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.exception != null) return ApiResponse.handleError(error: result.exception!);
    if (result.data?['getActiveTasks'] == null) return;

    List<ActiveTask> res = [];

    for (var el in result.data?['getActiveTasks']) {
      res.add(ActiveTask(
        id: el['id'],
        shares: el['status'] == 0 ? el['shares'] : el['shares'] ~/ 5,
        taskName: el['status'] == 0
            ? el['taskName']
            : el['status'] == 1
                ? 'تحقق من ${el['taskName']}'
                : 'مراجعة مهمة التخقق من ${el['taskName']}',
        taskType: el['taskType'],
        status: el['status'],
        curriculumId: el['curriculumId'],
        occupied: el['occupied'],
        occupiedTime: el['occupiedTime'],
      ));
    }

    c.tasks.value.activeTasks = res;
    c.tasks.refresh();
  }

  static doTask({required ActiveTask task, required Curriculum curriculum}) async {
    final c = Get.find<MainController>();
    final QueryResult result = await c.client.mutate(
      MutationOptions(
        variables: {'jwtToken': c.user.value.jwtToken, 'curriculumId': curriculum.id, 'taskId': task.id},
        document: gql(r'''
          mutation doTask($jwtToken: String!, $curriculumId: Int!, $taskId: Int!) {
            doTask(jwtToken: $jwtToken, curriculumId: $curriculumId, taskId: $taskId)
          }
      '''),
      ),
    );

    if (result.exception != null) {
      ApiResponse res = ApiResponse.handleError(error: result.exception!);
      if (Get.isSnackbarOpen) return;

      Get.snackbar(
        'خطأ',
        res.data,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
        maxWidth: 300,
        colorText: Colors.white,
      );

      return;
    }

    final l = Get.find<EntidioController>();
    l.lesson.init(curriculum: curriculum.name, level: curriculum.level, termType: curriculum.semester);
    l.userId = c.user.value.id;
    l.verify = task.status == 1;
    l.check = task.status == 2;
    l.shares = task.shares;
    l.taskName = task.taskName;
    l.taskType = task.taskType;
    l.submitTask = () async {
      await WorkData.submitTask(taskId: task.id, curriculumId: curriculum.id, verify: l.verify);
      await Get.toNamed('/work/materials');
    };
    l.goBack = () async => await Get.toNamed('/work/materials');

    if (result.data?['doTask'] != null && task.status == 1 || result.data?['doTask'] != null && task.status == 2) {
      Map data = jsonDecode(result.data?['doTask'][0]);
      l.lesson = Lesson.restore(data: data);

      l.notes.clear();
      for (var i = 1; i < result.data?['doTask'].length; i++) {
        List notes = jsonDecode(result.data?['doTask'][i]);
        for (var el in notes) {
          l.notes.add(EditNote.restore(data: el));
        }
      }
    }

    await Get.toNamed('/work/entidio');
  }

  static submitTask({required int taskId, required int curriculumId, required bool verify}) async {
    final c = Get.find<MainController>();
    final l = Get.find<EntidioController>();

    String data;
    if (!verify) {
      data = jsonEncode(l.lesson.toJson());
    } else {
      List dataList = [];
      for (var el in l.notes) {
        if (el.userId != c.user.value.id) continue;
        dataList.add(el.toJson());
      }
      data = jsonEncode(dataList);
    }

    final QueryResult result = await c.client.mutate(
      MutationOptions(
        variables: {'jwtToken': c.user.value.jwtToken, 'curriculumId': curriculumId, 'taskId': taskId, 'data': data},
        document: gql(r'''
          mutation submitTask($jwtToken: String!, $curriculumId: Int!, $taskId: Int!, $data: String!) {
            submitTask(jwtToken: $jwtToken, curriculumId: $curriculumId, taskId: $taskId, data: $data)
          }
        '''),
      ),
    );

    if (result.exception != null) {
      ApiResponse res = ApiResponse.handleError(error: result.exception!);

      if (Get.isSnackbarOpen) return;

      if (result.exception!.graphqlErrors[0].message == 'ZERO_TRUST') {
        Get.snackbar(
          'خطأ',
          res.data,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.TOP,
          maxWidth: 300,
          colorText: Colors.white,
        );

        await Get.toNamed('/work');
        return;
      }

      Get.snackbar(
        'خطأ',
        res.data,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
        maxWidth: 300,
        colorText: Colors.white,
      );
      Get.toNamed('/work/materials/$curriculumId');
      return;
    }

    Get.snackbar(
      'تم',
      'تم إرسال المهمة بنجاح',
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      maxWidth: 300,
      colorText: Colors.white,
    );
    Get.toNamed('/work/materials/$curriculumId');

    return true;
  }
}

class DoneTask {
  final int id;
  final int time;
  final int shares;
  final String userTaskName;
  final int doItNum;
  final int status; /* 0: cancelled | 1: rejected | 2: to verify | 3: verfied */
  final String level;
  final String curriculum;
  final int userShare;

  DoneTask({
    required this.id,
    required this.time,
    required this.shares,
    required this.userTaskName,
    required this.doItNum,
    required this.status,
    required this.level,
    required this.curriculum,
    required this.userShare,
  });

  @override
  String toString() {
    var s = shares;
    var t = userTaskName;
    var d = doItNum;
    var st = status;
    var l = level;
    var c = curriculum;
    var u = userShare;

    return 'DoneTask(id: $id, time: $time, shares: $s, userTaskName: $t, doItNum: $d, status: $st, level: $l curriculum: $c, userShare: $u)';
  }
}

class Curriculum {
  final int id;
  final String name;
  final int countryId;
  final String levelType;
  final int completedPercent;
  final String level;
  final int semester;

  Curriculum({
    required this.id,
    required this.name,
    required this.countryId,
    required this.levelType,
    required this.completedPercent,
    required this.level,
    required this.semester,
  });

  @override
  String toString() {
    return 'Curriculum(id: $id, name: $name, countryId: $countryId, levelType: $levelType, completedPercent: $completedPercent, level: $level, semester: $semester)';
  }
}

class ActiveTask {
  final int id;
  final int shares;
  final int taskType;
  final String taskName;
  final int status;
  final int curriculumId;
  final int occupied;
  final int? occupiedTime;

  ActiveTask({
    required this.id,
    required this.shares,
    required this.taskType,
    required this.taskName,
    required this.status,
    required this.curriculumId,
    required this.occupied,
    this.occupiedTime,
  });

  @override
  String toString() {
    var s = shares;
    var t = taskType;
    var n = taskName;
    var st = status;
    var c = curriculumId;
    var o = occupied;
    var ot = occupiedTime;

    return 'ActiveTask(id: $id, shares: $s, taskType: $t, taskName: $n, status: $st, curriculumId: $c, occupied: $o occupiedTime: $ot)';
  }
}

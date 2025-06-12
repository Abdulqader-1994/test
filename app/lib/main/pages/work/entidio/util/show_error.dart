import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showErrorMsg({required String text, required VoidCallback func}) {
  Get.snackbar(
    'Error',
    text,
    colorText: Colors.white,
    maxWidth: 200,
    backgroundColor: Colors.red,
    titleText: const Directionality(
      textDirection: TextDirection.ltr,
      child: Text('Error', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
    ),
    messageText: Directionality(
      textDirection: TextDirection.ltr,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    ),
  );

  Future.delayed(const Duration(seconds: 3), () => func());
}

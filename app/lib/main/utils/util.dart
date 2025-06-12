import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Utility {
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  static String setTimeFormat({required int value, int? full}) {
    if (value == 0) return '00:00';

    int duration = full == null ? value : (full * full).floor();

    String minutes = (duration ~/ 60).toString().padLeft(2, '0');
    String secounds = (duration % 60).toString().padLeft(2, '0');
    return '$minutes:$secounds';
  }

  static int getRandomColor() {
    List<int> colorValues = [
      4278190080, // Black
      4294967295, // White
      4294901760, // Red
      4278255360, // Green
      4278190335, // Blue
      4294967040, // Yellow
      4278255615, // Cyan
      4294902015, // Magenta
      4294944000, // Orange
      4294951115, // Pink
      4286578816, // Purple
      4289014310, // Brown
      4286611584, // Gray
      4278222976, // Teal
    ];

    int randomIndex = Random().nextInt(colorValues.length);
    return colorValues[randomIndex];
  }

  static String getUniqueId() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const segmentLength = 4;
    const separator = '-';
    const numSegments = 4;

    String generateSegment() {
      return List.generate(segmentLength, (index) => chars[Random().nextInt(chars.length)]).join('');
    }

    String id = List.generate(numSegments, (index) => generateSegment()).join(separator);
    return id;
  }

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
}

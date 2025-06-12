import 'package:ailence/main/component/page_header.dart';
import 'package:flutter/material.dart';
import '../component/main_widget.dart';

class Games extends StatelessWidget {
  const Games({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainWidget(
      page: Column(
        children: [
          PageHeader(title: 'منصة الألعاب', desc: 'ألعاب العقل تنمي الذاكرة وقوة الملاحظة والتركيز', icon: Icons.sports_esports),
          SizedBox(height: 40),
          Icon(Icons.sentiment_very_dissatisfied, color: Colors.grey, size: 150),
          SizedBox(height: 10),
          Text(
            'للأسف لا يوجد أي لعبة الآن',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 20),
          ),
          SizedBox(height: 30),
          Text(
            'لا تقلق يتم حالياً العمل على تطوير ألعاب العقل',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 17),
          ),
          SizedBox(height: 5),
          Text(
            'وسيتم عرض الألعاب عند إطلاق الموقع رسمياً',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 17),
          ),
        ],
      ),
    );
  }
}

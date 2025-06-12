import 'package:ailence/main/component/page_header.dart';
import 'package:flutter/material.dart';
import '../component/main_widget.dart';

class Social extends StatelessWidget {
  const Social({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainWidget(
      page: Column(
        children: [
          PageHeader(title: 'منصة التواصل', desc: 'منصة تواصل طلابي لمختلف المجالات', icon: Icons.groups),
          SizedBox(height: 40),
          Icon(Icons.sentiment_very_dissatisfied, color: Colors.grey, size: 150),
          SizedBox(height: 10),
          Text(
            'منصة التواصل قيد البناء حالياً',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 20),
          ),
          SizedBox(height: 30),
          Text(
            'لا تقلق يتم العمل عليها حالياً',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 17),
          ),
          SizedBox(height: 5),
          Text(
            'سيتم فتح المنصة عند إطلاق الموقع رسمياً',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 17),
          ),
        ],
      ),
    );
  }
}

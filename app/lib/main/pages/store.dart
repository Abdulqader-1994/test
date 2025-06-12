import 'package:ailence/main/component/page_header.dart';
import 'package:flutter/material.dart';
import '../component/main_widget.dart';

class Store extends StatelessWidget {
  const Store({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainWidget(
      page: Column(
        children: [
          PageHeader(title: 'الـــمـــتـــجـــر', desc: 'اشحن رصيدك واشتر أي من المواد التالية', icon: Icons.add_shopping_cart),
          SizedBox(height: 40),
          Icon(Icons.sentiment_very_dissatisfied, color: Colors.grey, size: 150),
          SizedBox(height: 10),
          Text(
            'للأسف لا يوجد أي مادة للعرض الآن',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 20),
          ),
          SizedBox(height: 30),
          Text(
            'لا تقلق، يتم العمل حالياً على إضافة المحتوى التعليمي',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 17),
          ),
          SizedBox(height: 5),
          Text(
            'ولا تنسى أنه يمكنك كسب المال في منصة العمل عبر صناعة المحتوى التعليمي',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 17),
          ),
        ],
      ),
    );
  }
}

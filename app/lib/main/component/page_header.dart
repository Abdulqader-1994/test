import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_vars.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  const PageHeader({super.key, required this.title, required this.desc, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 20,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(desc, style: const TextStyle(color: background)),
              ],
            ),
          ),
        ),
        Container(
          width: context.width > 500 ? 200 : 120,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              Icon(icon, color: background, size: 70),
              FittedBox(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        )
      ],
    );
  }
}

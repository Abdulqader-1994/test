import 'package:ailence/main/component/page_header.dart';
import 'package:flutter/material.dart';
import '../component/main_widget.dart';

class Study extends StatelessWidget {
  const Study({super.key});

  @override
  Widget build(BuildContext context) {
    return MainWidget(
      page: Column(
        children: [
          PageHeader(title: 'منصة الدراسة', desc: 'اختر المادة وابدأ بنشاط', icon: Icons.auto_stories),
          SizedBox(height: 40),
          Icon(Icons.sentiment_very_dissatisfied, color: Colors.grey, size: 150),
          SizedBox(height: 10),
          Text(
            'أنت غير مشترك في أي مادة',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 20),
          ),
          SizedBox(height: 30),
          Text(
            'اشترك بالمواد عبر المتجر في القائمة الجانبية',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 17),
          ),
          SizedBox(height: 5),
          Text(
            'وبعدها يمكنك الدراسة بتقنيات الذكاء الاصطناعي',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 17),
          ),
        ],
      ),
    );
  }
}

/* 
{
  content: [
    {
      childrenIDs: [],
      id: 20250521-0759-8f23-8363-8259c654f2e7,
      parentId: 0,
      trColor: 4294951115,
      partColor: 0,
      content: [
        {
          "insert":"as",
          "attributes":{"italic":true}
        },
        {"insert":"dasasdas\ndsds"},
        {"insert":"dsewr","attributes":{"color":"#000000"}}
        {"insert":"ewrwe "},
        {"insert":"rewrwerwerw","attributes":{"bold":true}},
        {"insert":"\n"}
      ],
      contentType: ContentType.normal
    }
  ],
  map: {
    id: 20250521-0759-8f23-8363-8259c654f2e7,
    title: ,
    trColor: 4294951115,
    children: []
  },
  country: ,
  eduType: ,
  year: curr,
  term: الفصل الأول والثاني,
  subject: curriculum,
  isRTL: true
}

{
  content: [
    {
      childrenIDs: [20250521-0512-8e10-8183-e9f922a68e93, 20250521-0512-8216-8519-2fe00714383a, 20250521-0512-8c21-9766-9ca5d78dc2b1],
      id: 20250521-0511-8219-b353-787caec362ec,
      parentId: 0,
      trColor: 4294951115,
      partColor: 0,
      content: [{"insert":"jslkdjlsdjflsdjfs \nfsdfsd fsdfsdfsd\n"}],
      contentType: ContentType.normal
    },
    {
      childrenIDs: [],
      id: 20250521-0512-8e10-8183-e9f922a68e93,
      parentId: 20250521-0511-8219-b353-787caec362ec,
      trColor: 4294944000,
      partColor: 0,
      content: [{"insert":"eqioweuqwoi eqweqw\n"}],
      contentType: ContentType.normal
    },
    {
      childrenIDs: [],
      id: 20250521-0512-8216-8519-2fe00714383a,
      parentId: 20250521-0511-8219-b353-787caec362ec,
      trColor: 4289014310,
      partColor: 0,
      content: [{"insert":"dasdasd dasdasdas\n"}],
      contentType: ContentType.normal
    },
    {
      childrenIDs: [],
      id: 20250521-0512-8c21-9766-9ca5d78dc2b1,
      parentId: 20250521-0511-8219-b353-787caec362ec,
      trColor: 4278190335,
      partColor: 0,
      content: [
        {
          "insert":{
            "myImage":"{
              \"base64\":\"/9j/4AAQSkZJRgABAQAAAQABAADjIy.......AFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQBNa/8AHwn4/wAqANGgD//Z\",
              \"width\":825,
              \"ratio\":1.778,
              \"align\":\"center\"
            }"
          }
        },
        {"insert":"\n\nkhjkhk\n"}
      ],
      contentType: ContentType.normal,
    },
  ],
  map: {
    id: 20250521-0511-8219-b353-787caec362ec,
    title: ,
    trColor: 4294951115,
    children: [
      {
        id: 20250521-0512-8e10-8183-e9f922a68e93,
        title: ,
        trColor: 4294944000,
        children: []
      },
      {
        id: 20250521-0512-8216-8519-2fe00714383a,
        title: ,
        trColor: 4289014310,
        children: []
      },
      {
        id: 20250521-0512-8c21-9766-9ca5d78dc2b1,
        title: ,
        trColor: 4278190335,
        children: []
      }
    ]
  },
  country: ,
  eduType: ,
  year: curr,
  term: الفصل الأول والثاني,
  subject: curriculum,
  isRTL: true
}

*/

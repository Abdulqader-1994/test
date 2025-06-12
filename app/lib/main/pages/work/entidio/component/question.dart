import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller.dart';
import '../model/part.dart';
import '../model/question.dart';
import 'rich_text_editor.dart';

class QuestionContent extends StatelessWidget {
  final EntidioController c;
  const QuestionContent({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    List<Widget> childs = [];

    for (var i = 0; i < c.lesson.questions.length; i++) {
      // question header
      childs.add(
        Container(
          color: Colors.blue[900],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text('السؤال رقم ${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
              Row(
                spacing: 3,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /* add new answer */
                  IconButton(
                    onPressed: () {
                      var ques = c.lesson.questions[i];
                      if (ques.type == QuesType.checkBox) (ques as CheckBoxQues).options.add(CheckBoxOption(p: Part(parentId: ques.content.id)));
                      c.update(['ques-$i']);
                    },
                    icon: const Icon(Icons.add_task, color: Colors.white, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(18, 28),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
                    ),
                  ),
                  VerticalDivider(color: Colors.white),
                  IconButton(
                    onPressed: () {
                      c.lesson.questions.removeAt(i);
                      c.update(['all']);
                    },
                    icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(18, 28),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      // question content
      childs.add(
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(border: Border.all(width: 4, color: Colors.blue[900]!)),
          child: GetBuilder<EntidioController>(
            id: 'ques-$i',
            builder: (c) {
              List<Widget> quesContent = [];

              Question ques = c.lesson.questions[i];

              if (ques.type == QuesType.checkBox) {
                ques = ques as CheckBoxQues;

                // question text
                Widget question = Container(
                  decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.blue[600]!)),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 96,
                          color: Colors.blue[600],
                          child: const Center(child: Text('نص السؤال', style: TextStyle(fontSize: 13, color: Colors.white))),
                        ),
                        Expanded(child: RichTextEditor(controller: ques.content.contentEditor, part: ques.content)),
                        IconButton(
                          onPressed: null,
                          icon: const Icon(Icons.question_mark, color: Colors.white, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: const EdgeInsets.all(4),
                            minimumSize: const Size(18, 28),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                quesContent.add(question);

                // answers
                for (int n = 0; n < ques.options.length; n++) {
                  Widget answer = Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.blue[700]!)),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 32,
                            color: Colors.blue[700]!,
                            child: Radio(
                              value: n,
                              groupValue: ques.answer,
                              activeColor: Colors.white,
                              splashRadius: 10,
                              onChanged: (newVal) {
                                (ques as CheckBoxQues).answer = n;
                                c.update(['ques-$i']);
                              },
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                (ques as CheckBoxQues).answer = n;
                                c.update(['ques-$i']);
                              },
                              child: Container(
                                width: 64,
                                color: Colors.blue[700],
                                child: Center(child: Text('الجواب رقم ${n + 1}', style: const TextStyle(fontSize: 11, color: Colors.white))),
                              ),
                            ),
                          ),
                          Expanded(child: RichTextEditor(controller: ques.options[n].p.contentEditor, part: ques.options[n].p)),
                          IconButton(
                            onPressed: () {
                              (ques as CheckBoxQues).options.removeAt(n);
                              if (ques.options.length < 2) ques.options.add(CheckBoxOption(p: Part(parentId: ques.content.id)));
                              c.update(['ques-$i']);
                            },
                            icon: const Icon(Icons.clear, color: Colors.white, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              padding: const EdgeInsets.all(4),
                              minimumSize: const Size(18, 28),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  quesContent.add(answer);
                }
              }
              return Column(children: quesContent);
            },
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: childs);
  }
}

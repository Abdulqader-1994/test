import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import '../controller.dart';
import '../model/part.dart';
import '../util/picker.dart';
import '../util/quill_math_block.dart';
import 'painter.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  bool hasScrollbar = false;
  ScrollController scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EntidioController>(
      id: 'viewMode',
      builder: (c) {
        return c.viewMode
            ? const SizedBox()
            : Directionality(
                textDirection: TextDirection.rtl,
                child: Container(
                  width: double.infinity,
                  height: hasScrollbar ? 82 + 13 /* 13 is scroll height if needed */ : 82,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[800],
                    boxShadow: [BoxShadow(offset: const Offset(0, -1), color: Colors.black.withValues(alpha: 0.2), spreadRadius: 3, blurRadius: 3)],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  child: Center(
                    child: SizedBox(
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(Colors.blueGrey[400]),
                          trackColor: WidgetStateProperty.all(Colors.grey[300]),
                          trackVisibility: WidgetStateProperty.all(true),
                        ),
                        child: NotificationListener<ScrollMetricsNotification>(
                          onNotification: (notification) {
                            setState(() => hasScrollbar = (notification.metrics.maxScrollExtent > 0));
                            return hasScrollbar;
                          },
                          child: Scrollbar(
                            controller: scroll,
                            thumbVisibility: true,
                            thickness: 7.0,
                            radius: const Radius.circular(4.0),
                            child: SingleChildScrollView(
                              controller: scroll,
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: hasScrollbar ? 13 : 0),
                                child: const Row(spacing: 3, children: [AddContent(), PartPropButtons(), TextButtons()]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }
}

class AddContent extends GetView<EntidioController> {
  const AddContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 182,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: Colors.blueGrey[700], borderRadius: const BorderRadius.all(Radius.circular(3))),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          // up row
          AddPartBtn(icon: Icons.playlist_add, text: 'موازي', func: () => controller.addPart(isChild: false)),
          AddPartBtn(icon: Icons.menu_open, text: 'تـابـع', func: () => controller.addPart()),
          IconBtn(icon: Icons.delete_sweep, func: () => controller.deletePart()),

          // down row
          IconBtn(icon: Icons.photo_camera, func: () => AppPicker.pickImage(controller)),
          IconBtn(icon: Icons.functions, func: () => Get.dialog(const MathEditor())),
          IconBtn(icon: Icons.draw, func: () => Get.dialog(const Painter())),
          IconBtn(icon: Icons.rule, func: () => controller.addQuestion()),
          IconBtn(func: () => controller.addEditNote(), icon: Icons.rate_review),
        ],
      ),
    );
  }
}

class PartPropButtons extends GetView<EntidioController> {
  const PartPropButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 146,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: Colors.blueGrey[700], borderRadius: const BorderRadius.all(Radius.circular(3))),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          // up row
          const ContentTypeBtn(),

          // bottom row
          IconBtn(icon: Icons.content_copy, func: () => controller.copyPart()),
          IconBtn(icon: Icons.content_paste, func: () => controller.pastePart()),
          IconBtn(icon: Icons.palette, func: () => AppPicker.pickColor(context: context, k: 'partColor')),
          IconBtn(icon: Icons.border_color, func: () => AppPicker.pickColor(context: context, k: 'trColor')),
        ],
      ),
    );
  }
}

class IconBtn extends StatelessWidget {
  final IconData icon;
  final Function func;
  final bool selected;

  const IconBtn({super.key, required this.func, required this.icon, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
          foregroundColor: Colors.white,
          hoverColor: Colors.blue,
          backgroundColor: selected ? Colors.blue : Colors.blueGrey[600],
        ),
        icon: Icon(icon),
        onPressed: () => func(),
      ),
    );
  }
}

class AddPartBtn extends GetView<EntidioController> {
  final IconData icon;
  final String text;
  final Function func;
  const AddPartBtn({super.key, required this.icon, required this.text, required this.func});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 32,
      child: TextButton.icon(
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
          foregroundColor: Colors.white,
          hoverColor: Colors.blue,
          backgroundColor: Colors.blueGrey[600],
        ),
        onPressed: () => func(),
        icon: Icon(icon, size: 22, color: Colors.white),
        label: Text(text, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

class ContentTypeBtn extends StatelessWidget {
  const ContentTypeBtn({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> types = ['normal', 'numeric', 'bullet'];

    Map<String, IconData> typeIcons = {'normal': Icons.title, 'numeric': Icons.format_list_numbered, 'bullet': Icons.format_list_bulleted};

    return Container(
      height: 32,
      width: 146,
      decoration: BoxDecoration(color: Colors.blueGrey[600], borderRadius: const BorderRadius.all(Radius.circular(3))),
      child: GetBuilder<EntidioController>(
        id: 'contentTypeBtn',
        builder: (c) {
          String value = 'normal';
          if (c.selectedPart != null) value = c.selectedPart!.decor.toString().substring('ContentDecor.'.length);

          return DropdownButton<String>(
            value: value,
            iconEnabledColor: Colors.white,
            isExpanded: true,
            dropdownColor: Colors.blueGrey[800],
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox.shrink(),
            onChanged: (String? value) {
              var selected = ContentDecor.normal;
              if (value == 'numeric') selected = ContentDecor.numeric;
              if (value == 'bullet') selected = ContentDecor.bullet;
              c.setContentType(type: selected);
            },
            items: types.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(children: [Icon(typeIcons[value], color: Colors.white, size: 20), const SizedBox(width: 2), Text(value)]),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class TextButtons extends GetView<EntidioController> {
  const TextButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 318,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: Colors.blueGrey[700], borderRadius: const BorderRadius.all(Radius.circular(3))),
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        children: [
          // up row
          IconBtn(icon: Icons.redo, func: () => controller.editor.redo()),
          IconBtn(icon: Icons.undo, func: () => controller.editor.undo()),
          const FontFamilyBtn(),
          const TextSizeBtn(),

          // down row
          const QuillBtn(id: 'rtlBtn', icon: Icons.format_textdirection_r_to_l, attr: DirectionAttribute('rtl')),
          const QuillBtn(id: 'ltrBtn', icon: Icons.format_textdirection_l_to_r, attr: DirectionAttribute(null)),
          const QuillIconBtn(id: 'boldBtn', icon: Icons.format_bold, attr: Attribute.bold),
          const QuillIconBtn(id: 'italicBtn', icon: Icons.format_italic, attr: Attribute.italic),
          const QuillIconBtn(id: 'underlineBtn', icon: Icons.format_underlined, attr: Attribute.underline),
          const QuillIconBtn(id: 'strikeThroughBtn', icon: Icons.format_strikethrough, attr: Attribute.strikeThrough),
          const QuillIconBtn(id: 'centerBtn', icon: Icons.format_align_center, attr: Attribute.centerAlignment),
          IconBtn(icon: Icons.format_color_text, func: () => AppPicker.pickColor(context: context, k: 'textColor')),
          IconBtn(icon: Icons.format_color_fill, func: () => AppPicker.pickColor(context: context, k: 'bgColor')),
        ],
      ),
    );
  }
}

class FontFamilyBtn extends StatelessWidget {
  const FontFamilyBtn({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> googleFonts = [
      'El Messiri',
      'Almendra',
      'Amiri',
      'Cairo',
      'Lato',
      'Lobster',
      'Montserrat',
      'IBM Plex Sans',
      'Noto Sans',
      'Noto Serif',
      'Open Sans',
      'Playfair Display',
      'Poppins',
      'Roboto',
      'Ubuntu',
    ];

    return Container(
      height: 32,
      width: 137,
      decoration: BoxDecoration(color: Colors.blueGrey[600], borderRadius: const BorderRadius.all(Radius.circular(3))),
      child: GetBuilder<EntidioController>(
        id: 'fontFamilyBtn',
        builder: (c) {
          String font = c.avtiveBtn['fontFamily'];

          return DropdownButton<String>(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            value: font, // This will be null if there's a mix of fonts
            iconEnabledColor: Colors.white,
            isExpanded: true,
            dropdownColor: Colors.blueGrey[800],
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox.shrink(),
            onChanged: (String? value) {
              c.editor.formatSelection(FontAttribute(value));
              c.updateActiveBtn(c.editor.selection);
            },
            selectedItemBuilder: (BuildContext context) => googleFonts.map<Widget>((String value) {
              return Row(
                children: [
                  if (value == font) ...[const Icon(Icons.format_paint, color: Colors.white, size: 16)],
                  SizedBox(width: 60, child: Text(value, style: TextStyle(fontFamily: value, color: Colors.white), overflow: TextOverflow.ellipsis)),
                ],
              );
            }).toList(),
            items: googleFonts.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(fontFamily: value)));
            }).toList(),
          );
        },
      ),
    );
  }
}

class TextSizeBtn extends GetView<EntidioController> {
  const TextSizeBtn({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> sizes = ['micro', 'tiny', 'small', 'medium', 'big', 'large', 'gigantic', 'colossal'];

    // Map each size to a specific font size
    Map<String, String> sizeFontSizes = {
      'micro': '11.5',
      'tiny': '13',
      'small': '14.5',
      'medium': '16',
      'big': '17.5',
      'large': '19',
      'gigantic': '20.5',
      'colossal': '22',
    };

    return Container(
      height: 32,
      width: 102,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: Colors.blueGrey[600], borderRadius: const BorderRadius.all(Radius.circular(3))),
      child: GetBuilder<EntidioController>(
        id: 'fontSizeBtn',
        builder: (c) {
          String selectedSize = 'medium';
          if (c.avtiveBtn['fontSize'] == '11.5') selectedSize = 'micro';
          if (c.avtiveBtn['fontSize'] == '13') selectedSize = 'tiny';
          if (c.avtiveBtn['fontSize'] == '14.5') selectedSize = 'small';
          if (c.avtiveBtn['fontSize'] == '17.5') selectedSize = 'big';
          if (c.avtiveBtn['fontSize'] == '19') selectedSize = 'large';
          if (c.avtiveBtn['fontSize'] == '20.5') selectedSize = 'gigantic';
          if (c.avtiveBtn['fontSize'] == '22') selectedSize = 'colossal';

          return DropdownButton<String>(
            value: selectedSize,
            iconEnabledColor: Colors.white,
            isExpanded: true,
            dropdownColor: Colors.blueGrey[800],
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox.shrink(),
            onChanged: (String? value) {
              if (value == 'micro') selectedSize = 'micro';
              if (value == 'tiny') selectedSize = 'tiny';
              if (value == 'small') selectedSize = 'small';
              if (value == 'medium') selectedSize = 'small';
              if (value == 'big') selectedSize = 'big';
              if (value == 'large') selectedSize = 'large';
              if (value == 'gigantic') selectedSize = 'gigantic';
              if (value == 'colossal') selectedSize = 'colossal';
              c.editor.formatSelection(SizeAttribute(sizeFontSizes[selectedSize]));
              c.updateActiveBtn(c.editor.selection);
            },
            selectedItemBuilder: (BuildContext context) => sizes
                .map<Widget>(
                  (String value) => Row(
                    children: [
                      const Icon(Icons.format_size, color: Colors.white, size: 17),
                      const SizedBox(width: 2),
                      if (value == selectedSize) SizedBox(width: 55, child: Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )
                .toList(),
            items: sizes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(fontSize: double.parse(sizeFontSizes[value]!), color: Colors.white)),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class QuillIconBtn extends StatelessWidget {
  final String id;
  final IconData icon;
  final Attribute attr;

  const QuillIconBtn({super.key, required this.id, required this.icon, required this.attr});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EntidioController>(
      id: id,
      builder: (c) {
        bool isStyleApplied = false;
        if (id == 'boldBtn' && c.avtiveBtn['bold']) isStyleApplied = true;
        if (id == 'italicBtn' && c.avtiveBtn['italic']) isStyleApplied = true;
        if (id == 'underlineBtn' && c.avtiveBtn['underline']) isStyleApplied = true;
        if (id == 'strikeThroughBtn' && c.avtiveBtn['strikeThrough']) isStyleApplied = true;
        if (id == 'centerBtn' && c.avtiveBtn['align'] == 'center') isStyleApplied = true;

        return SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            style: IconButton.styleFrom(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
              padding: EdgeInsets.zero,
              foregroundColor: Colors.white,
              hoverColor: Colors.blue,
              backgroundColor: isStyleApplied ? Colors.blue : Colors.blueGrey[600],
            ),
            icon: Icon(icon),
            onPressed: () {
              c.editor.formatSelection(isStyleApplied ? Attribute.clone(attr, null) : attr);
              c.updateActiveBtn(c.editor.selection);
            },
          ),
        );
      },
    );
  }
}

class QuillBtn extends StatelessWidget {
  final String id;
  final IconData icon;
  final Attribute attr;

  const QuillBtn({super.key, required this.id, required this.icon, required this.attr});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EntidioController>(
      id: id,
      builder: (c) {
        bool isStyleApplied = false;
        if (id == 'rtlBtn' && c.avtiveBtn['rtl']) isStyleApplied = true;
        if (id == 'ltrBtn' && !c.avtiveBtn['rtl']) isStyleApplied = true;

        return SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            style: IconButton.styleFrom(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
              padding: EdgeInsets.zero,
              foregroundColor: Colors.white,
              hoverColor: Colors.blue,
              backgroundColor: isStyleApplied ? Colors.blue : Colors.blueGrey[600],
            ),
            icon: Icon(icon),
            onPressed: () {
              c.editor.formatSelection(attr);
              c.updateActiveBtn(c.editor.selection);
            },
          ),
        );
      },
    );
  }
}

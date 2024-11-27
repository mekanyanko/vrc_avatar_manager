import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:vrc_avatar_manager/text_color_for.dart';

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key, required this.color, this.defaultColor});
  final Color color;
  final Color? defaultColor;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();

  static Future<Color?> show(BuildContext context, Color color,
      {Color? defaultColor}) async {
    return showDialog<Color>(
      context: context,
      builder: (context) {
        return ColorPickerDialog(
          color: color,
          defaultColor: defaultColor,
        );
      },
    );
  }
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color _color = Colors.white;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
  }

  void changeColor(Color color) {
    setState(() => _color = color);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            height: 150,
            child: ColorPicker(
                pickerColor: _color,
                enableAlpha: false,
                onColorChanged: changeColor)),
        BlockPicker(pickerColor: _color, onColorChanged: changeColor),
        if (widget.defaultColor != null)
          ElevatedButton(
              onPressed: () => changeColor(widget.defaultColor!),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.defaultColor,
                foregroundColor: widget.defaultColor!.textColor,
              ),
              child: const Text("デフォルト色"))
      ]),
      actions: [
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop(_color);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: const Text('OK'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

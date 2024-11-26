import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key, required this.color});
  final Color color;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();

  static Future<Color?> show(
    BuildContext context,
    Color color,
  ) async {
    return showDialog<Color>(
      context: context,
      builder: (context) {
        return ColorPickerDialog(
          color: color,
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
        BlockPicker(pickerColor: _color, onColorChanged: changeColor)
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

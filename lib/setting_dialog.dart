import 'package:flutter/material.dart';
import 'package:vrc_avatar_manager/prefs.dart';

class SettingDialog extends StatefulWidget {
  const SettingDialog({super.key});

  @override
  State<SettingDialog> createState() => _SettingDialogState();

  static Future<String?> show(
    BuildContext context,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return SettingDialog();
      },
    );
  }
}

class _SettingDialogState extends State<SettingDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _fetchAvatarSize = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Prefs.instance.then((prefs) async {
      final fetchAvatarSize = await prefs.fetchAvatarSize;
      setState(() {
        _fetchAvatarSize = fetchAvatarSize;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      content: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            CheckboxListTile(
              value: _fetchAvatarSize,
              onChanged: (value) {
                setState(() {
                  _fetchAvatarSize = value!;
                });
              },
              title: const Text("アバターのサイズを取得する(30秒に一回)"),
            ),
          ]))),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            final prefs = await Prefs.instance;
            await prefs.setFetchAvatarSize(_fetchAvatarSize);

            Navigator.of(context).pop();
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

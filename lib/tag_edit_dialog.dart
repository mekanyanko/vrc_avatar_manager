import 'package:flutter/material.dart';
import 'package:vrc_avatar_manager/color_picker_dialog.dart';
import 'package:vrc_avatar_manager/db/tag.dart';
import 'package:vrc_avatar_manager/db/tag_target.dart';
import 'package:vrc_avatar_manager/db/tag_type.dart';
import 'package:vrc_avatar_manager/db/tags_db.dart';
import 'package:vrc_avatar_manager/tag_button.dart';
import 'package:vrc_avatar_manager/text_color_for.dart';

class TagEditDialog extends StatefulWidget {
  const TagEditDialog(
      {super.key,
      required this.tag,
      required this.isNew,
      required this.tagsDb});
  final Tag tag;
  final bool isNew;
  final TagsDb tagsDb;

  @override
  State<TagEditDialog> createState() => _TagEditDialogState();

  static Future<String?> show(
    BuildContext context,
    Tag tag,
    bool isNew,
    TagsDb tagsDb,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return TagEditDialog(tag: tag, isNew: isNew, tagsDb: tagsDb);
      },
    );
  }
}

class _TagEditDialogState extends State<TagEditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  Color _color = Colors.white;
  Color _inactiveColor = Colors.white;
  TagType _type = TagType.items;
  TagTarget _target = TagTarget.name;
  final _searchController = TextEditingController();
  bool _invert = false;
  bool _caseSensitive = false;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.tag.name;
    _color = Color(widget.tag.validColor);
    _inactiveColor = Color(widget.tag.validInactiveColor);
    _type = widget.tag.type;
    _target = widget.tag.target;
    _searchController.text = widget.tag.search;
    _invert = widget.tag.invert;
    _caseSensitive = widget.tag.caseSensitive;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      content: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名前',
              ),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TagType>(
              decoration: const InputDecoration(
                labelText: 'タイプ',
              ),
              value: _type,
              onChanged: (value) {
                setState(() {
                  _type = value!;
                });
              },
              items: TagType.values
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(switch (e) {
                        TagType.items => "リスト",
                        TagType.simple => "文字列検索",
                        TagType.regexp => "正規表現検索",
                      })))
                  .toList(),
            ),
            if (_type != TagType.items)
              DropdownButtonFormField<TagTarget>(
                decoration: const InputDecoration(
                  labelText: '検索対象',
                ),
                value: _target,
                onChanged: (value) {
                  setState(() {
                    _target = value!;
                  });
                },
                items: TagTarget.values
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(switch (e) {
                          TagTarget.name => "name",
                          TagTarget.description => "description",
                        })))
                    .toList(),
              ),
            if (_type != TagType.items)
              TextFormField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: '検索文字列',
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
            if (_type != TagType.items)
              CheckboxListTile(
                value: _invert,
                onChanged: (value) {
                  setState(() {
                    _invert = value!;
                  });
                },
                title: const Text("NOT条件"),
              ),
            if (_type != TagType.items)
              CheckboxListTile(
                value: _caseSensitive,
                onChanged: (value) {
                  setState(() {
                    _caseSensitive = value!;
                  });
                },
                title: const Text("大文字小文字を区別する"),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TagButton(
                    tag: Tag()
                      ..empty()
                      ..name = "有効時色"
                      ..color = _color.value
                      ..inactiveColor = _inactiveColor.value,
                    onPressed: () async {
                      var color = await ColorPickerDialog.show(context, _color,
                          defaultColor: Tag.defaultColor);
                      if (color != null) {
                        setState(() {
                          _color = color;
                        });
                      }
                    },
                    selected: true),
                TagButton(
                    tag: Tag()
                      ..empty()
                      ..name = "無効時色"
                      ..color = _color.value
                      ..inactiveColor = _inactiveColor.value,
                    onPressed: () async {
                      var color = await ColorPickerDialog.show(
                          context, _inactiveColor,
                          defaultColor: Tag.defaultInactiveColor);
                      if (color != null) {
                        setState(() {
                          _inactiveColor = color;
                        });
                      }
                    },
                    selected: false)
              ],
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    _inactiveColor = _color.inactiveColor;
                  });
                },
                child: const Text("有効時色から無効時色を自動計算")),
            TextButton(
                onPressed: () {
                  setState(() {
                    _inactiveColor = Colors.white;
                  });
                },
                child: const Text("無効時色は白")),
          ])),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            widget.tag
              ..name = _nameController.text
              ..color = _color.value
              ..inactiveColor = _inactiveColor.value
              ..type = _type
              ..target = _target
              ..search = _searchController.text
              ..invert = _invert
              ..caseSensitive = _caseSensitive;
            await widget.tagsDb.put(widget.tag);

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
        if (!widget.isNew)
          ElevatedButton(
            onPressed: () async {
              await widget.tagsDb.delete(widget.tag);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
      ],
    );
  }
}

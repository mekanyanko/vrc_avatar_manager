import 'package:flutter/material.dart';
import 'package:vrc_avatar_manager/db/tag.dart';
import 'package:vrc_avatar_manager/text_color_for.dart';

class TagButton extends StatelessWidget {
  const TagButton(
      {super.key,
      required this.tag,
      required this.onPressed,
      required this.selected});
  final Tag tag;
  final Function() onPressed;
  final bool selected;

  static const Size _minimumSize = Size(43, 40);
  static const EdgeInsetsGeometry _padding =
      EdgeInsets.only(left: 10, right: 10);
  static final RoundedRectangleBorder _shape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30));

  @override
  Widget build(BuildContext context) {
    final color = Color(tag.validColor);
    final inactiveColor = Color(tag.validInactiveColor);
    return ElevatedButton(
        style: selected
            ? ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: color.textColor,
                padding: _padding,
                minimumSize: _minimumSize,
                shape: _shape)
            : ElevatedButton.styleFrom(
                backgroundColor: inactiveColor,
                foregroundColor: inactiveColor.textColor,
                padding: _padding,
                minimumSize: _minimumSize,
                shape: _shape),
        onPressed: onPressed,
        child: Text(tag.name));
  }
}

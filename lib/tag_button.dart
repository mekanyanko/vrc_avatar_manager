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

  @override
  Widget build(BuildContext context) {
    final color = Color(tag.validColor);
    final inactiveColor = Color(tag.validInactiveColor);
    return ElevatedButton(
        style: selected
            ? ElevatedButton.styleFrom(
                backgroundColor: color, foregroundColor: color.textColor)
            : ElevatedButton.styleFrom(
                backgroundColor: inactiveColor,
                foregroundColor: inactiveColor.textColor),
        onPressed: onPressed,
        child: Text(tag.name));
  }
}

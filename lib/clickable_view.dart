import 'package:flutter/material.dart';

class ClickableView extends StatelessWidget {
  const ClickableView({super.key, required this.child, required this.onTap});

  final Widget child;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: child,
          onTap: () => onTap(),
        ));
  }
}

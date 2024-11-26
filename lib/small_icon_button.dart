import 'package:flutter/material.dart';

class SmallIconButton extends IconButton {
  const SmallIconButton({
    super.key,
    required super.icon,
    required super.onPressed,
  }) : super(
          padding: const EdgeInsets.all(0),
          constraints: const BoxConstraints(),
        );
}

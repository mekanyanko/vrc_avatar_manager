import 'package:flutter/material.dart';

extension TextColorFor on Color {
  Color get textColor {
    if (computeLuminance() < 0.5) {
      return Colors.white;
    }
    return Colors.black;
  }

  Color get inactiveColor {
    var hslColor = HSLColor.fromColor(this);
    return hslColor
        .withLightness((hslColor.lightness < 0.7
                ? hslColor.lightness + 0.3
                : hslColor.lightness - 0.3)
            .clamp(0, 1))
        .toColor();
  }
}

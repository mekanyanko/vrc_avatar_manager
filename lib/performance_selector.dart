import 'package:flutter/material.dart';
import 'package:vrc_avatar_manager/small_icon_button.dart';
import 'package:vrc_avatar_manager/vrc_icons.dart';
import 'package:vrchat_dart/vrchat_dart.dart';

class PerformanceRankSelector extends StatelessWidget {
  const PerformanceRankSelector(
      {super.key, required this.selected, required this.onChanged});
  final Set<PerformanceRatings> selected;
  final Function(PerformanceRatings) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
        children: PerformanceRatings.values
            .where((p) => p != PerformanceRatings.none)
            .map((p) {
      return Opacity(
        opacity: selected.contains(p) ? 1 : 0.5,
        child: Tooltip(
            message: p.value,
            child: SmallIconButton(
              onPressed: () {
                onChanged(p);
              },
              icon: switch (p) {
                PerformanceRatings.excellent => VrcIcons.excellent,
                PerformanceRatings.good => VrcIcons.good,
                PerformanceRatings.medium => VrcIcons.medium,
                PerformanceRatings.poor => VrcIcons.poor,
                PerformanceRatings.veryPoor => VrcIcons.verypoor,
                _ => VrcIcons.none,
              },
            )),
      );
    }).toList());
  }
}

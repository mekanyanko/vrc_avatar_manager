import 'package:vrchat_dart/vrchat_dart.dart';

class AvatarStat {
  const AvatarStat({required this.main, required this.impostor});
  final UnityPackage? main;
  final UnityPackage? impostor;

  bool get hasMain => main != null;
  bool get hasImpostor => impostor != null;
  PerformanceRatings? get performanceRating => main?.performanceRating;
}

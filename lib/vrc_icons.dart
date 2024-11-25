import 'package:flutter/material.dart';

const double _platformIconSize = 28;
const double _platformIconSize2 = 56;
const double _performanceIconSize = 28;

class VrcIcons {
  static final pc = Image.asset(
    "assets/platform/pc.png",
    width: _platformIconSize,
  );
  static final android = Image.asset(
    "assets/platform/android.png",
    width: _platformIconSize,
  );
  static final crossPlatform = Image.asset(
    "assets/platform/cross_platform.png",
    width: _platformIconSize2,
  );
  static final excellent = Image.asset(
    "assets/performance/excellent.png",
    width: _performanceIconSize,
  );
  static final good = Image.asset(
    "assets/performance/good.png",
    width: _performanceIconSize,
  );
  static final medium = Image.asset(
    "assets/performance/medium.png",
    width: _performanceIconSize,
  );
  static final poor = Image.asset(
    "assets/performance/poor.png",
    width: _performanceIconSize,
  );
  static final verypoor = Image.asset(
    "assets/performance/verypoor.png",
    width: _performanceIconSize,
  );
  static final none = Image.asset(
    "assets/performance/none.png",
    width: _performanceIconSize,
  );
}

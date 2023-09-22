import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  bool get isTouchDevice {
    final platform = Theme.of(this).platform;
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.fuchsia;
  }

  bool get isPointerDevice => !isTouchDevice;

  DeviceKindInteract get kind {
    if (isTouchDevice) return DeviceKindInteract.touch;
    return DeviceKindInteract.pointer;
  }
}

enum DeviceKindInteract {
  touch,
  pointer,
}
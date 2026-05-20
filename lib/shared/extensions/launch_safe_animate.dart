import 'package:flutter/widgets.dart';

import '../../core/config/startup_policy.dart';

extension LaunchSafeAnimate on Widget {
  /// Runs [effect] only after launch animations are enabled.
  Widget launchEffect(Widget Function(Widget child) effect) {
    if (!StartupPolicy.heavyAnimationsEnabled) {
      return this;
    }
    return effect(this);
  }
}

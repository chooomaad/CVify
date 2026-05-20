/// Controls heavy UI work during cold start (TestFlight / iOS Release).
class StartupPolicy {
  StartupPolicy._();

  static bool heavyAnimationsEnabled = false;

  /// Call after first frame + short delay so splash/router stay instant.
  static void enableHeavyAnimations() {
    heavyAnimationsEnabled = true;
  }
}

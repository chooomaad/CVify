import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NSSetUncaughtExceptionHandler { exception in
      NSLog("[CVify][iOS] Uncaught native exception: \(exception.name.rawValue)")
      NSLog("[CVify][iOS] Reason: \(exception.reason ?? "No reason provided")")
      NSLog("[CVify][iOS] Stack: \(exception.callStackSymbols.joined(separator: "\n"))")
    }

    NSLog("[CVify][iOS] App launch started")
    NSLog("[CVify][iOS] Registering Flutter plugins")
    GeneratedPluginRegistrant.register(with: self)
    NSLog("[CVify][iOS] Flutter plugins registered")

    let launched = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    NSLog("[CVify][iOS] super.application returned \(launched)")
    return launched
  }
}

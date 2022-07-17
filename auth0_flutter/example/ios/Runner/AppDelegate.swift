import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if ProcessInfo.processInfo.arguments.contains("SmokeTests") {
            self.window?.layer.speed = 0.0
            UIView.setAnimationsEnabled(false)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

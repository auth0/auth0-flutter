import UIKit
import Flutter
import Auth0

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
    
    override func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
            return WebAuthentication.resume(with: url)
        }
}

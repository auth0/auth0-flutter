import UIKit
import Flutter
import Auth0

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if CommandLine.arguments.contains("--smoke-tests") {
            self.window?.layer.speed = 0.0
            UIView.setAnimationsEnabled(false)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
                WebAuthentication.resume(with: url)
            return super.application(application, open: url, options: options);
        }
}

import Flutter
import UIKit

public class SwiftAuth0FlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugins.flutter.io/auth0_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftAuth0FlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)

    if (call.method == "getPlatformVersion") {
      result("iOS " + UIDevice.current.systemVersion)
    } else if(call.method == "login") {
      result("Token 123456 (iOS)")
    } 
  }
}

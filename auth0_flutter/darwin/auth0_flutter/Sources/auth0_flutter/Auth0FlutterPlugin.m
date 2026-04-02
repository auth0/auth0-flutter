#import "Auth0FlutterPlugin.h"
#if __has_include(<auth0_flutter/auth0_flutter-Swift.h>)
#import <auth0_flutter/auth0_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "auth0_flutter-Swift.h"
#endif

@implementation Auth0FlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAuth0FlutterPlugin registerWithRegistrar:registrar];
}
@end

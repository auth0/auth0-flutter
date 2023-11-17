#if TARGET_OS_IOS
    #import <Flutter/Flutter.h>
#else
    #import <FlutterMacOS/FlutterMacOS.h>
#endif
@interface Auth0FlutterPlugin : NSObject<FlutterPlugin>
@end

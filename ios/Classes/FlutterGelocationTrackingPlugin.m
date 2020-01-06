#import "FlutterGelocationTrackingPlugin.h"
#if __has_include(<flutter_gelocation_tracking/flutter_gelocation_tracking-Swift.h>)
#import <flutter_gelocation_tracking/flutter_gelocation_tracking-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_gelocation_tracking-Swift.h"
#endif

@implementation FlutterGelocationTrackingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterGelocationTrackingPlugin registerWithRegistrar:registrar];
}
@end

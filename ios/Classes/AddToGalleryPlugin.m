#import "AddToGalleryPlugin.h"

#if __has_include(<add_to_gallery/add_to_gallery-Swift.h>)
#import <add_to_gallery/add_to_gallery-Swift.h>
#else
#import "add_to_gallery-Swift.h"
#endif


@implementation AddToGalleryPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAddToGalleryPlugin registerWithRegistrar:registrar];
}
@end

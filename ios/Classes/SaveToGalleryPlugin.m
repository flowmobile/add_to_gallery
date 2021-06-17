#import "SaveToGalleryPlugin.h"

#if __has_include(<save_to_gallery/save_to_gallery-Swift.h>)
#import <save_to_gallery/save_to_gallery-Swift.h>
#else
#import "save_to_gallery-Swift.h"
#endif


@implementation SaveToGalleryPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSaveToGalleryPlugin registerWithRegistrar:registrar];
}
@end

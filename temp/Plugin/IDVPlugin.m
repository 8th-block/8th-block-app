#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(IDVPlugin, "IDV",
           CAP_PLUGIN_METHOD(echo, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(takeSelfiePhoto, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(takeIDPhotoFront, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(takeIDPhotoBack, CAPPluginReturnPromise);
)

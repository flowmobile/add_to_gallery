package flowmobile.add_to_gallery

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AddToGalleryPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "add_to_gallery")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if(call.method == "addToGallery"){
            /*
                MUST use scoped storage
                Images must NOT be deleted if the app is uninstalled
                The path returned to Flutter must be readable with
                    Image.file(File(theGalleryPath))
                The app must have access to the file in perpetuity
                    Even after rebooting
                Images must be visible in Google Photos
                Images must be visible in the named album, ie: "David's App"
                Android 10
                    https://youtu.be/UnJ3amzJM94
                Android 11
                    https://youtu.be/RjyYCUW-9tY
            */
            val album = call.argument<String>("album")!!
            val path = call.argument<String>("path")!!
            // result.error("wip", "Album: ${album}\n\npath: ${path}", null)
            result.success(null)
        } else {
            result.notImplemented()
        }
    }
    
}

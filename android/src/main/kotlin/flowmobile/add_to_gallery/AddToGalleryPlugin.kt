package flowmobile.add_to_gallery

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.IOException
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class AddToGalleryPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    // Copying large videos would block the main thread, so saves run here one at a time
    private lateinit var executor: ExecutorService
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "add_to_gallery")
        channel.setMethodCallHandler(this)
        executor = Executors.newSingleThreadExecutor()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        executor.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method != "addToGallery") {
            result.notImplemented()
            return
        }
        val album = call.argument<String>("album")
        val path = call.argument<String>("path")
        if (album == null || path == null) {
            result.error("bad_args", "Expected path and album arguments", null)
            return
        }
        val isVideo = call.argument<String>("type") == "video"
        val source = File(path)
        if (!source.exists()) {
            result.error("file_not_found", "File not found at path: $path", null)
            return
        }
        executor.execute {
            try {
                val galleryPath = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    addToGalleryLegacy(source, album, isVideo)
                } else {
                    addToGalleryScoped(source, album, isVideo)
                }
                mainHandler.post { result.success(galleryPath) }
            } catch (e: Exception) {
                e.printStackTrace()
                mainHandler.post { result.error("could_not_save_file", e.message, e.toString()) }
            }
        }
    }

    //
    // Android 9 and below
    //
    @Suppress("DEPRECATION")
    private fun addToGalleryLegacy(source: File, album: String, isVideo: Boolean): String {
        val directory = if (isVideo) Environment.DIRECTORY_MOVIES else Environment.DIRECTORY_PICTURES
        val dir = File(Environment.getExternalStoragePublicDirectory(directory), album)
        if (!dir.exists()) {
            dir.mkdirs()
        }
        val file = File(dir, source.name)
        source.copyTo(file, overwrite = true)
        // Add the copy to the gallery
        val values = ContentValues()
        val collection = if (isVideo) {
            values.put(MediaStore.Video.Media.DATE_TAKEN, System.currentTimeMillis())
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        } else {
            values.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis())
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        }
        mimeTypeOf(file)?.let { values.put(MediaStore.MediaColumns.MIME_TYPE, it) }
        values.put(MediaStore.MediaColumns.DATA, file.path)
        if (context.contentResolver.insert(collection, values) == null) {
            // The gallery won't show the copy without a MediaStore entry
            file.delete()
            throw IOException("Could not add ${file.name} to the MediaStore")
        }
        return file.path
    }

    //
    // Android 10 and above
    //
    @RequiresApi(Build.VERSION_CODES.Q)
    private fun addToGalleryScoped(source: File, album: String, isVideo: Boolean): String? {
        // Android 10 only accepts videos in DCIM/ or Movies/
        val (collection, directory) = if (isVideo) {
            MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY) to Environment.DIRECTORY_MOVIES
        } else {
            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY) to Environment.DIRECTORY_PICTURES
        }
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, source.name)
            // When unknown, MediaStore infers the type from the file extension
            mimeTypeOf(source)?.let { put(MediaStore.MediaColumns.MIME_TYPE, it) }
            put(MediaStore.MediaColumns.RELATIVE_PATH, "$directory/$album")
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
        val resolver = context.contentResolver
        val item = resolver.insert(collection, values)
            ?: throw IOException("Could not add ${source.name} to the MediaStore")
        try {
            val output = resolver.openOutputStream(item)
                ?: throw IOException("Could not open $item for writing")
            output.use { out ->
                source.inputStream().use { input -> input.copyTo(out) }
            }
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            if (resolver.update(item, values, null, null) == 0) {
                throw IOException("Could not publish $item to the gallery")
            }
        } catch (e: Exception) {
            // Don't leave an empty, pending item in the gallery
            resolver.delete(item, null, null)
            throw e
        }
        return getRealPathFromURI(item)
    }

    private fun mimeTypeOf(file: File): String? =
        MimeTypeMap.getSingleton().getMimeTypeFromExtension(file.extension.lowercase())

    @Suppress("DEPRECATION")
    private fun getRealPathFromURI(contentUri: Uri): String? {
        val projection = arrayOf(MediaStore.MediaColumns.DATA)
        context.contentResolver.query(contentUri, projection, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                return cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA))
            }
        }
        return null
    }
}

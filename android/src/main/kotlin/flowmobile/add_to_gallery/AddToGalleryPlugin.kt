package flowmobile.add_to_gallery

import android.app.Activity
import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.InputStream

class AddToGalleryPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var context: Context
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "add_to_gallery")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "addToGallery") {
            val album = call.argument<String>("album")!!
            val path = call.argument<String>("path")!!
            val contentResolver: ContentResolver = context.contentResolver;
            try {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    //
                    // Android 9 and below
                    //
                    val filepath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
                    val dir = File(filepath.absolutePath.toString() + "/$album/")
                    if (!dir.exists()) {
                        dir.mkdirs();
                    }
                    val file = File(dir, File(path).name)
                    try {
                        val output = FileOutputStream(file)
                        val inS: InputStream = FileInputStream(File(path))
                        val buf = ByteArray(1024)
                        var len: Int
                        while (inS.read(buf).also { len = it } > 0) {
                            output?.write(buf, 0, len)
                        }
                        inS.close()
                        output.close()
                        // Copy image into  Gallery
                        val values = ContentValues()
                        values.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis())
                        values.put(MediaStore.Images.Media.MIME_TYPE, "images/*")
                        values.put(MediaStore.MediaColumns.DATA, file.path)
                        contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                        result.success(file.path)
                    } catch (e: java.lang.Exception) {
                        e.printStackTrace()
                        result.error("error", null, null)
                    }
                } else {
                    //
                    // Android 10 and above
                    //
                    val value = ContentValues().apply {
                        put(MediaStore.Images.Media.DISPLAY_NAME, File(path).name)
                        put(MediaStore.Images.Media.MIME_TYPE, "images/*")
                        put(MediaStore.MediaColumns.RELATIVE_PATH, "Pictures/$album")
                        put(MediaStore.Images.Media.IS_PENDING, 1)
                    }
                    val resolver = contentResolver
                    val collection = MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
                    val item = resolver.insert(collection, value)
                    if (item != null) {
                        resolver.openOutputStream(item).use { out ->
                            val inS: InputStream = FileInputStream(File(path))
                            val buf = ByteArray(1024)
                            var len: Int
                            while (inS.read(buf).also { len = it } > 0) {
                                out?.write(buf, 0, len)
                            }
                            inS.close()
                            out?.close()
                        }
                        value.clear()
                        value.put(MediaStore.Images.Media.IS_PENDING, 0)
                        resolver.update(item, value, null, null)
                        result.success(getRealPathFromURI(context, item))
                    } else {
                        result.error("error", null, null)
                    }
                }
            } catch (e: Exception) {
                result.error("error", null, null)
                e.printStackTrace()
            }
        } else {
            result.notImplemented()
        }
    }

    fun getRealPathFromURI(context: Context, contentUri: Uri?): String? {
        var cursor: Cursor? = null
        return try {
            val proj = arrayOf(MediaStore.Images.Media.DATA)
            cursor = context.contentResolver.query(contentUri!!, proj, null, null, null)
            val column_index: Int = cursor!!.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            cursor.moveToFirst()
            cursor.getString(column_index)
        } finally {
            cursor?.close()
        }
    }
}

package flowmobile.add_to_gallery

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.*

enum class MediaType { image, video }
/**
 * Class holding implementation of saving images and videos
 */
class AddToGallery internal constructor(private val activity: Activity) :
    PluginRegistry.RequestPermissionsResultListener {

    private var pendingResult: MethodChannel.Result? = null
    private var mediaType: MediaType? = null
    private var filePath: String = ""
    private var albumName: String = ""

    private val job = Job()
    private val uiScope = CoroutineScope(Dispatchers.Main + job)

    /**
     * Saves image or video to device
     *
     * @param call       - method call
     * @param result     - result to be set when saving operation finishes
     */
    internal fun checkPermissionAndSaveFile(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val type = call.argument<String>("type")!!
        this.filePath = call.argument<String>("path")!!
        this.albumName = call.argument<String>("albumName")!!
        this.mediaType = if (type == "image") MediaType.image else MediaType.video
        this.pendingResult = result

        if (isWritePermissionGranted()) {
            saveMediaFile()
        } else {
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION
            )
        }
    }

    private fun isWritePermissionGranted(): Boolean {
        return PackageManager.PERMISSION_GRANTED ==
                ActivityCompat.checkSelfPermission(
                    activity, Manifest.permission.WRITE_EXTERNAL_STORAGE
                )
    }

    private fun saveMediaFile() {
        uiScope.launch {
            val path = async(Dispatchers.IO) {
                if (mediaType == MediaType.video) {
                    FileUtils.insertVideo(activity.contentResolver, filePath, albumName)
                } else {
                    FileUtils.insertImage(activity.contentResolver, filePath, albumName)
                }
            }
            finishWithSuccess(path.await())
        }
    }

    private fun finishWithSuccess(path: String?) {
        if(path != null){
            pendingResult!!.success(path)
        } else {
            pendingResult!!.error("error", "Could not save image to gallery", null)
        }
        pendingResult = null
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<String>, grantResults: IntArray
    ): Boolean {
        val permissionGranted = grantResults.isNotEmpty()
                && grantResults[0] == PackageManager.PERMISSION_GRANTED

        if (requestCode == REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION) {
            if (permissionGranted) {
                if (mediaType == MediaType.video) {
                    FileUtils.insertVideo(activity.contentResolver, filePath, albumName)
                } else {
                    FileUtils.insertImage(activity.contentResolver, filePath, albumName)
                }
            }
        } else {
            return false
        }
        return true
    }

    companion object {
        private const val REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION = 2408
    }
}
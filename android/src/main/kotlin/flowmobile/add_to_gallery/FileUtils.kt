package flowmobile.add_to_gallery

import android.content.ContentResolver
import android.content.ContentValues
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import android.text.TextUtils
import android.util.Log
import android.webkit.MimeTypeMap
import java.io.*

/**
 * Core implementation of methods related to File manipulation
 */
internal object FileUtils {

    private const val BUFFER_SIZE = 1024 * 1024 * 8
    private const val EOF = -1

    /**
     * Inserts image into external storage
     *
     * @param contentResolver - content resolver
     * @param path            - path to temp file that needs to be stored
     * @param albumName       - album name for storing image
     * @return path to newly created file
     */
    fun insertImage(
        contentResolver: ContentResolver,
        path: String,
        albumName: String
    ): String? {
        val file = File(path)
        val extension = MimeTypeMap.getFileExtensionFromUrl(file.toString())
        val mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
        var source = getBytesFromFile(file)

        return albumName

        /*
        val albumDir = File(getAlbumFolderPath(albumName, MediaType.image))
        val imageFilePath = File(albumDir, file.name).absolutePath

        val values = ContentValues()
        values.put(MediaStore.Images.ImageColumns.DATA, imageFilePath)
        values.put(MediaStore.Images.Media.TITLE, file.name)
        values.put(MediaStore.Images.Media.DISPLAY_NAME, file.name)
        values.put(MediaStore.Images.Media.MIME_TYPE, mimeType)
        values.put(MediaStore.Images.Media.DATE_ADDED, System.currentTimeMillis())
        values.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis())

        var imageUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI

        try {
            imageUri = contentResolver.insert(imageUri, values)
            if (source != null) {
                var outputStream: OutputStream? = null
                if (imageUri != null) {
                    outputStream = contentResolver.openOutputStream(imageUri)
                }
                outputStream?.use {
                    outputStream.write(source)
                }
                if (imageUri != null) {
                    return getFilePathFromContentUri(imageUri, contentResolver)
                }
            } else {
                if (imageUri != null) {
                    contentResolver.delete(imageUri, null, null)
                }
                imageUri = null
            }
        } catch (e: IOException) {
            contentResolver.delete(imageUri!!, null, null)
            return null
        } catch (t: Throwable) {
            return null
        }
        return null
        */
    }

    /**
     * @param uri             - provided file uri
     * @param contentResolver - content resolver
     * @return path from provided Uri
     */
    private fun getFilePathFromContentUri(
        uri: Uri,
        contentResolver: ContentResolver
    ): String? {
        var filePath: String? = null
        val cursor = contentResolver.query(uri, arrayOf(MediaStore.MediaColumns.DATA), null, null, null)
        var columnIndex: Int
        cursor?.use {
            cursor.moveToFirst()
            columnIndex = cursor.getColumnIndex(MediaStore.MediaColumns.DATA)
            filePath = cursor.getString(columnIndex)
        }
        return filePath
    }

    private fun getBytesFromFile(
        file: File
    ): ByteArray? {
        val size = file.length().toInt()
        val bytes = ByteArray(size)
        val buf = BufferedInputStream(FileInputStream(file))
        buf.use {
            buf.read(bytes, 0, bytes.size)
        }

        return bytes
    }

    /**
     * @param contentResolver - content resolver
     * @param path            - path to temp file that needs to be stored
     * @param albumName      - folder name for storing video
     * @return path to newly created file
     */
    fun insertVideo(
        contentResolver: ContentResolver,
        inputPath: String,
        albumName: String,
        bufferSize: Int = BUFFER_SIZE
    ): String? {

        val inputFile = File(inputPath)
        val inputStream: InputStream?
        val outputStream: OutputStream?

        val extension = MimeTypeMap.getFileExtensionFromUrl(inputFile.toString())
        val mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)

        val albumDir = File(getAlbumFolderPath(albumName, MediaType.video))
        val videoFilePath = File(albumDir, inputFile.name).absolutePath

        val values = ContentValues()
        values.put(MediaStore.Video.VideoColumns.DATA, videoFilePath)
        values.put(MediaStore.Video.Media.TITLE, inputFile.name)
        values.put(MediaStore.Video.Media.DISPLAY_NAME, inputFile.name)
        values.put(MediaStore.Video.Media.MIME_TYPE, mimeType)
        // Add the date meta data to ensure the image is added at the front of the gallery
        values.put(MediaStore.Video.Media.DATE_ADDED, System.currentTimeMillis())
        values.put(MediaStore.Video.Media.DATE_TAKEN, System.currentTimeMillis())

        try {
            val url = contentResolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
            inputStream = FileInputStream(inputFile)
            if (url != null) {
                outputStream = contentResolver.openOutputStream(url)
                val buffer = ByteArray(bufferSize)
                inputStream.use {
                    outputStream?.use {
                        var len = inputStream.read(buffer)
                        while (len != EOF) {
                            outputStream.write(buffer, 0, len)
                            len = inputStream.read(buffer)
                        }
                    }
                }
                if (url != null) {
                    return getFilePathFromContentUri(url, contentResolver)
                }
            }
        } catch (fnfE: FileNotFoundException) {
            Log.e("AddToGallery", fnfE.message)
            return null
        } catch (e: Exception) {
            Log.e("AddToGallery", e.message)
            return null
        }
        return null
    }

    private fun getAlbumFolderPath(
        albumName: String,
        mediaType: MediaType
    ): String? {
        var albumFolderPath: String = Environment.getExternalStorageDirectory().path + File.separator + albumName
        return createDirIfNotExist(albumFolderPath);
    }

    private fun createDirIfNotExist(
        dirPath: String
    ): String? {
        val dir = File(dirPath)
        if (!dir.exists()) {
            if (!dir.mkdirs()) {
                return null
            }
        }
        return dir.path
    }
    
}

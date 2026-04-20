package com.galaxydox.app

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveImageToGallery" -> saveImageToGallery(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun saveImageToGallery(call: MethodCall, result: MethodChannel.Result) {
        val fileName = call.argument<String>("fileName")
        val mimeType = call.argument<String>("mimeType") ?: "image/jpeg"
        val bytes = call.argument<ByteArray>("bytes")

        if (fileName.isNullOrBlank() || bytes == null || bytes.isEmpty()) {
            result.error("INVALID_ARGS", "Wallpaper payload was incomplete.", null)
            return
        }

        try {
            val savedPath =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    saveWithMediaStore(fileName, mimeType, bytes)
                } else {
                    saveToLegacyPictures(fileName, mimeType, bytes)
                }

            result.success(savedPath)
        } catch (error: Exception) {
            result.error("SAVE_FAILED", error.message, null)
        }
    }

    private fun saveWithMediaStore(
        fileName: String,
        mimeType: String,
        bytes: ByteArray,
    ): String {
        val resolver = applicationContext.contentResolver
        val relativePath = "${Environment.DIRECTORY_PICTURES}/GalaxyDox"
        val contentValues =
            ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }

        val collection = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val uri =
            resolver.insert(collection, contentValues)
                ?: throw IOException("MediaStore entry could not be created.")

        resolver.openOutputStream(uri)?.use { stream ->
            stream.write(bytes)
            stream.flush()
        } ?: throw IOException("Gallery file stream could not be opened.")

        contentValues.clear()
        contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
        resolver.update(uri, contentValues, null, null)

        return "$relativePath/$fileName"
    }

    private fun saveToLegacyPictures(
        fileName: String,
        mimeType: String,
        bytes: ByteArray,
    ): String {
        val picturesDir =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
        val galleryDir = File(picturesDir, "GalaxyDox")
        if (!galleryDir.exists() && !galleryDir.mkdirs()) {
            throw IOException("GalaxyDox folder could not be created.")
        }

        val targetFile = File(galleryDir, fileName)
        targetFile.writeBytes(bytes)

        MediaScannerConnection.scanFile(
            applicationContext,
            arrayOf(targetFile.absolutePath),
            arrayOf(mimeType),
            null,
        )

        return targetFile.absolutePath
    }

    companion object {
        private const val CHANNEL_NAME = "com.galaxydox.app/wallpaper_downloads"
    }
}

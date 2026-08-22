package com.gharsaheli.ghar_saheli

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Native side of the in-app updater.
 *
 * Written by hand rather than pulled in as a plugin: the whole job is three
 * platform calls, and an unmaintained package sitting on the path that installs
 * APKs is a bad trade for sixty lines of Kotlin. It also means no extra Dart
 * dependency against the size budget.
 */
class MainActivity : FlutterActivity() {

    private val channelName = "ghar_saheli/updates"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "installedVersion" -> result.success(installedVersion())
                "canInstallPackages" -> result.success(canInstallPackages())
                "openInstallPermissionSettings" -> {
                    openInstallPermissionSettings()
                    result.success(null)
                }
                "installApk" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrEmpty()) {
                        result.error("NO_PATH", "No file was given to install.", null)
                    } else {
                        installApk(path, result)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Read from the package manager rather than passed down from Dart, so it
     * is always the version actually installed and cannot drift from pubspec.
     */
    private fun installedVersion(): Map<String, Any> {
        val info = packageManager.getPackageInfo(packageName, 0)
        val code = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            info.versionCode.toLong()
        }
        return mapOf(
            "versionCode" to code.toInt(),
            "versionName" to (info.versionName ?: "")
        )
    }

    /**
     * Android 8.0 replaced the single system-wide "unknown sources" switch with
     * a per-app permission. Below that, sideloading was allowed globally and
     * there is nothing to ask for.
     */
    private fun canInstallPackages(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            packageManager.canRequestPackageInstalls()
        } else {
            true
        }
    }

    private fun openInstallPermissionSettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val intent = Intent(
            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
            Uri.parse("package:$packageName")
        )
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun installApk(path: String, result: MethodChannel.Result) {
        val file = File(path)
        if (!file.exists()) {
            result.error("MISSING", "The downloaded file is no longer there.", null)
            return
        }

        try {
            // A raw file:// URI throws FileUriExposedException on Android 7+.
            // The installer is a separate app, so the file has to be handed
            // over through a provider with a temporary read grant rather than
            // by path.
            val uri: Uri = FileProvider.getUriForFile(
                this,
                "$packageName.updateprovider",
                file
            )

            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/vnd.android.package-archive")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            result.success(true)
        } catch (error: Exception) {
            result.error("INSTALL_FAILED", error.message, null)
        }
    }
}

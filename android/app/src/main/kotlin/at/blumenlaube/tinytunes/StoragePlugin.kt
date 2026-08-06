package at.blumenlaube.tinytunes

import android.os.StatFs
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Narrow storage MethodChannel for free-space checks.
 *
 * Purpose: Let cloud downloads refuse when the device cannot hold the file.
 * No write APIs beyond reading [StatFs].
 */
class StoragePlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "availableBytes" -> {
                val path = call.argument<String>("path")
                if (path.isNullOrEmpty()) {
                    result.error("bad_args", "path required", null)
                    return
                }
                try {
                    val target = File(path)
                    val probe = if (target.exists()) target else target.parentFile
                    if (probe == null || !probe.exists()) {
                        result.error("missing_path", "path does not exist: $path", null)
                        return
                    }
                    val stat = StatFs(probe.absolutePath)
                    result.success(stat.availableBytes)
                } catch (e: Exception) {
                    result.error(
                        "stat_failed",
                        "${e.javaClass.simpleName}: ${e.message ?: "no message"}",
                        null,
                    )
                }
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val CHANNEL = "at.blumenlaube.tinytunes/storage"
    }
}

package at.blumenlaube.tinytunes

import android.content.pm.PackageManager
import android.os.Build
import android.util.Base64
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

/**
 * Narrow MethodChannel for the installed APK's signing-certificate SHA-1.
 *
 * Purpose: Let Dart decide whether this build is the official GitHub APK
 * (package + release cert) before contacting GitHub for updates.
 * The hash format matches MSAL's Android signature hash (Base64 of SHA-1).
 */
class PackageIdentityPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var packageName: String
    private lateinit var packageManager: PackageManager

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        packageName = binding.applicationContext.packageName
        packageManager = binding.applicationContext.packageManager
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sha1Base64" -> {
                try {
                    result.success(signingSha1Base64())
                } catch (e: Exception) {
                    result.error(
                        "signing_hash_failed",
                        "${e.javaClass.simpleName}: ${e.message ?: "no message"}",
                        null,
                    )
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun signingSha1Base64(): String? {
        val cert = signingCertBytes() ?: return null
        val digest = MessageDigest.getInstance("SHA-1").digest(cert)
        return Base64.encodeToString(digest, Base64.NO_WRAP)
    }

    private fun signingCertBytes(): ByteArray? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val info = packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNING_CERTIFICATES,
            )
            val signingInfo = info.signingInfo ?: return null
            val signers = if (signingInfo.hasMultipleSigners()) {
                signingInfo.apkContentsSigners
            } else {
                signingInfo.signingCertificateHistory
            }
            return signers.firstOrNull()?.toByteArray()
        }
        @Suppress("DEPRECATION")
        val info = packageManager.getPackageInfo(
            packageName,
            PackageManager.GET_SIGNATURES,
        )
        @Suppress("DEPRECATION")
        return info.signatures?.firstOrNull()?.toByteArray()
    }

    companion object {
        const val CHANNEL = "at.blumenlaube.tinytunes/package_identity"
    }
}

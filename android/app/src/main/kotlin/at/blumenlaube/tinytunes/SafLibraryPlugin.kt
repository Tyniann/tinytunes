package at.blumenlaube.tinytunes

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.FileOutputStream

/**
 * Narrow SAF MethodChannel for Phase 0 library access.
 *
 * Purpose: Pick a document tree, take persistable READ permission, list children,
 * and copy document bytes for path-only metadata APIs. No write APIs.
 */
class SafLibraryPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingPickResult: MethodChannel.Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
        appContext = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickAndPersistTree" -> pickAndPersistTree(result)
            "listChildren" -> {
                val directoryUri = call.argument<String>("directoryUri")
                if (directoryUri.isNullOrEmpty()) {
                    result.error("bad_args", "directoryUri required", null)
                } else {
                    try {
                        result.success(listChildren(directoryUri))
                    } catch (e: Exception) {
                        result.error(
                            "list_failed",
                            "${e.javaClass.simpleName}: ${e.message ?: "no message"} ($directoryUri)",
                            null,
                        )
                    }
                }
            }
            "hasPersisted" -> {
                val treeUri = call.argument<String>("treeUri")
                if (treeUri.isNullOrEmpty()) {
                    result.error("bad_args", "treeUri required", null)
                } else {
                    result.success(hasPersisted(treeUri))
                }
            }
            "listPersisted" -> result.success(listPersisted())
            "release" -> {
                val treeUri = call.argument<String>("treeUri")
                if (treeUri.isNullOrEmpty()) {
                    result.error("bad_args", "treeUri required", null)
                } else {
                    release(treeUri)
                    result.success(null)
                }
            }
            "copyToCache" -> {
                val documentUri = call.argument<String>("documentUri")
                val destPath = call.argument<String>("destPath")
                val maxBytes = call.argument<Number>("maxBytes")?.toLong() ?: DEFAULT_MAX_BYTES
                if (documentUri.isNullOrEmpty() || destPath.isNullOrEmpty()) {
                    result.error("bad_args", "documentUri and destPath required", null)
                } else {
                    try {
                        copyToCache(documentUri, destPath, maxBytes)
                        result.success(destPath)
                    } catch (e: Exception) {
                        result.error(
                            "copy_failed",
                            "${e.javaClass.simpleName}: ${e.message ?: "no message"}",
                            null,
                        )
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun pickAndPersistTree(result: MethodChannel.Result) {
        val act = activity
        if (act == null) {
            result.error("no_activity", "Activity not attached", null)
            return
        }
        if (pendingPickResult != null) {
            result.error("busy", "A folder pick is already in progress", null)
            return
        }
        pendingPickResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
            )
        }
        act.startActivityForResult(intent, REQUEST_OPEN_TREE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_OPEN_TREE) return false
        val pending = pendingPickResult ?: return false
        pendingPickResult = null
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            pending.success(null)
            return true
        }
        val uri = data.data!!
        val act = activity
        if (act == null) {
            pending.error("no_activity", "Activity gone after pick", null)
            return true
        }
        try {
            act.contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
            pending.success(uri.toString())
        } catch (e: SecurityException) {
            pending.error("persist_failed", e.message, null)
        }
        return true
    }

    /**
     * Lists one directory level via [DocumentsContract] (reliable under tree grants).
     *
     * [DocumentFile.listFiles] often fails on document-under-tree URIs during recursion.
     */
    private fun listChildren(directoryUri: String): List<Map<String, Any?>> {
        val ctx = appContext ?: error("No application context")
        val uri = Uri.parse(directoryUri)
        val authority = uri.authority ?: error("URI has no authority: $directoryUri")

        val treeDocumentId: String
        val parentDocumentId: String
        when {
            DocumentsContract.isDocumentUri(ctx, uri) -> {
                treeDocumentId = DocumentsContract.getTreeDocumentId(uri)
                parentDocumentId = DocumentsContract.getDocumentId(uri)
            }
            DocumentsContract.isTreeUri(uri) -> {
                treeDocumentId = DocumentsContract.getTreeDocumentId(uri)
                parentDocumentId = treeDocumentId
            }
            else -> error("Not a SAF tree/document URI: $directoryUri")
        }

        val treeUri = DocumentsContract.buildTreeDocumentUri(authority, treeDocumentId)
        val childrenUri =
            DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentDocumentId)

        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
        )

        val out = ArrayList<Map<String, Any?>>()
        var cursor: Cursor? = null
        try {
            cursor = ctx.contentResolver.query(childrenUri, projection, null, null, null)
                ?: return emptyList()
            val idIdx = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
            val nameIdx =
                cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
            val mimeIdx = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)
            while (cursor.moveToNext()) {
                val docId = cursor.getString(idIdx) ?: continue
                val name = cursor.getString(nameIdx) ?: ""
                val mime = cursor.getString(mimeIdx) ?: ""
                val childUri =
                    DocumentsContract.buildDocumentUriUsingTree(treeUri, docId).toString()
                out.add(
                    mapOf(
                        "uri" to childUri,
                        "name" to name,
                        "isDirectory" to (mime == DocumentsContract.Document.MIME_TYPE_DIR),
                    ),
                )
            }
        } finally {
            cursor?.close()
        }
        return out
    }

    private fun hasPersisted(treeUri: String): Boolean {
        val ctx = appContext ?: return false
        val target = Uri.parse(treeUri)
        return ctx.contentResolver.persistedUriPermissions.any {
            it.uri == target && it.isReadPermission
        }
    }

    private fun listPersisted(): List<String> {
        val ctx = appContext ?: return emptyList()
        return ctx.contentResolver.persistedUriPermissions
            .filter { it.isReadPermission }
            .map { it.uri.toString() }
    }

    private fun release(treeUri: String) {
        val ctx = appContext ?: return
        val uri = Uri.parse(treeUri)
        try {
            ctx.contentResolver.releasePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
        } catch (_: SecurityException) {
            // Already released or never granted.
        }
    }

    private fun copyToCache(documentUri: String, destPath: String, maxBytes: Long) {
        val ctx = appContext ?: error("No application context")
        val uri = Uri.parse(documentUri)
        val dest = File(destPath)
        dest.parentFile?.mkdirs()
        ctx.contentResolver.openInputStream(uri).use { input ->
            requireNotNull(input) { "Cannot open $documentUri" }
            FileOutputStream(dest).use { output ->
                val buffer = ByteArray(DEFAULT_BUFFER)
                var total = 0L
                while (true) {
                    val read = input.read(buffer)
                    if (read <= 0) break
                    total += read
                    if (total > maxBytes) {
                        output.close()
                        dest.delete()
                        error("File exceeds maxBytes ($maxBytes)")
                    }
                    output.write(buffer, 0, read)
                }
            }
        }
    }

    companion object {
        const val CHANNEL = "at.blumenlaube.tinytunes/saf"
        private const val REQUEST_OPEN_TREE = 0x51AF
        private const val DEFAULT_MAX_BYTES = 100L * 1024L * 1024L
        private const val DEFAULT_BUFFER = 64 * 1024

        @Volatile
        private var appContext: android.content.Context? = null
    }
}

package at.blumenlaube.tinytunes

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Hosts SAF MethodChannel + audio_service.
 *
 * Extends [AudioServiceActivity] (package README) so media-session wiring stays
 * intact while still registering [SafLibraryPlugin].
 */
class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(SafLibraryPlugin())
        flutterEngine.plugins.add(StoragePlugin())
    }
}

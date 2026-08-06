import 'package:googleapis/drive/v3.dart' as drive;
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/google_access_token_client.dart';
import 'package:tinytunes/core/cloud/google_drive_auth.dart';
import 'package:tinytunes/core/library/media_locator.dart';

/// One child under a Drive folder for the Phase 7 OAuth spike.
///
/// Purpose: Prove list-after-sign-in without building full ingest UI yet.
/// Usage Context: Returned by [GoogleDriveProbe.listMyDriveRoot].
class DriveProbeEntry {
  /// Creates a listed Drive child.
  const DriveProbeEntry({
    required this.locator,
    required this.name,
    required this.isDirectory,
  });

  /// Opaque `gdrive:<fileId>` locator.
  final MediaLocator locator;

  /// Display name from Drive.
  final String name;

  /// Whether this entry is a Drive folder.
  final bool isDirectory;
}

/// Minimal read-only Drive listing used to gate Phase 7 OAuth on device.
///
/// Purpose: Sign-in → list My Drive root children → prove API access works.
/// Usage Context: Settings spike buttons; replaced by [CloudLibrarySource] in
/// Step 1 for production listing.
class GoogleDriveProbe {
  /// Creates a probe that obtains tokens from [auth].
  GoogleDriveProbe(this._auth);

  final GoogleDriveAuth _auth;

  static const _folderMime = 'application/vnd.google-apps.folder';

  /// Lists non-trashed children directly under the user's My Drive root.
  Future<List<DriveProbeEntry>> listMyDriveRoot({int pageSize = 50}) async {
    final token = await _auth.accessTokenForDriveReadonly();
    final client = GoogleAccessTokenClient(accessToken: token);
    try {
      final api = drive.DriveApi(client);
      final listed = await api.files.list(
        q: "'root' in parents and trashed = false",
        $fields: 'files(id, name, mimeType)',
        pageSize: pageSize,
        spaces: 'drive',
        corpora: 'user',
      );
      final files = listed.files ?? const <drive.File>[];
      return [
        for (final file in files)
          if (file.id != null && file.name != null)
            DriveProbeEntry(
              locator: DriveMediaLocator.encode(file.id!),
              name: file.name!,
              isDirectory: file.mimeType == _folderMime,
            ),
      ];
    } finally {
      client.close();
    }
  }
}

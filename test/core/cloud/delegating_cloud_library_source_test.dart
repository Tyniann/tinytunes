import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/cloud/delegating_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_media_locator.dart';
import 'package:tinytunes/core/library/media_locator.dart';

void main() {
  test('routes Google locators only to the Google source', () async {
    final google = RecordingCloudLibrarySource(CloudProviderId.googleDrive);
    final oneDrive = RecordingCloudLibrarySource(CloudProviderId.oneDrive);
    final router = DelegatingCloudLibrarySource({
      CloudProviderId.googleDrive: google,
      CloudProviderId.oneDrive: oneDrive,
    });

    final g = DriveMediaLocator.encode('file1');
    await router.list(g);
    await router.downloadToCache(g);
    await expectLater(router.resolveCached(g), throwsA(isA<CloudCacheMissException>()));

    expect(google.listCalls, 1);
    expect(google.downloadCalls, 1);
    expect(google.resolveCalls, 1);
    expect(oneDrive.listCalls, 0);
    expect(oneDrive.downloadCalls, 0);
    expect(oneDrive.resolveCalls, 0);
  });

  test('routes OneDrive locators only to the OneDrive source', () async {
    final google = RecordingCloudLibrarySource(CloudProviderId.googleDrive);
    final oneDrive = RecordingCloudLibrarySource(CloudProviderId.oneDrive);
    final router = DelegatingCloudLibrarySource({
      CloudProviderId.googleDrive: google,
      CloudProviderId.oneDrive: oneDrive,
    });

    final o = OneDriveMediaLocator.encode(driveId: 'd', itemId: 'i');
    await router.list(o);
    expect(oneDrive.listCalls, 1);
    expect(google.listCalls, 0);
  });

  test('throws when provider is not registered', () async {
    final router = DelegatingCloudLibrarySource({
      CloudProviderId.googleDrive: RecordingCloudLibrarySource(
        CloudProviderId.googleDrive,
      ),
    });
    final o = OneDriveMediaLocator.encode(driveId: 'd', itemId: 'i');
    expect(() => router.list(o), throwsStateError);
  });
}

/// Records which methods were invoked for router isolation tests.
class RecordingCloudLibrarySource implements CloudLibrarySource {
  /// Creates a recorder tagged with [provider] for assertion messages.
  RecordingCloudLibrarySource(this.provider);

  /// Provider this fake stands in for.
  final CloudProviderId provider;

  /// Count of [list] calls.
  int listCalls = 0;

  /// Count of [downloadToCache] calls.
  int downloadCalls = 0;

  /// Count of [resolveCached] calls.
  int resolveCalls = 0;

  @override
  Future<List<CloudLibraryEntry>> list(MediaLocator parent) async {
    listCalls++;
    return const [];
  }

  @override
  Future<MediaLocator> downloadToCache(
    MediaLocator item, {
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) async {
    downloadCalls++;
    return const MediaLocator('/tmp/missing.bin');
  }

  @override
  Future<Uri> resolveCached(MediaLocator item) async {
    resolveCalls++;
    throw CloudCacheMissException(item);
  }
}

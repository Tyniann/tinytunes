import 'package:tinytunes/core/updates/github_release.dart';
import 'package:tinytunes/core/updates/github_release_client.dart';

/// Test double that never hits the network.
///
/// Purpose: Default [pumpApp] override so [UpdateCheckBinder] cannot call
/// GitHub; unit tests configure [release] or [error].
class FakeGithubReleaseClient implements GithubReleaseClient {
  /// [release] is returned when set; otherwise [error] is thrown (or a default).
  FakeGithubReleaseClient({this.release, this.error});

  /// Latest release to return.
  GithubRelease? release;

  /// Thrown instead of returning [release] when non-null.
  Object? error;

  /// How many times [fetchLatest] was called.
  int calls = 0;

  @override
  Future<GithubRelease> fetchLatest() async {
    calls++;
    if (error != null) throw error!;
    final value = release;
    if (value == null) {
      throw const GithubReleaseFetchException('fake: no release');
    }
    return value;
  }
}

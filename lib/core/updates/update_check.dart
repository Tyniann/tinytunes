import 'package:tinytunes/core/updates/app_semver.dart';
import 'package:tinytunes/core/updates/github_release.dart';

/// How often a scheduled (startup) check may hit GitHub.
const Duration updateCheckInterval = Duration(hours: 24);

/// Outcome of one update-check pass.
enum UpdateCheckOutcome {
  /// Scheduled check skipped because the interval has not elapsed.
  skippedInterval,

  /// Network or parse failure. Scheduled checks stay silent.
  failed,

  /// Not the official release-signed APK — GitHub is not contacted.
  skippedUnofficial,

  /// Latest tag is not newer than the installed version.
  current,

  /// Newer tag exists but the user already dismissed this tag.
  dismissed,

  /// Newer than installed and not dismissed (or a manual check).
  available,
}

/// Result of [UpdateCheck] including the release when [outcome] is available.
class UpdateCheckResult {
  /// Creates a check result.
  const UpdateCheckResult(this.outcome, {this.release});

  /// What the UI should do.
  final UpdateCheckOutcome outcome;

  /// Latest release when [outcome] is [UpdateCheckOutcome.available].
  final GithubRelease? release;
}

/// Pure fetch/prompt policy for GitHub latest-release checks.
///
/// Purpose: Keep interval, dismiss, and semver rules out of Riverpod/HTTP so
/// tests pin behavior with literals. Manual checks ([force]) skip the interval
/// and ignore a previous dismiss of the same tag.
/// Usage Context: [UpdateCheckController] after reading prefs + [PackageInfo].
abstract final class UpdateCheck {
  /// Whether a GitHub fetch should run.
  static bool shouldFetch({
    required DateTime now,
    required DateTime? lastCheckedAt,
    required bool force,
    Duration interval = updateCheckInterval,
  }) {
    if (force) return true;
    if (lastCheckedAt == null) return true;
    return !now.isBefore(lastCheckedAt.add(interval));
  }

  /// Decides whether to prompt given [installedVersion] and a fetched [release].
  static UpdateCheckResult decidePrompt({
    required String installedVersion,
    required GithubRelease release,
    required String? dismissedNormalized,
    required bool force,
  }) {
    if (!AppSemver.isNewer(release.tagName, installedVersion)) {
      return const UpdateCheckResult(UpdateCheckOutcome.current);
    }
    final latest = AppSemver.normalize(release.tagName);
    if (!force &&
        latest != null &&
        dismissedNormalized != null &&
        latest == dismissedNormalized) {
      return const UpdateCheckResult(UpdateCheckOutcome.dismissed);
    }
    return UpdateCheckResult(UpdateCheckOutcome.available, release: release);
  }
}

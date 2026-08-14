import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/core/settings/package_info_provider.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/core/updates/github_release.dart';
import 'package:tinytunes/core/updates/github_release_client.dart';
import 'package:tinytunes/core/updates/installed_signing_hash.dart';
import 'package:tinytunes/core/updates/official_release.dart';
import 'package:tinytunes/core/updates/update_check.dart';
import 'package:tinytunes/core/updates/update_preferences.dart';

part 'update_providers.g.dart';

/// GitHub latest-release client. Tests override with a fake implementation.
@Riverpod(keepAlive: true)
GithubReleaseClient githubReleaseClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return HttpGithubReleaseClient(client);
}

/// Prefs wrapper for last-check time and dismissed tag.
@Riverpod(keepAlive: true)
UpdatePreferences updatePreferences(Ref ref) {
  return UpdatePreferences(ref.watch(sharedPreferencesProvider));
}

/// Installed APK signing hash. Tests override [isOfficialApkProvider] instead.
@Riverpod(keepAlive: true)
InstalledSigningHashSource installedSigningHashSource(Ref ref) {
  return AndroidInstalledSigningHashSource();
}

/// Whether this install is the official GitHub APK (package + release cert).
///
/// Purpose: Skip GitHub entirely for forks, debug builds, and unsigned hosts.
/// Usage Context: [UpdateCheckController] and About's Check for updates button.
@Riverpod(keepAlive: true)
Future<bool> isOfficialApk(Ref ref) async {
  final info = await ref.watch(packageInfoProvider.future);
  final hash = await ref.read(installedSigningHashSourceProvider).sha1Base64();
  return OfficialRelease.isOfficialApk(
    packageName: info.packageName,
    signatureSha1Base64: hash,
  );
}

/// Clock for interval math. Tests override with a frozen instant.
@Riverpod(keepAlive: true)
DateTime Function() updateClock(Ref ref) => DateTime.now;

/// Snapshot the binder and About dialog watch after a check.
@immutable
class UpdateCheckSnapshot {
  /// No prompt. [checking] is true while a GitHub request is in flight.
  const UpdateCheckSnapshot({this.checking = false, this.release});

  /// True while a check is in flight (About spinner).
  final bool checking;

  /// Latest newer release to prompt about, or `null`.
  final GithubRelease? release;
}

/// Runs scheduled and manual GitHub latest-release checks.
///
/// Purpose: Apply [UpdateCheck] policy with injected client, clock, prefs, and
/// [packageInfoProvider]. Failures never go to the message center.
/// Usage Context: [UpdateCheckBinder] on start; About manual check.
@Riverpod(keepAlive: true)
class UpdateCheckController extends _$UpdateCheckController {
  @override
  UpdateCheckSnapshot build() => const UpdateCheckSnapshot();

  /// Startup / interval check. Silent on failure, interval skip, or current.
  Future<UpdateCheckResult> checkScheduled() => _run(force: false);

  /// About-dialog check. Ignores interval and a previous dismiss of this tag.
  Future<UpdateCheckResult> checkNow() => _run(force: true);

  /// Remembers [tag] so scheduled checks skip it until a newer tag appears.
  Future<void> dismissTag(String tag) async {
    await ref.read(updatePreferencesProvider).writeDismissedTag(tag);
    state = const UpdateCheckSnapshot();
  }

  Future<UpdateCheckResult> _run({required bool force}) async {
    if (state.checking) {
      return const UpdateCheckResult(UpdateCheckOutcome.failed);
    }
    final official = await ref.read(isOfficialApkProvider.future);
    if (!official) {
      return const UpdateCheckResult(UpdateCheckOutcome.skippedUnofficial);
    }
    final prefs = ref.read(updatePreferencesProvider);
    final now = ref.read(updateClockProvider)();
    if (!UpdateCheck.shouldFetch(
      now: now,
      lastCheckedAt: prefs.readLastCheckedAt(),
      force: force,
    )) {
      return const UpdateCheckResult(UpdateCheckOutcome.skippedInterval);
    }

    state = const UpdateCheckSnapshot(checking: true);
    try {
      final info = await ref.read(packageInfoProvider.future);
      final release = await ref.read(githubReleaseClientProvider).fetchLatest();
      await prefs.writeLastCheckedAt(now);
      final result = UpdateCheck.decidePrompt(
        installedVersion: info.version,
        release: release,
        dismissedNormalized: prefs.readDismissedVersion(),
        force: force,
      );
      state = result.outcome == UpdateCheckOutcome.available && !force
          ? UpdateCheckSnapshot(release: result.release)
          : const UpdateCheckSnapshot();
      return result;
    } catch (e) {
      debugPrint('Update check failed: $e');
      state = const UpdateCheckSnapshot();
      return const UpdateCheckResult(UpdateCheckOutcome.failed);
    }
  }
}

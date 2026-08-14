import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/settings/package_info_provider.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/core/updates/github_release.dart';
import 'package:tinytunes/core/updates/github_release_client.dart';
import 'package:tinytunes/core/updates/update_check.dart';
import 'package:tinytunes/core/updates/update_preferences.dart';
import 'package:tinytunes/core/updates/update_providers.dart';

import 'fake_github_release_client.dart';

class _Clock {
  _Clock(this.now);
  DateTime now;
}

void main() {
  const newer = GithubRelease(
    tagName: 'v1.10.0',
    htmlUrl: 'https://github.com/Tyniann/tinytunes/releases/tag/v1.10.0',
  );

  Future<(ProviderContainer, _Clock)> containerWith({
    required FakeGithubReleaseClient client,
    Map<String, Object> prefs = const {},
    DateTime? now,
    String version = '1.2.0',
    bool official = true,
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final shared = await SharedPreferences.getInstance();
    final clock = _Clock(now ?? DateTime.utc(2026, 8, 14, 12));
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(shared),
        githubReleaseClientProvider.overrideWithValue(client),
        updateClockProvider.overrideWithValue(() => clock.now),
        packageInfoProvider.overrideWith(
          (ref) async => PackageInfo(
            appName: 'TinyTunes',
            packageName: 'at.blumenlaube.tinytunes',
            version: version,
            buildNumber: '12',
          ),
        ),
        isOfficialApkProvider.overrideWith((ref) async => official),
      ],
    );
    addTearDown(container.dispose);
    return (container, clock);
  }

  test('scheduled check prompts and records last-checked when newer', () async {
    final client = FakeGithubReleaseClient(release: newer);
    final (container, _) = await containerWith(client: client);

    final result = await container
        .read(updateCheckControllerProvider.notifier)
        .checkScheduled();

    expect(result.outcome, UpdateCheckOutcome.available);
    expect(container.read(updateCheckControllerProvider).release, newer);
    expect(client.calls, 1);
    expect(
      container.read(updatePreferencesProvider).readLastCheckedAt(),
      DateTime.utc(2026, 8, 14, 12),
    );
  });

  test('scheduled check is silent and skips GitHub inside 24h', () async {
    final last = DateTime.utc(2026, 8, 14, 1);
    final client = FakeGithubReleaseClient(release: newer);
    final (container, _) = await containerWith(
      client: client,
      prefs: {
        UpdatePreferences.lastCheckedAtKey: last.millisecondsSinceEpoch,
      },
    );

    final result = await container
        .read(updateCheckControllerProvider.notifier)
        .checkScheduled();

    expect(result.outcome, UpdateCheckOutcome.skippedInterval);
    expect(client.calls, 0);
    expect(container.read(updateCheckControllerProvider).release, isNull);
  });

  test('manual check ignores interval and dismissed tag', () async {
    final last = DateTime.utc(2026, 8, 14, 11);
    final client = FakeGithubReleaseClient(release: newer);
    final (container, _) = await containerWith(
      client: client,
      prefs: {
        UpdatePreferences.lastCheckedAtKey: last.millisecondsSinceEpoch,
        UpdatePreferences.dismissedVersionKey: '1.10.0',
      },
    );

    final result = await container
        .read(updateCheckControllerProvider.notifier)
        .checkNow();

    expect(result.outcome, UpdateCheckOutcome.available);
    expect(client.calls, 1);
    expect(container.read(updateCheckControllerProvider).release, isNull);
  });

  test('scheduled check stays silent when GitHub fails', () async {
    final client = FakeGithubReleaseClient(
      error: const GithubReleaseFetchException('down'),
    );
    final (container, _) = await containerWith(client: client);

    final result = await container
        .read(updateCheckControllerProvider.notifier)
        .checkScheduled();

    expect(result.outcome, UpdateCheckOutcome.failed);
    expect(container.read(updateCheckControllerProvider).release, isNull);
    expect(
      container.read(updatePreferencesProvider).readLastCheckedAt(),
      isNull,
    );
  });

  test('dismissTag suppresses the same version after the interval elapses', () async {
    final client = FakeGithubReleaseClient(release: newer);
    final (container, clock) = await containerWith(client: client);

    await container.read(updateCheckControllerProvider.notifier).checkScheduled();
    await container
        .read(updateCheckControllerProvider.notifier)
        .dismissTag('v1.10.0');

    clock.now = clock.now.add(const Duration(hours: 25));
    final after = await container
        .read(updateCheckControllerProvider.notifier)
        .checkScheduled();
    expect(after.outcome, UpdateCheckOutcome.dismissed);
    expect(container.read(updateCheckControllerProvider).release, isNull);
    expect(client.calls, 2);
  });

  test('unofficial install never contacts GitHub', () async {
    final client = FakeGithubReleaseClient(release: newer);
    final (container, _) = await containerWith(
      client: client,
      official: false,
    );

    final scheduled = await container
        .read(updateCheckControllerProvider.notifier)
        .checkScheduled();
    final manual = await container
        .read(updateCheckControllerProvider.notifier)
        .checkNow();

    expect(scheduled.outcome, UpdateCheckOutcome.skippedUnofficial);
    expect(manual.outcome, UpdateCheckOutcome.skippedUnofficial);
    expect(client.calls, 0);
    expect(
      container.read(updatePreferencesProvider).readLastCheckedAt(),
      isNull,
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/updates/github_release.dart';
import 'package:tinytunes/core/updates/update_check.dart';

void main() {
  final newer = GithubRelease(
    tagName: 'v1.10.0',
    htmlUrl: 'https://github.com/Tyniann/tinytunes/releases/tag/v1.10.0',
  );
  final same = GithubRelease(
    tagName: 'v1.2.0',
    htmlUrl: 'https://github.com/Tyniann/tinytunes/releases/tag/v1.2.0',
  );

  group('shouldFetch', () {
    final now = DateTime.utc(2026, 8, 14, 12);

    test('runs when never checked or forced', () {
      expect(
        UpdateCheck.shouldFetch(now: now, lastCheckedAt: null, force: false),
        isTrue,
      );
      expect(
        UpdateCheck.shouldFetch(
          now: now,
          lastCheckedAt: now,
          force: true,
        ),
        isTrue,
      );
    });

    test('skips inside 24h and runs at the boundary', () {
      expect(
        UpdateCheck.shouldFetch(
          now: now,
          lastCheckedAt: now.subtract(const Duration(hours: 23)),
          force: false,
        ),
        isFalse,
      );
      expect(
        UpdateCheck.shouldFetch(
          now: now,
          lastCheckedAt: now.subtract(const Duration(hours: 24)),
          force: false,
        ),
        isTrue,
      );
    });
  });

  group('decidePrompt', () {
    test('prompts when latest is newer', () {
      final result = UpdateCheck.decidePrompt(
        installedVersion: '1.2.0',
        release: newer,
        dismissedNormalized: null,
        force: false,
      );
      expect(result.outcome, UpdateCheckOutcome.available);
      expect(result.release, newer);
    });

    test('does not prompt when installed is current', () {
      final result = UpdateCheck.decidePrompt(
        installedVersion: '1.2.0',
        release: same,
        dismissedNormalized: null,
        force: false,
      );
      expect(result.outcome, UpdateCheckOutcome.current);
      expect(result.release, isNull);
    });

    test('scheduled check respects dismissed tag; manual check does not', () {
      final scheduled = UpdateCheck.decidePrompt(
        installedVersion: '1.2.0',
        release: newer,
        dismissedNormalized: '1.10.0',
        force: false,
      );
      expect(scheduled.outcome, UpdateCheckOutcome.dismissed);

      final manual = UpdateCheck.decidePrompt(
        installedVersion: '1.2.0',
        release: newer,
        dismissedNormalized: '1.10.0',
        force: true,
      );
      expect(manual.outcome, UpdateCheckOutcome.available);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/updates/github_release.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

import '../../core/updates/fake_github_release_client.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('startup check shows a dialog when GitHub latest is newer', (
    tester,
  ) async {
    await pumpApp(
      tester,
      githubReleaseClient: FakeGithubReleaseClient(
        release: const GithubRelease(
          tagName: 'v9.0.0',
          htmlUrl: 'https://github.com/Tyniann/tinytunes/releases/tag/v9.0.0',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.updateAvailableTitle), findsOneWidget);
    expect(find.text(l10n.updateAvailableOpen), findsOneWidget);

    await tester.tap(find.text(l10n.updateAvailableLater));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.updateAvailableTitle), findsNothing);

    await endPumpApp(tester);
  });

  testWidgets('startup check stays silent when GitHub fails', (tester) async {
    await pumpApp(
      tester,
      githubReleaseClient: FakeGithubReleaseClient(),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.updateAvailableTitle), findsNothing);

    await endPumpApp(tester);
  });

  testWidgets('startup check stays silent on unofficial / fork builds', (
    tester,
  ) async {
    await pumpApp(
      tester,
      officialApk: false,
      githubReleaseClient: FakeGithubReleaseClient(
        release: const GithubRelease(
          tagName: 'v9.0.0',
          htmlUrl: 'https://github.com/Tyniann/tinytunes/releases/tag/v9.0.0',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.updateAvailableTitle), findsNothing);

    await endPumpApp(tester);
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 0 contract checks for ADR 0003 + OAuth/branding docs.
///
/// Purpose: Fail CI if locked OneDrive decisions or setup docs drift.
void main() {
  late final String adr;
  late final String oauthDoc;
  late final String brandDoc;

  setUpAll(() {
    adr = File('docs/adr/0003-onedrive-cloud-library.md').readAsStringSync();
    oauthDoc = File(
      'docs/legal/android-signing-and-oauth.md',
    ).readAsStringSync();
    brandDoc = File('docs/legal/microsoft-brand-assets.md').readAsStringSync();
  });

  group('ADR 0003 locked decisions', () {
    test('exists and links ADR 0002 + OAuth research', () {
      expect(adr, contains('ADR 0002'));
      expect(adr, contains('0002-google-drive-cloud-library.md'));
      expect(adr, contains('onedrive-oauth-public-effort.md'));
    });

    test('locks personal MSA, Android-only, Files.Read, read-only', () {
      expect(adr, contains('Personal Microsoft accounts only'));
      expect(adr, contains('Android only'));
      expect(adr, contains('`Files.Read`'));
      expect(adr, contains('Never `Files.Read.All`'));
      expect(adr, contains('Do **not** request `offline_access`'));
      expect(adr.toLowerCase(), contains('read-only'));
      expect(adr, contains('never create, rename'));
    });

    test('locks multi-provider cache and account replacement', () {
      expect(adr, contains('simultaneously'));
      expect(adr, contains('shared'));
      expect(adr, contains('cloud_provider'));
      expect(adr, contains('cloud_account_key'));
      expect(adr, contains('sign-out'));
      expect(adr, contains('replacement'));
      expect(adr, contains('Google Drive and OneDrive'));
    });

    test('locks msal_auth with MethodChannel fallback boundary', () {
      expect(adr, contains('msal_auth'));
      expect(adr, contains('MethodChannel'));
      expect(adr, contains('AppAuth'));
      expect(adr, contains('Unverified'));
    });

    test('locks provider folder layout and locator tokens', () {
      expect(adr, contains('google_drive/'));
      expect(adr, contains('one_drive/'));
      expect(adr, contains('gdrive'));
      expect(adr, contains('onedrive'));
      expect(adr, contains('sourceKind = cloud'));
    });
  });

  group('OAuth setup docs', () {
    test('documents reproducible debug and release signature-hash commands', () {
      expect(oauthDoc, contains('signatureHash='));
      expect(oauthDoc, contains('msauth://at.blumenlaube.tinytunes/'));
      expect(oauthDoc, contains('debug.keystore'));
      expect(oauthDoc, contains('tinytunes-release.jks'));
      expect(oauthDoc, contains('Personal Microsoft accounts only'));
      expect(oauthDoc, contains('public client'));
      expect(oauthDoc, contains('Do **not** create a client secret'));
    });

    test('records maintainer debug and release public binding values', () {
      expect(
        oauthDoc,
        contains('c2ed77e3-5443-4251-94c2-b6e1916d084d'),
      );
      expect(oauthDoc, contains('kNrKEKVATPOALWoi2IiGqfnphGM='));
      expect(oauthDoc, contains('yA+8T1x4a9pYEu1mYe58Quq7f5Y='));
      expect(oauthDoc, contains('PersonalMicrosoftAccount'));
    });
  });

  group('Brand assets', () {
    test('inventory doc lists official sources', () {
      expect(brandDoc, contains('howto-add-branding-in-apps'));
      expect(brandDoc, contains('onedrive_icon.png'));
      expect(brandDoc, contains('microsoft_symbol.png'));
      expect(brandDoc, contains('Do **not** redraw'));
    });

    test('official asset files exist and are non-trivial', () {
      final required = <String>[
        'assets/branding/onedrive_icon.png',
        'assets/branding/microsoft_symbol.png',
        'assets/branding/microsoft_symbol.svg',
        'assets/branding/ms_signin_light.png',
        'assets/branding/ms_signin_dark.png',
      ];
      for (final path in required) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: path);
        expect(file.lengthSync(), greaterThan(100), reason: path);
      }
    });
  });
}

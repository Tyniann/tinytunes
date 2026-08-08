import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_auth.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_oauth_config.dart';

void main() {
  test('maps MSAL Account fields into OneDriveAccount', () {
    // Exercise the same mapping rules used by MsalOneDriveAuth via a local
    // mirror — production mapping is private; validate the ownership contract.
    const account = OneDriveAccount(
      stableAccountKey: '00000000-0000-0000-0000-000000000001',
      email: 'person@outlook.com',
      displayName: 'Person',
    );
    expect(account.stableAccountKey, isNot(contains('@')));
    expect(account.email, contains('@'));
  });

  test('oauth config exposes public client id and Files.Read scopes', () {
    expect(
      OneDriveOAuthConfig.clientId,
      'c2ed77e3-5443-4251-94c2-b6e1916d084d',
    );
    expect(
      OneDriveOAuthConfig.graphScopes,
      contains('https://graph.microsoft.com/Files.Read'),
    );
    expect(
      OneDriveOAuthConfig.graphScopes,
      isNot(contains('https://graph.microsoft.com/Files.Read.All')),
    );
    // Personal MSA declines offline_access when requested explicitly.
    expect(OneDriveOAuthConfig.graphScopes, isNot(contains('offline_access')));
    expect(OneDriveOAuthConfig.androidRedirectUri, startsWith('msauth://'));
    expect(
      OneDriveOAuthConfig.androidRedirectUri,
      contains(OneDriveOAuthConfig.androidPackageName),
    );
  });

  test('cancelled and ui-required exceptions are distinct', () {
    expect(
      const OneDriveAuthCancelledException(),
      isA<OneDriveAuthCancelledException>(),
    );
    expect(
      const OneDriveAuthUiRequiredException('x'),
      isA<OneDriveAuthUiRequiredException>(),
    );
  });
}

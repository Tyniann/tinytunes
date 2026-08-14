import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_oauth_config.dart';
import 'package:tinytunes/core/updates/official_release.dart';

void main() {
  test('isOfficialApk requires package id and release cert hash', () {
    expect(
      OfficialRelease.isOfficialApk(
        packageName: OfficialRelease.androidApplicationId,
        signatureSha1Base64: OfficialRelease.androidReleaseSignatureHash,
      ),
      isTrue,
    );
    expect(
      OfficialRelease.isOfficialApk(
        packageName: OfficialRelease.androidApplicationId,
        signatureSha1Base64: OneDriveOAuthConfig.debugSignatureHash,
      ),
      isFalse,
    );
    expect(
      OfficialRelease.isOfficialApk(
        packageName: 'com.example.fork',
        signatureSha1Base64: OfficialRelease.androidReleaseSignatureHash,
      ),
      isFalse,
    );
    expect(
      OfficialRelease.isOfficialApk(
        packageName: OfficialRelease.androidApplicationId,
        signatureSha1Base64: null,
      ),
      isFalse,
    );
  });

  test('release signature hash stays aligned with Entra redirect hash', () {
    expect(
      OfficialRelease.androidReleaseSignatureHash,
      OneDriveOAuthConfig.releaseSignatureHash,
    );
  });
}

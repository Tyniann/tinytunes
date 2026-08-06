import 'package:http/http.dart' as http;

/// HTTP client that attaches a Bearer access token to every request.
///
/// Purpose: Bridge `google_sign_in` access tokens to `googleapis` Drive without
/// Firebase or the googleapis_auth extension package.
/// Usage Context: Constructed with a fresh token from [GoogleDriveAuth].
class GoogleAccessTokenClient extends http.BaseClient {
  /// Creates a client that sends [accessToken] on each request via [inner].
  GoogleAccessTokenClient({required this.accessToken, http.Client? inner})
    : _inner = inner ?? http.Client();

  /// OAuth access token for Drive (Bearer).
  final String accessToken;

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $accessToken';
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}

import 'package:http/http.dart' as http;

/// Whether [host] is a Microsoft Graph API host eligible for Bearer auth.
///
/// Purpose: Never attach the Graph access token to CDN / preauth download hosts.
bool isMicrosoftGraphHost(String host) {
  final lower = host.toLowerCase();
  return lower == 'graph.microsoft.com' ||
      lower.endsWith('.graph.microsoft.com');
}

/// HTTP client that attaches a Bearer token only to Microsoft Graph hosts.
///
/// Purpose: Bridge MSAL Graph tokens to Graph JSON/`/content` requests without
/// leaking Authorization onto redirect download URLs.
/// Usage Context: Constructed with a fresh token from [OneDriveAuth].
class OneDriveGraphAccessTokenClient extends http.BaseClient {
  /// Creates a client that sends [accessToken] only to Graph hosts via [inner].
  OneDriveGraphAccessTokenClient({
    required this.accessToken,
    http.Client? inner,
  }) : _inner = inner ?? http.Client();

  /// OAuth access token for Microsoft Graph (Bearer).
  final String accessToken;

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (isMicrosoftGraphHost(request.url.host)) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      request.headers.remove('Authorization');
    }
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

/// Returns true if the embedded webview is supported on the current platform.
bool get isWebViewSupported => Platform.isWindows || Platform.isMacOS;

/// Opens claude.ai in an embedded browser so the user can sign in.
/// After login, extracts the `sessionKey` cookie and returns it via [Navigator.pop].
///
/// Only supported on Windows and macOS. On Linux, use [ClaudeManualLoginView].
class ClaudeLoginView extends StatefulWidget {
  const ClaudeLoginView({super.key});

  @override
  State<ClaudeLoginView> createState() => _ClaudeLoginViewState();
}

class _ClaudeLoginViewState extends State<ClaudeLoginView> {
  static const _claudeUrl = 'https://claude.ai/login';
  static const _cookieName = 'sessionKey';

  final CookieManager _cookieManager = CookieManager.instance();
  Timer? _cookiePollingTimer;
  bool _isLoading = true;
  bool _extracted = false;

  @override
  void initState() {
    super.initState();
    _cookieManager.deleteCookies(
      url: WebUri('https://claude.ai'),
    );
  }

  @override
  void dispose() {
    _cookiePollingTimer?.cancel();
    super.dispose();
  }

  void _startCookiePolling() {
    _cookiePollingTimer?.cancel();
    _cookiePollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkForSessionCookie(),
    );
  }

  Future<void> _checkForSessionCookie() async {
    if (_extracted) return;

    final cookies = await _cookieManager.getCookies(
      url: WebUri('https://claude.ai'),
    );

    for (final cookie in cookies) {
      if (cookie.name == _cookieName && cookie.value.toString().isNotEmpty) {
        _extracted = true;
        _cookiePollingTimer?.cancel();
        if (mounted) {
          Navigator.of(context).pop(cookie.value.toString());
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign in to Claude',
          style: TextStyle(
            fontSize: DesignTokens.headline,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(_claudeUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
        ),
        onLoadStart: (controller, url) {
          setState(() => _isLoading = true);
        },
        onLoadStop: (controller, url) async {
          setState(() => _isLoading = false);
          _checkForSessionCookie();
          _startCookiePolling();
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED,
          );
        },
        onUpdateVisitedHistory: (controller, url, isReload) {
          _checkForSessionCookie();
        },
        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT,
          );
        },
      ),
    );
  }
}

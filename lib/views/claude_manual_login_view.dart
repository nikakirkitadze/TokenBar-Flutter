import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

/// Fallback login view for Linux where embedded webview is not available.
/// Shows instructions and a text field to paste the session cookie manually.
class ClaudeManualLoginView extends StatefulWidget {
  const ClaudeManualLoginView({super.key});

  @override
  State<ClaudeManualLoginView> createState() => _ClaudeManualLoginViewState();
}

class _ClaudeManualLoginViewState extends State<ClaudeManualLoginView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.space5),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to get your session cookie:',
                    style: TextStyle(
                      fontSize: DesignTokens.body,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space3),
                  _step('1. Open claude.ai in your browser and sign in',
                      textSecondary),
                  _step(
                      '2. Open Developer Tools (F12) \u2192 Application \u2192 Cookies',
                      textSecondary),
                  _step(
                      '3. Find the "sessionKey" cookie for claude.ai',
                      textSecondary),
                  _step('4. Copy the value and paste it below', textSecondary),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space5),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Session Cookie',
                hintText: 'Paste sessionKey cookie value',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
              obscureText: true,
              maxLines: 1,
            ),
            const SizedBox(height: DesignTokens.space5),
            ElevatedButton(
              onPressed: () {
                final value = _controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.of(context).pop(value);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Save & Connect'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontSize: DesignTokens.footnote, color: color),
      ),
    );
  }
}

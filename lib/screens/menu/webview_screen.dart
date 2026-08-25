import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../widgets/game_button.dart';

/// Generic in-app browser used for the Privacy Policy and Support pages.
class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({super.key, required this.title, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _loading = true;
            _error = false;
          }),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (_) => setState(() {
            _loading = false;
            _error = true;
          }),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GameIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 12),
                  Expanded(child: Text(widget.title, style: AppText.heading(size: 22))),
                  GameIconButton(icon: Icons.refresh_rounded, onPressed: () => _controller.reload()),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: WebViewWidget(controller: _controller),
                  ),
                  if (_loading)
                    const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                  if (_error)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 48),
                          const SizedBox(height: 12),
                          Text('Could not load the page.', style: AppText.body_(size: 15)),
                          const SizedBox(height: 12),
                          GameButton(label: 'Retry', width: 140, height: 44, onPressed: () => _controller.reload()),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

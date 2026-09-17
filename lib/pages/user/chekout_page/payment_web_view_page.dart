import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String checkoutUrl;
  const PaymentWebViewPage({super.key, required this.checkoutUrl});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Paystack's "Cancel Payment" button calls window.close(), since
      // their checkout page is normally opened as a popup. A WebView has
      // no window to close, so that call was silently doing nothing.
      // This channel + override lets us catch it and pop the page instead.
      ..addJavaScriptChannel(
        'PaystackCancel',
        onMessageReceived: (message) {
          if (!mounted) return;
          Navigator.pop(context);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            // Don't guess what Paystack's Cancel Payment button's own
            // handler does (window.close() didn't fix it) — instead watch
            // for that button directly and fire our channel on click.
            // MutationObserver covers it even if Paystack renders the
            // checkout UI asynchronously after the page "finishes" loading.
            _controller.runJavaScript('''
              (function() {
                function attach(el) {
                  if (el.dataset.flutterCancelBound) return;
                  el.dataset.flutterCancelBound = '1';
                  el.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopImmediatePropagation();
                    PaystackCancel.postMessage('cancel');
                  }, true);
                }
                function scan() {
                  document.querySelectorAll('button, a, div, span').forEach(function(el) {
                    var text = (el.textContent || '').trim();
                    if (text === 'Cancel Payment') attach(el);
                  });
                }
                scan();
                new MutationObserver(scan).observe(document.body, {childList: true, subtree: true});
              })();
            ''');
          },
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress / 100);
          },
          onNavigationRequest: (request) {
            final url = request.url;
            print('WEBVIEW NAVIGATING TO: $url');

            if (url.contains('payment-complete')) {
              final uri = Uri.parse(url);
              final reference = uri.queryParameters['reference'];

              Navigator.pop(
                context,
                reference,
              ); // send reference back to checkout_page
              return NavigationDecision
                  .prevent; // stop the WebView from actually loading it
            }

            return NavigationDecision
                .navigate; // let all other navigation happen normally
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        value: _progress > 0 && _progress < 1
                            ? _progress
                            : null,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Loading secure payment page...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            // This is YOUR callback URL — the one you set (or Paystack's default).
            // Adjust this check to match whatever callback_url you use.
            if (url.contains('myapp://payment-complete')) {
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
      body: WebViewWidget(controller: _controller),
    );
  }
}

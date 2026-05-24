import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String checkoutUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkRedirection(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkRedirection(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkRedirection(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _checkRedirection(String url) {
    debugPrint("[DEBUG - WebView] Navegando a: $url");
    if (url.contains("success=true")) {
      debugPrint("[DEBUG - WebView] Pago Exitoso detectado!");
      if (mounted) {
        Navigator.of(context).pop(true); // Retorna true si es exitoso
      }
    } else if (url.contains("cancel=true")) {
      debugPrint("[DEBUG - WebView] Pago Cancelado detectado!");
      if (mounted) {
        Navigator.of(context).pop(false); // Retorna false si es cancelado
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago Seguro con Stripe'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

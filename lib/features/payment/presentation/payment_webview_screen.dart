import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/booking_strings.dart';
import '../domain/entities/payment_outcome.dart';
import '../domain/usecases/payment_usecases.dart';

/// Cổng VNPay trong WebView. Khi VNPay chuyển về `VNPAY_RETURN_URL`, màn này
/// chặn lại và gửi nguyên query cho BE (kèm token của khách) để kiểm chữ ký.
@RoutePage()
class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({super.key, required this.paymentUrl});

  final String paymentUrl;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _verifying = false;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && ConfirmVnPayReturn.isReturnUrl(uri)) {
              _handleReturn(uri);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: _checkUrl,
          onUrlChange: (change) => _checkUrl(change.url),
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkUrl(String? url) {
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri != null && ConfirmVnPayReturn.isReturnUrl(uri)) _handleReturn(uri);
  }

  Future<void> _handleReturn(Uri uri) async {
    if (_handled) return;
    _handled = true;
    setState(() => _verifying = true);
    PaymentOutcome outcome;
    try {
      outcome = await getIt<ConfirmVnPayReturn>()(uri);
    } catch (error) {
      if (mounted) AppToast.error(context, AppException.from(error).message);
      outcome = PaymentOutcome.invalid;
    }
    if (mounted) await context.router.maybePop(outcome);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: BookingStrings.paymentTitle,
      leading: IconButton(
        tooltip: AppStrings.close,
        icon: const Icon(Icons.close_rounded),
        onPressed: () => context.router.maybePop(),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_progress < 100)
            LinearProgressIndicator(value: _progress / 100, minHeight: 2),
          if (_verifying)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0xEBFFFFFF),
                child: AppLoadingView(message: BookingStrings.paymentVerifying),
              ),
            ),
        ],
      ),
      backgroundColor: AppColors.surface,
    );
  }
}

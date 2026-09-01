import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/pages/user/order_history_page.dart';

/// Simple snapshot of a purchased line item, captured *before* payment
/// starts (cart items get deleted server-side once the order is fulfilled,
/// so we can't re-read them live from CartProvider after success).
class OrderLineItem {
  final String name;
  final int quantity;
  final double price;

  const OrderLineItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

enum _OrderStatus { verifying, success, pending, declined }

/// Shown right after the payment WebView redirects back into the app.
/// Confirms the transaction with the backend and renders a state that
/// matches the real outcome: success | pending | declined.
class OrderStatusPage extends StatefulWidget {
  final String reference;
  final List<OrderLineItem> items;
  final double expectedTotal;

  const OrderStatusPage({
    super.key,
    required this.reference,
    required this.items,
    required this.expectedTotal,
  });

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  _OrderStatus _status = _OrderStatus.verifying;
  String? _orderId;
  double? _amountPaid;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    setState(() => _status = _OrderStatus.verifying);
    try {
      final verify = FirebaseFunctions.instance.httpsCallable(
        'verifyTransaction',
      );
      final result = await verify.call({'reference': widget.reference});
      final data = Map<String, dynamic>.from(result.data as Map);

      if (!mounted) return;

      if (data['verified'] == true) {
        setState(() {
          _status = _OrderStatus.success;
          _orderId = data['orderId'] as String?;
          _amountPaid = (data['amount'] as num?)?.toDouble();
        });
      } else {
        final paystackStatus = data['status'] as String?;
        setState(() {
          _status = paystackStatus == 'pending'
              ? _OrderStatus.pending
              : _OrderStatus.declined;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = _OrderStatus.declined);
    }
  }

  void _backToShopping() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _backToCheckout() {
    Navigator.of(context).pop();
  }

  void _viewOrder() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Don't let the user swipe/back out of an unresolved verification —
      // it's a quick call, but we don't want a half-confirmed state left
      // hanging behind them.
      canPop: _status != _OrderStatus.verifying,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_status) {
      case _OrderStatus.verifying:
        return _VerifyingView();
      case _OrderStatus.success:
        return _SuccessView(
          orderId: _orderId ?? widget.reference,
          amountPaid: _amountPaid ?? widget.expectedTotal,
          items: widget.items,
          onContinueShopping: _backToShopping,
          onViewOrder: _viewOrder,
        );
      case _OrderStatus.pending:
        return _PendingView(
          onCheckAgain: _verify,
          onContinueShopping: _backToShopping,
        );
      case _OrderStatus.declined:
        return _DeclinedView(
          onTryAgain: _backToCheckout,
          onContinueShopping: _backToShopping,
        );
    }
  }
}

class _VerifyingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const CircularProgressIndicator(strokeWidth: 3),
        const SizedBox(height: 24),
        Text(
          'Confirming your payment...',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'This will only take a moment.',
          style: GoogleFonts.dmSans(color: Colors.grey),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String orderId;
  final double amountPaid;
  final List<OrderLineItem> items;
  final VoidCallback onContinueShopping;
  final VoidCallback onViewOrder;

  const _SuccessView({
    required this.orderId,
    required this.amountPaid,
    required this.items,
    required this.onContinueShopping,
    required this.onViewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 50),
            )
            .animate()
            .scale(
              duration: 400.ms,
              curve: Curves.elasticOut,
              begin: const Offset(0.4, 0.4),
              end: const Offset(1, 1),
            )
            .fadeIn(duration: 250.ms),
        const SizedBox(height: 24),
        Text(
          'Payment Successful!',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 8),
        Text(
          'Your order is confirmed and on its way 🎉',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _receiptRow(
                'Order ID',
                '#${orderId.substring(0, orderId.length < 10 ? orderId.length : 10)}',
              ),
              const SizedBox(height: 6),
              _receiptRow('Amount Paid', '₦${amountPaid.toStringAsFixed(0)}'),
              if (items.isNotEmpty) ...[
                const Divider(height: 24),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.name} × ${item.quantity}',
                            style: GoogleFonts.dmSans(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₦${(item.price * item.quantity).toStringAsFixed(0)}',
                          style: GoogleFonts.dmSans(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onViewOrder,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('View Order'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onContinueShopping,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Continue Shopping'),
          ),
        ),
      ],
    );
  }

  Widget _receiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 13),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}

class _PendingView extends StatelessWidget {
  final VoidCallback onCheckAgain;
  final VoidCallback onContinueShopping;

  const _PendingView({
    required this.onCheckAgain,
    required this.onContinueShopping,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.access_time_rounded,
            color: Colors.white,
            size: 46,
          ),
        ).animate().fadeIn(duration: 300.ms).scale(),
        const SizedBox(height: 24),
        Text(
          'Payment Pending',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Your bank is still confirming this payment. This can take a few minutes — we\'ll update your order automatically.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onCheckAgain,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Check Again'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onContinueShopping,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Continue Shopping'),
          ),
        ),
      ],
    );
  }
}

class _DeclinedView extends StatelessWidget {
  final VoidCallback onTryAgain;
  final VoidCallback onContinueShopping;

  const _DeclinedView({
    required this.onTryAgain,
    required this.onContinueShopping,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 50),
        ).animate().shake(duration: 400.ms).fadeIn(duration: 200.ms),
        const SizedBox(height: 24),
        Text(
          'Payment Declined',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Your payment could not be completed. No charge was made — you can try again.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTryAgain,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onContinueShopping,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Continue Shopping'),
          ),
        ),
      ],
    );
  }
}

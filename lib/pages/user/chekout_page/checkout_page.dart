import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/component/my_button.dart';
import 'package:morden_ecommerce_app/models/address_model.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/order_status_page.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/payment_web_view_page.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/Shipping_method.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/address_widget.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/order_summary.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/payment_method.dart';
import 'package:morden_ecommerce_app/providers/cart_provider.dart';
import 'package:morden_ecommerce_app/providers/product_provider.dart';
import 'package:morden_ecommerce_app/services/shop/shipping_service.dart';
import 'package:morden_ecommerce_app/util/formatters.dart';

import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Method? _selectedShippingMethod;
  AddressModel? _selectedAddress;
  PaymentChannel? _selectedPayment;
  final ValueNotifier<double?> _shippingCost = ValueNotifier(null);
  final ValueNotifier<bool> _loadingShipping = ValueNotifier(false);
  final ValueNotifier<String?> _shippingError = ValueNotifier(null);
  String? _lastCalculatedKey;
  bool _isProcessing = false;

  // Created once instead of inline in build() — otherwise every setState()
  // (picking an address, shipping method, or payment method) would call
  // .snapshots() again, handing StreamBuilder a brand-new Stream instance
  // and making it drop back to ConnectionState.waiting, which flashes the
  // loading spinner and looks like the whole page reloaded.
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream =
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

  // Built once and reused (same List instance) across every rebuild.
  // flutter_animate's Animate widget compares the effects list by
  // reference; chaining .animate().fadeIn().moveY() fresh inside build()
  // creates a new list every time, which the widget reads as "the
  // effects changed" and restarts the intro fade/slide from the top.
  // That's what caused the form to visibly jump/move on every tap of
  // address, shipping, or payment — it was replaying its entrance
  // animation on every single setState.
  static final List<Effect> _introEffects = [
    FadeEffect(
      delay: 200.ms,
      duration: 600.ms,
      curve: Curves.fastEaseInToSlowEaseOut,
    ),
    const MoveEffect(begin: Offset(0, 100)),
  ];

  @override
  void dispose() {
    _shippingCost.dispose();
    _loadingShipping.dispose();
    _shippingError.dispose();
    super.dispose();
  }

  Future<void> _maybeCalculateShipping() async {
    if (_selectedAddress == null || _selectedShippingMethod == null) {
      return;
    }

    final destination = _selectedAddress!.fullAddress;
    if (destination.isEmpty) return;

    final isExpress = _selectedShippingMethod == Method.express;
    final key = '$destination|$isExpress';
    if (key == _lastCalculatedKey) return;
    _lastCalculatedKey = key;

    _loadingShipping.value = true;
    _shippingError.value = null;

    try {
      final cost = await ShippingService.calculateShippingCost(
        destinationAddress: destination,
        isExpress: isExpress,
      );
      if (!mounted) return;
      _shippingCost.value = cost;
      _loadingShipping.value = false;
    } catch (e) {
      if (!mounted) return;
      _shippingError.value = 'Could not calculate shipping';
      _loadingShipping.value = false;
    }
  }

  Future<void> _startPayment({
    required List<OrderLineItem> items,
    required double total,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'initializeTransaction',
    );

    // Paystack's own channel names — restricting to the one the customer
    // picked skips the "choose how to pay" step on their hosted page,
    // rather than showing every channel every time.
    final channels = switch (_selectedPayment) {
      PaymentChannel.card => ['card'],
      PaymentChannel.bankTransfer => ['bank_transfer'],
      null => null,
    };

    final result = await callable.call({
      'shippingCost': _shippingCost.value ?? 0,
      'email': FirebaseAuth.instance.currentUser!.email,
      'address': _selectedAddress?.toMap(),
      'channels': channels,
    });

    if (!mounted) return;

    final paystackReference = result.data['reference'] as String?;

    final callbackReference = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PaymentWebViewPage(checkoutUrl: result.data['authorizationUrl']),
      ),
    );

    // Closing the WebView is not a payment outcome — Paystack may still
    // confirm a charge. Always verify with the initialize reference.
    final reference = callbackReference ?? paystackReference;
    if (reference == null || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderStatusPage(
          reference: reference,
          items: items,
          expectedTotal: total,
        ),
      ),
    );
  }

  void _showPriceDetails({
    required double subtotal,
    required double vat,
    required double total,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PriceDetailsSheet(
        subtotal: subtotal,
        vat: vat,
        total: total,
        shippingCost: _shippingCost,
        loadingShipping: _loadingShipping,
        shippingError: _shippingError,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();

    final subtotalValue = cart.getCartTotal(productProvider.products);
    final shipping = _shippingCost.value ?? 0;
    final vatableAmount = subtotalValue + shipping;
    final vat = vatableAmount * 0.075;
    final total = subtotalValue + shipping + vat;

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          StreamBuilder(
            stream: _userStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('user data not found'));
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          AddressWidget(
                            selectedAddress: _selectedAddress,
                            onChanged: (address) {
                              setState(() => _selectedAddress = address);
                              _maybeCalculateShipping();
                            },
                          ),
                          //order summary
                          OrderSummary(),

                          //delivery method
                          ShippingMethod(
                            selectedShipping: _selectedShippingMethod,
                            onChanged: (method) {
                              setState(() => _selectedShippingMethod = method);
                              _maybeCalculateShipping();
                            },
                          ),
                          //Promo code

                          //payment method
                          PaymentMethod(
                            selectedPayment: _selectedPayment,
                            onChanged: (method) {
                              setState(() => _selectedPayment = method);
                            },
                          ),
                        ],
                      ).animate(effects: _introEffects),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 1, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _showPriceDetails(
                                  subtotal: subtotalValue,
                                  vat: vat,
                                  total: total,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Total',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.keyboard_arrow_up_rounded,
                                            size: 16,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₦${formatMoney(total)}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              height: 52,
                              child: MyButton(
                                text: _isProcessing
                                    ? 'Processing...'
                                    : 'Checkout',
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                onTap: _isProcessing
                                    ? null
                                    : () async {
                                        if (_selectedShippingMethod == null ||
                                            _shippingCost.value == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please select a shipping method to continue.',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        if (_selectedPayment == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please select a payment method to continue.',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() => _isProcessing = true);
                                        try {
                                          final items = cart.selectedItems.map((
                                            cartItem,
                                          ) {
                                            final product = productProvider
                                                .getProductById(
                                                  cartItem.productId,
                                                );
                                            return OrderLineItem(
                                              name: product?.name ?? 'Item',
                                              quantity: cartItem.quantity,
                                              price: product?.price ?? 0,
                                            );
                                          }).toList();

                                          await _startPayment(
                                            items: items,
                                            total: total,
                                          );
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Payment failed to start: $e',
                                              ),
                                            ),
                                          );
                                        } finally {
                                          if (mounted)
                                            setState(
                                              () => _isProcessing = false,
                                            );
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'Preparing secure payment...',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Price breakdown shown when the user taps the "Total" row at checkout.
/// Subtotal and VAT are fixed once the sheet opens (recomputed each time
/// the cart/shipping changes upstream); shipping updates live via the
/// same ValueNotifiers checkout uses, since it may still be calculating.
class _PriceDetailsSheet extends StatelessWidget {
  final double subtotal;
  final double vat;
  final double total;
  final ValueNotifier<double?> shippingCost;
  final ValueNotifier<bool> loadingShipping;
  final ValueNotifier<String?> shippingError;

  const _PriceDetailsSheet({
    required this.subtotal,
    required this.vat,
    required this.total,
    required this.shippingCost,
    required this.loadingShipping,
    required this.shippingError,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Price Details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _row(context, 'Subtotal', '₦${formatMoney(subtotal)}'),
            const SizedBox(height: 10),
            _shippingRow(context),
            const SizedBox(height: 10),
            _row(context, 'VAT (7.5%)', '₦${formatMoney(vat)}'),
            const Divider(height: 28),
            _row(context, 'Total', '₦${formatMoney(total)}', emphasize: true),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    final style = emphasize
        ? GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Theme.of(context).colorScheme.onPrimary,
          )
        : GoogleFonts.dmSans(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onPrimary,
          );
    final valueStyle = emphasize
        ? GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Theme.of(context).colorScheme.onPrimary,
          )
        : GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: valueStyle),
      ],
    );
  }

  Widget _shippingRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Shipping',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        ValueListenableBuilder<double?>(
          valueListenable: shippingCost,
          builder: (context, cost, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: loadingShipping,
              builder: (context, loading, _) {
                return ValueListenableBuilder<String?>(
                  valueListenable: shippingError,
                  builder: (context, error, _) {
                    final text = loading
                        ? 'Calculating...'
                        : error != null
                        ? error
                        : cost != null
                        ? '₦${formatMoney(cost)}'
                        : '—';
                    return Text(
                      text,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

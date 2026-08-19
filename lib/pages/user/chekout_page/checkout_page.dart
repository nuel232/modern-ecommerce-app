import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/component/my_button.dart';
import 'package:morden_ecommerce_app/models/address_model.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/payment_web_view_page.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/Shipping_method.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/address_widget.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/order_summary.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/payment_method.dart';
import 'package:morden_ecommerce_app/providers/cart_provider.dart';
import 'package:morden_ecommerce_app/providers/product_provider.dart';
import 'package:morden_ecommerce_app/services/shop/shipping_service.dart';
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
  final ValueNotifier<double?> _shippingCost = ValueNotifier(null);
  final ValueNotifier<bool> _loadingShipping = ValueNotifier(false);
  final ValueNotifier<String?> _shippingError = ValueNotifier(null);
  String? _lastCalculatedKey;
  bool _isProcessing = false;

  @override
  void dispose() {
    _shippingCost.dispose();
    _loadingShipping.dispose();
    _shippingError.dispose();
    super.dispose();
  }

  Future<void> _maybeCalculateShipping() async {
    print(
      'CALC CALLED — address: ${_selectedAddress?.fullAddress}, method: $_selectedShippingMethod',
    );
    if (_selectedAddress == null || _selectedShippingMethod == null) {
      print('CALC SKIPPED — address or method is null');
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
      print('SHIPPING CALC ERROR: $e'); // <-- add this
      if (!mounted) return;
      _shippingError.value = 'Could not calculate shipping';
      _loadingShipping.value = false;
    }
  }

  Future<void> _startPayment() async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'initializeTransaction',
      );

      final result = await callable.call({
        'shippingCost': _shippingCost.value ?? 0,
        'email': FirebaseAuth.instance.currentUser!.email,
      });
      print('SUCCESS: ${result.data}');
      if (!mounted) return;

      final reference = await Navigator.push<String>(
        context,

        MaterialPageRoute(
          builder: (context) =>
              PaymentWebViewPage(checkoutUrl: result.data['authorizationUrl']),
        ),
      );
      if (reference == null) {
        return;
      }
      final verify = FirebaseFunctions.instance.httpsCallable(
        'verifyTransaction',
      );

      final verifyResult = await verify.call({'reference': reference});
      if (!mounted) return;

      if (verifyResult.data['verified'] == true) {
        final cart = context.read<CartProvider>();
        final productProvider = context.read<ProductProvider>();

        final items = cart.selectedItems.map((cartItem) {
          final product = productProvider.getProductById(cartItem.productId);
          if (product == null) {
            throw Exception('Product not found: ${cartItem.productId}');
          }
          return {
            'productId': product.productId,
            'name': product?.name ?? 'Unknown product',
            'quantity': cartItem.quantity,
            'price': product.price,
          };
        }).toList();

        await FirebaseFirestore.instance.collection('orders').add({
          'Uid': FirebaseAuth.instance.currentUser!.uid,
          'items': items,
          'address': _selectedAddress?.toMap(),
          'subtotal': cart.getCartTotal(productProvider.products),
          'Vat': result.data['vat'],

          'shippingCost': _shippingCost.value,
          'total': result.data['total'],
          'reference': reference,
          'status': 'paid',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await cart.clearCart();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment successful!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment verification failed.')),
        );
      }
      print('VERIFY SUCCESS: ${verifyResult.data}');
    } catch (e) {
      print('FUNCTION ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    final productProvider = context.watch<ProductProvider>();
    // final ShippingMethod? _selectedShippingMethod = null;
    final subtotalValue = cart.getCartTotal(productProvider.products);
    final Subtotal = subtotalValue.toStringAsFixed(0);

    final shipping = _shippingCost.value ?? 0;
    final vatableAmount = subtotalValue + shipping;
    final vat = vatableAmount * 0.075;

    final total = subtotalValue + shipping + vat;
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
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
                      PaymentMethod(),
                    ],
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context, StateSetter setmodalstate) {
                                  return SizedBox(
                                    height: 300,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              "Price Details",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Divider(thickness: 0.3),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 8.0,
                                                  ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('Subtotal:'),
                                                      Text('₦ ${Subtotal}'),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('Shipping:'),
                                                      ValueListenableBuilder<
                                                        double?
                                                      >(
                                                        valueListenable:
                                                            _shippingCost,
                                                        builder: (context, cost, _) {
                                                          return ValueListenableBuilder<
                                                            bool
                                                          >(
                                                            valueListenable:
                                                                _loadingShipping,
                                                            builder: (context, loading, _) {
                                                              return ValueListenableBuilder<
                                                                String?
                                                              >(
                                                                valueListenable:
                                                                    _shippingError,
                                                                builder: (context, error, _) {
                                                                  return Text(
                                                                    loading
                                                                        ? 'Calculating...'
                                                                        : error !=
                                                                              null
                                                                        ? error
                                                                        : cost !=
                                                                              null
                                                                        ? '₦ ${cost.toStringAsFixed(0)}'
                                                                        : '—',
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('Discount:'),
                                                      Text('₦'),
                                                    ], // Update this line
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('VAT:'),
                                                      Text(
                                                        '- ₦ ${vat.toStringAsFixed(0)}',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ], // Update this line
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'Total: ',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '₦${cart.getCartTotal(productProvider.products).toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(Icons.keyboard_arrow_up_rounded, size: 15),
                          ],
                        ),
                      ),

                      MyButton(
                        text: 'submit',
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        onTap: _isProcessing
                            ? null
                            : () async {
                                setState(() => _isProcessing = true);
                                try {
                                  await _startPayment();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Payment failed to start: $e',
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (mounted)
                                    setState(() => _isProcessing = false);
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

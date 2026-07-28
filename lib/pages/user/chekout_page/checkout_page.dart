import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/component/my_button.dart';
import 'package:morden_ecommerce_app/models/address_model.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/Shipping_method.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/address_widget.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/order_summary.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/payment_method.dart';
import 'package:morden_ecommerce_app/providers/cart_provider.dart';
import 'package:morden_ecommerce_app/providers/product_provider.dart';
import 'package:morden_ecommerce_app/services/shop/shipping_service.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Method? _selectedShippingMethod;
  AddressModel? _selectedAddress;
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    final productProvider = context.watch<ProductProvider>();
    // final ShippingMethod? _selectedShippingMethod = null;
    final Subtotal = cart
        .getCartTotal(productProvider.products)
        .toStringAsFixed(0);
    final shippingCost = ShippingService.calculateShippingCost(
      destinationAddress: _selectedAddress?.fullAddress ?? '',
      isExpress: _selectedShippingMethod == Method.express,
    );

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
                          setState(() {
                            _selectedAddress = address;
                          });
                        },
                      ),
                      //order summary
                      OrderSummary(),

                      //delivery method
                      ShippingMethod(
                        selectedShipping: _selectedShippingMethod,
                        onChanged: (method) {
                          setState(() {
                            _selectedShippingMethod = method;
                          });
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
                      offset: const Offset(0, -3), // changes position of shadow
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
                                builder:
                                    (
                                      BuildContext context,
                                      StateSetter setmodalstate,
                                    ) {
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
                                                          Text('₦${Subtotal}'),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text('Shipping:'),
                                                          Text('₦'),
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
                                                          Text('₦'),
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
                        onTap: () {},
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

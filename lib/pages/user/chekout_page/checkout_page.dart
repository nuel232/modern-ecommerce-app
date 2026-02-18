import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/models/address_model.dart';
import 'package:morden_ecommerce_app/models/user.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/address_form.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/address_list.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/address_widget.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          //users address
          AddressWidget(),

          //order summary

          //delivery method
          Container(),

          //Promo code

          //payment method

          //special instruction

          //price breakdown

          //Terms and conditions

          //place order button
        ],
      ),
    );
  }
}

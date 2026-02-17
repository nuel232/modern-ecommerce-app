import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/models/address_model.dart';
import 'package:morden_ecommerce_app/models/user.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/address_form.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/address_list.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/address_page.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/address_widget.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
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

          final user = UserModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
          );

          final addresses = user.addresses;
          // ✅ Declare address as nullable
          AddressModel? address;

          return Column(
            children: [
              //users address
              AddressWidget(),

              //delivery method
              Container(),

              //order summary

              //Promo code

              //payment method

              //special instruction

              //price breakdown

              //Terms and conditions

              //place order button
            ],
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/models/user.dart';

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
          // pick default address if any, otherwise the first one
          final address = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );

          return Column(
            children: [
              //users address
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: addresses.isEmpty
                    ? Text(
                        'please input your address',
                        style: GoogleFonts.dmSans(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      )
                    : Column(
                        children: [
                          Text("Contact: ${address.email}"),
                          Text('name: ${address.fullName}'),
                          Text('phone: ${address.phoneNumber}'),
                          Text(
                            'Ship to:  ${address.streetAddress}, ${address.city}, ${address.state} ',
                          ),
                        ],
                      ),
              ),

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

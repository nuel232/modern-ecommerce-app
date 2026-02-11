import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/models/address_model.dart';
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
          // ✅ Declare address as nullable
          AddressModel? address;

          // ✅ Only try to get address if list is not empty
          if (addresses.isNotEmpty) {
            address = addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            );
          }
          return Column(
            children: [
              //users address
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: addresses.isEmpty
                      ? Border.all(color: Colors.red)
                      : Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  color: Theme.of(context).colorScheme.primary,
                ),

                child: ListTile(
                  title: Text('Shipping Address'),

                  subtitle: addresses.isEmpty
                      ? Text(
                          'please input your address',
                          style: GoogleFonts.dmSans(
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contact: ${address!.email}'),
                            Text('name: ${address!.fullName}'),
                            Text('phone: ${address!.phoneNumber}'),
                            Text(
                              'Ship to:  ${address!.streetAddress}, ${address!.city}, ${address!.state} ',
                            ),
                          ],
                        ),
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

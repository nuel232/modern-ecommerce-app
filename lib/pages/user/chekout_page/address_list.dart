import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/models/address_model.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/address_form.dart';

class AddressList extends StatelessWidget {
  const AddressList({super.key});

  Stream<List<AddressModel>> getAddresses() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('addresses')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AddressModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('shipping address'),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.close),
          ),
        ],
      ),

      body: StreamBuilder(
        stream: getAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No addresses found');
          }

          final addresses = snapshot.data!;

          return ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: address.isDefault
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                  ),
                  color: address.isDefault
                      ? Colors.green.shade200
                      : Theme.of(context).colorScheme.primary,
                ),

                child: ListTile(
                  title: Text('Shipping Address'),

                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact: ${address.email}'),
                      Text('name: ${address.fullName}'),
                      Text('phone: ${address.phoneNumber}'),
                      Text(
                        'Ship to:  ${address.streetAddress}, ${address.city}, ${address.state} ',
                      ),
                    ],
                  ),
                  trailing: GestureDetector(
                    onTap: () async {
                      // EDIT — pass existing address
                      final updatedAddress = await Navigator.push<AddressModel>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddressForm(existingAddress: address),
                        ),
                      );

                      if (updatedAddress != null) {
                        //replace the old address in firestore
                        final updatedList = addresses
                            .map(
                              (a) => a.addressId == updatedAddress.addressId
                                  ? updatedAddress.toMap()
                                  : a.toMap(),
                            )
                            .toList();

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('addresses')
                            .doc(updatedAddress.addressId)
                            .update(updatedAddress.toMap());
                      }
                    },

                    child: Icon(Icons.edit_note_rounded, size: 15),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

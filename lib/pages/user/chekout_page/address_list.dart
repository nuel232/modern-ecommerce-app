import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/component/my_button.dart';
import 'package:morden_ecommerce_app/models/address_model.dart';
import 'package:morden_ecommerce_app/models/user.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/address_form.dart';

class AddressList extends StatelessWidget {
  const AddressList({super.key});

  Stream<List<AddressModel>> getAddresses() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((doc) {
          final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          return user.addresses;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Stack(
            alignment: Alignment.center,
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
              // Centered Title
              Center(
                child: Text(
                  'Shipping Address',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Close Button on the Right
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),

        Divider(height: 0.5, color: Colors.grey.shade700),
        Expanded(
          child: StreamBuilder(
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
                  return GestureDetector(
                    onTap: () async {
                      final batch = FirebaseFirestore.instance.batch();
                      final userRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid);
                      final updatedAddress = addresses.map((a) {
                        return {
                          ...a.toMap(),
                          'isDefault': a.addressId == address.addressId,
                        };
                      }).toList();

                      batch.update(userRef, {'addresses': updatedAddress});
                      await batch.commit();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: address.isDefault
                              ? Colors.green.shade600
                              : Theme.of(context).colorScheme.primary,
                        ),
                        color: address.isDefault
                            ? Colors.green.shade300.withOpacity(0.2)
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
                            final updatedAddress =
                                await Navigator.push<AddressModel>(
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
                                    (a) =>
                                        a.addressId == updatedAddress.addressId
                                        ? updatedAddress.toMap()
                                        : a.toMap(),
                                  )
                                  .toList();

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                    'addresses': addresses
                                        .map(
                                          (a) =>
                                              a.addressId ==
                                                  updatedAddress.addressId
                                              ? updatedAddress.toMap()
                                              : a.toMap(),
                                        )
                                        .toList(),
                                  });
                            }
                          },

                          child: Icon(Icons.edit_note_rounded, size: 25),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 30,
                offset: Offset(0, 4),
              ),
            ],
          ),

          child: MyButton(
            text: 'Add address',
            onTap: () async {
              final newAddress = await Navigator.push<AddressModel>(
                context,
                MaterialPageRoute(builder: (context) => AddressForm()),
              );

              if (newAddress != null) {
                //save to firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                      'addresses': FieldValue.arrayUnion([newAddress.toMap()]),
                    });
              }
            },
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
        ),
      ],
    );
  }
}

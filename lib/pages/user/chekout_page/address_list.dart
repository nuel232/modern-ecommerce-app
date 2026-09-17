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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Align(
              //   alignment: Alignment.topCenter,
              //   child: Container(
              //     width: 40,
              //     height: 4,
              //     margin: const EdgeInsets.only(bottom: 4),
              //     decoration: BoxDecoration(
              //       color: colorScheme.onSurface.withOpacity(0.2),
              //       borderRadius: BorderRadius.circular(2),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.secondary.withOpacity(0.15),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Shipping Address',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onPrimary.withOpacity(0.08),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Divider(height: 0.5, color: colorScheme.onSurface.withOpacity(0.1)),
        Flexible(
          child: StreamBuilder(
            stream: getAddresses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No addresses found',
                      style: GoogleFonts.dmSans(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              }

              final addresses = snapshot.data!;

              return ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: address.isDefault
                            ? colorScheme.secondary.withOpacity(0.1)
                            : colorScheme.primary,
                        border: Border.all(
                          color: address.isDefault
                              ? colorScheme.secondary
                              : colorScheme.onPrimary.withOpacity(0.1),
                          width: address.isDefault ? 1.5 : 1,
                        ),
                        boxShadow: address.isDefault
                            ? [
                                BoxShadow(
                                  color: colorScheme.secondary.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: address.isDefault
                                  ? LinearGradient(
                                      colors: [
                                        colorScheme.secondary,
                                        colorScheme.secondary.withOpacity(0.7),
                                      ],
                                    )
                                  : null,
                              color: address.isDefault
                                  ? null
                                  : colorScheme.onPrimary.withOpacity(0.06),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: address.isDefault
                                  ? colorScheme.onSecondary
                                  : colorScheme.onPrimary.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      address.fullName,
                                      style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (address.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.secondary,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          'Default',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${address.streetAddress}, ${address.city}, ${address.state}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: colorScheme.onPrimary.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  address.phoneNumber,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: colorScheme.onPrimary.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  address.email,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: colorScheme.onPrimary.withOpacity(
                                      0.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
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
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.onPrimary.withOpacity(0.06),
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: colorScheme.onPrimary.withOpacity(0.6),
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
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
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

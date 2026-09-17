import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/models/address_model.dart';
import 'package:morden_ecommerce_app/models/user.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/address_form.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/address_list.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/Shipping_method.dart';

class AddressWidget extends StatefulWidget {
  final AddressModel? selectedAddress;
  final ValueChanged<AddressModel?> onChanged;
  const AddressWidget({
    super.key,
    this.selectedAddress,
    required this.onChanged,
  });

  @override
  State<AddressWidget> createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = UserModel.fromMap(
          snapshot.data!.data() as Map<String, dynamic>,
        );

        final addresses = user.addresses;
        AddressModel? address;

        if (addresses.isNotEmpty) {
          address = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
        }

        // Only notify the parent if this address is actually different
        // from what it already has — prevents an infinite rebuild loop.
        if (address?.addressId != widget.selectedAddress?.addressId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onChanged(address);
          });
        }

        return Column(
          children: [
            //users address
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: addresses.isEmpty
                    ? Border.all(color: Colors.red)
                    : Border.all(color: Theme.of(context).colorScheme.primary),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () async {
                    if (addresses.isEmpty) {
                      // CREATE — no existing address
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
                              'addresses': FieldValue.arrayUnion([
                                newAddress.toMap(),
                              ]),
                            });
                      }
                    } else {
                      showModalBottomSheet(
                        context: context,
                        // isScrollControlled: true,
                        builder: (context) => AddressList(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(35),
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.secondary.withOpacity(0.15),
                          ),
                          child: Icon(
                            addresses.isEmpty
                                ? Icons.add_location_alt_outlined
                                : Icons.location_on_outlined,
                            size: 22,
                            color: addresses.isEmpty
                                ? Colors.red
                                : Theme.of(
                                    context,
                                  ).colorScheme.onPrimary.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shipping Address',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (addresses.isEmpty)
                                Text(
                                  'Add a shipping address to continue',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                )
                              else ...[
                                Text(
                                  address!.fullName,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${address.streetAddress}, ${address.city}, ${address.state}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary.withOpacity(1),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  address.phoneNumber,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary.withOpacity(1),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

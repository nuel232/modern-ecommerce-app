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
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: addresses.isEmpty
                    ? Border.all(color: Colors.red)
                    : Border.all(color: Theme.of(context).colorScheme.primary),
                color: Theme.of(context).colorScheme.primary,
              ),

              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Shipping Address',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

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
                          Text('name: ${address.fullName}'),
                          Text('phone: ${address.phoneNumber}'),
                          Text(
                            'Ship to:  ${address.streetAddress}, ${address.city}, ${address.state} ',
                          ),
                        ],
                      ),
                trailing: GestureDetector(
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
                        builder: (context) => AddressList(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(35),
                          ),
                        ),
                      );
                    }
                  },
                  child: Icon(Icons.arrow_forward_ios_rounded, size: 15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

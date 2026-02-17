import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/models/address_model.dart';

class AddressPage extends StatelessWidget {
  final AddressModel? existingAddress;
  final Function(AddressModel) onSave;
  const AddressPage({super.key, this.existingAddress, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Address'),
        leading: Icon(Icons.arrow_back_ios_new_rounded),
      ),
      body: GestureDetector(onTap: () {}),
    );
  }
}

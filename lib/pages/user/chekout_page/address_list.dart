import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';

class AddressList extends StatelessWidget {
  const AddressList({super.key});


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

      body: ListView.builder(,itemBuilder: (context, index) {}),
    );
  }
}

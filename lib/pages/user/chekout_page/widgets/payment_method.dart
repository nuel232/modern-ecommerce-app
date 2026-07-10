import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/widgets/Shipping_method.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  Method? _selectedPayment;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),

      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            child: Text(
              'Payment Method',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          ListTile(
            title: Text('Credit/Debit Card'),
            trailing: Checkbox(
              checkColor: Theme.of(context).colorScheme.onSecondary,
              activeColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              value: _selectedPayment == Method.standard,
              onChanged: (value) {
                setState(() {
                  _selectedPayment = value == true ? Method.standard : null;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Bank Transfer'),
            trailing: Checkbox(
              checkColor: Theme.of(context).colorScheme.onSecondary,
              activeColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              value: _selectedPayment == Method.express,
              onChanged: (value) {
                setState(() {
                  _selectedPayment = value == true ? Method.express : null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum Method { standard, express, overnight }

class ShippingMethod extends StatefulWidget {
  const ShippingMethod({super.key});

  @override
  State<ShippingMethod> createState() => _ShippingMethodState();
}

class _ShippingMethodState extends State<ShippingMethod> {
  Method? _selectedShipping;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                'Shipping Method',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            ListTile(
              title: Text('Standard Shipping'),
              subtitle: Text('3-10 working days'),
              trailing: Checkbox(
                checkColor: Theme.of(context).colorScheme.onSecondary,
                activeColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),

                value: _selectedShipping == Method.standard,
                onChanged: (value) {
                  setState(() {
                    _selectedShipping = value == true ? Method.standard : null;
                  });
                },
              ),
            ),

            ListTile(
              title: Text('Express Shipping'),
              subtitle: Text('1-3 working days'),
              trailing: Checkbox(
                checkColor: Theme.of(context).colorScheme.onSecondary,
                activeColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                value: _selectedShipping == Method.express,
                onChanged: (value) {
                  setState(() {
                    _selectedShipping = value == true ? Method.express : null;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

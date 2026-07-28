import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum Method { standard, express, overnight }

class ShippingMethod extends StatefulWidget {
  final Method? selectedShipping;
  final ValueChanged<Method?> onChanged;
  const ShippingMethod({
    super.key,
    required this.onChanged,
    required this.selectedShipping,
  });

  @override
  State<ShippingMethod> createState() => _ShippingMethodState();
}

class _ShippingMethodState extends State<ShippingMethod> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
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

              value: widget.selectedShipping == Method.standard,
              onChanged: (value) {
                widget.onChanged(value == true ? Method.standard : null);
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
              value: widget.selectedShipping == Method.express,
              onChanged: (value) {
                widget.onChanged(value == true ? Method.express : null);
              },
            ),
          ),
        ],
      ),
    );
  }
}

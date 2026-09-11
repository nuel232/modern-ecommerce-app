import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Which Paystack channel to restrict checkout to. Kept separate from the
/// shipping Method enum — payment method and shipping method are unrelated
/// choices and shouldn't share a type.
enum PaymentChannel { card, bankTransfer }

class PaymentMethod extends StatelessWidget {
  final PaymentChannel? selectedPayment;
  final ValueChanged<PaymentChannel?> onChanged;

  const PaymentMethod({
    super.key,
    required this.selectedPayment,
    required this.onChanged,
  });

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
              value: selectedPayment == PaymentChannel.card,
              onChanged: (value) {
                onChanged(value == true ? PaymentChannel.card : null);
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
              value: selectedPayment == PaymentChannel.bankTransfer,
              onChanged: (value) {
                onChanged(value == true ? PaymentChannel.bankTransfer : null);
              },
            ),
          ),
        ],
      ),
    );
  }
}

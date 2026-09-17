import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentCancelledPage extends StatelessWidget {
  const PaymentCancelledPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ).animate().fadeIn(duration: 250.ms).scale(),
                const SizedBox(height: 24),
                Text(
                  'Payment Cancelled',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 8),
                Text(
                  'You cancelled the payment. No charge was made — you can try again whenever you\'re ready.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.dmSans(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Continue Shopping',
                      style: GoogleFonts.dmSans(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

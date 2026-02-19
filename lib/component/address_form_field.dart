import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool isRequired;
  final String? errorText;
  final Widget? prefix;
  const AddressFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.isRequired = true,
    this.errorText,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Label
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: label, style: GoogleFonts.poppins()),
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 5),

          /// TextField
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              errorText: errorText,
              prefixIcon: prefix,

              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 0.4,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

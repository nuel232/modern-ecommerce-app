import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPopover extends StatelessWidget {
  final void Function()? onDeleteTap;
  final void Function()? onEditTap;

  const AdminPopover({
    super.key,
    required this.onDeleteTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //edit option
        GestureDetector(
          onTap: () {
            Navigator.pop(context);

            onEditTap!();
          },
          child: Container(
            height: 50,
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text(
                'Edit',
                style: GoogleFonts.dmSans(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        //delete option
        GestureDetector(
          onTap: () {
            Navigator.pop(context);

            onDeleteTap!();
          },
          child: Container(
            height: 50,
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text(
                'delete',
                style: GoogleFonts.dmSans(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyNavBar extends StatelessWidget {
  final Function(int)? onTabChange;
  final String text;
  final String text2;
  final String text3;
  final IconData icon;
  final IconData icon2;
  final IconData icon3;
  final int? cartItemCount;
  const MyNavBar({
    super.key,
    required this.onTabChange,
    required this.text,
    required this.text2,
    required this.text3,
    required this.icon,
    required this.icon2,
    required this.icon3,
    this.cartItemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: GNav(
        color: Theme.of(context).colorScheme.inversePrimary,
        activeColor: Theme.of(context).colorScheme.inverseSurface,
        tabActiveBorder: Border.all(
          color: Theme.of(context).colorScheme.primary,
        ),
        tabBackgroundColor: Theme.of(context).colorScheme.primary,
        mainAxisAlignment: MainAxisAlignment.center,
        tabBorderRadius: 10,
        onTabChange: (value) => onTabChange!(value),

        tabs: [
          GButton(icon: icon, text: text),
          GButton(
            icon: icon2,
            text: text2,
            leading: cartItemCount != null && cartItemCount! > 0
                ? Badge(
                    label: Text(
                      cartItemCount! > 99 ? '99+' : '$cartItemCount',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Icon(
                      icon2,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  )
                : null,
          ),
          GButton(icon: icon3, text: text3),
        ],
      ),
    );
  }
}

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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            Color.alphaBlend(
              colorScheme.secondary.withOpacity(0.05),
              colorScheme.primary,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withOpacity(0.15),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  size: 16,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Shipping Method',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ShippingOptionTile(
            icon: Icons.local_shipping_outlined,
            title: 'Standard Shipping',
            subtitle: '3-10 working days',
            selected: widget.selectedShipping == Method.standard,
            onTap: () => widget.onChanged(
              widget.selectedShipping == Method.standard
                  ? null
                  : Method.standard,
            ),
          ),
          const SizedBox(height: 10),
          _ShippingOptionTile(
            icon: Icons.bolt_rounded,
            title: 'Express Shipping',
            subtitle: '1-3 working days',
            selected: widget.selectedShipping == Method.express,
            onTap: () => widget.onChanged(
              widget.selectedShipping == Method.express ? null : Method.express,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShippingOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ShippingOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? colorScheme.secondary.withOpacity(0.14)
              : colorScheme.onPrimary.withOpacity(0.03),
          border: Border.all(
            color: selected
                ? colorScheme.secondary
                : colorScheme.onPrimary.withOpacity(0.1),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colorScheme.secondary.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected
                    ? LinearGradient(
                        colors: [
                          colorScheme.secondary,
                          colorScheme.secondary.withOpacity(0.7),
                        ],
                      )
                    : null,
                color: selected
                    ? null
                    : colorScheme.onPrimary.withOpacity(0.06),
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected
                    ? colorScheme.onSecondary
                    : colorScheme.onPrimary.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: colorScheme.onPrimary.withOpacity(1),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: selected ? 1.0 : 0.9,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? colorScheme.secondary : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? colorScheme.secondary
                        : colorScheme.onPrimary.withOpacity(0.35),
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: colorScheme.onSecondary,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

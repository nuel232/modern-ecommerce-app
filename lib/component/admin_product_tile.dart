import 'dart:io';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/component/admin_popover.dart';
import 'package:popover/popover.dart';

class AdminProductTile extends StatelessWidget {
  final String name;
  final double price;

  final String imagePath;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;

  const AdminProductTile({
    super.key,
    required this.name,
    required this.onDeletePressed,
    required this.onEditPressed,
    required this.imagePath,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: imagePath.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imagePath.startsWith('assets/')
                    ? Image.asset(
                        imagePath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(imagePath),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.inventory_2_outlined, size: 30),
              ),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(Icons.inventory, size: 16, color: Colors.grey),
              SizedBox(width: 4),

              SizedBox(width: 20),
              Icon(Icons.attach_money, size: 16, color: Colors.green),
              Text(
                '$price.toStringAsFixed(2)',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        trailing: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => showPopover(
              width: 100,
              height: 100,
              backgroundColor: Theme.of(context).colorScheme.surface,
              context: context,
              bodyBuilder: (context) => AdminPopover(
                onDeleteTap: onDeletePressed,
                onEditTap: onEditPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

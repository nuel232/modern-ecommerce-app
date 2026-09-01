import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/util/formatters.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(error: snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const _EmptyState();
          }

          final orders = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;
              return _OrderCard(orderId: doc.id, data: data);
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;

  const _OrderCard({required this.orderId, required this.data});

  @override
  Widget build(BuildContext context) {
    final items = (data['items'] as List?) ?? const [];
    final total = (data['totalPrice'] as num?) ?? 0;
    final status = (data['status'] as String?) ?? 'unknown';
    final createdAtRaw = data['createdAt'];

    final date = parseFirestoreDate(createdAtRaw);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) =>
                  _OrderDetailSheet(orderId: orderId, data: data),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${shortId(orderId)}',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    _StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _itemsSummary(items),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            date != null ? formatDate(date) : 'Date unknown',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₦${formatMoney(total)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;

  const _OrderDetailSheet({required this.orderId, required this.data});

  @override
  Widget build(BuildContext context) {
    final items = (data['items'] as List?) ?? const [];
    final total = (data['totalPrice'] as num?) ?? 0;
    final status = (data['status'] as String?) ?? 'unknown';
    final address = data['address'] as Map<String, dynamic>?;
    final reference = data['reference'] as String?;
    final date = parseFirestoreDate(data['createdAt']);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${shortId(orderId)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              if (date != null) ...[
                const SizedBox(height: 4),
                Text(
                  formatDate(date),
                  style: GoogleFonts.dmSans(color: Colors.grey[500]),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Items',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...items.map((item) {
                final map = item as Map<String, dynamic>;
                final name = map['name'] as String? ?? 'Item';
                final qty = (map['quantity'] as num?) ?? 1;
                final price = (map['price'] as num?) ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$name  ×$qty',
                          style: GoogleFonts.dmSans(fontSize: 14),
                        ),
                      ),
                      Text(
                        '₦${formatMoney(price * qty)}',
                        style: GoogleFonts.dmSans(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₦${formatMoney(total)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (address != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Delivery Address',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  address['fullAddress']?.toString() ??
                      address.values.join(', '),
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (reference != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Payment Reference',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  reference,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'paid' => (Colors.green, 'Paid'),
      'pending' => (Colors.orange, 'Pending'),
      'fulfillment_failed' => (Colors.red, 'Issue'),
      _ => (Colors.grey, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your past orders will show up here once you make a purchase.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Could not load orders',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- helpers ----
// formatMoney, formatDate, parseFirestoreDate, and shortId now live in
// lib/utils/formatters.dart, shared across screens.

String _itemsSummary(List items) {
  if (items.isEmpty) return 'Order';
  final first = items.first as Map<String, dynamic>;
  final name = first['name'] as String? ?? 'Item';
  if (items.length == 1) return name;
  return '$name +${items.length - 1} more';
}

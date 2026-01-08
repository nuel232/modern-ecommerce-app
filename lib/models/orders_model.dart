import 'package:morden_ecommerce_app/models/cart_model.dart';
import 'package:morden_ecommerce_app/models/product.dart';
import 'package:morden_ecommerce_app/models/shop.dart';

class OrdersModel {
  final String orderId;
  final String usersId;
  final List<CartModel> products;
  final double totalPrice;
  final String status;
  final DateTime orderDate;
  OrdersModel({
    required this.orderId,
    required this.usersId,
    required this.products,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'usersId': usersId,
      'products': products.map((cart) => cart.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
    };
  }

  factory OrdersModel.fromMap(Map<String, dynamic> map) {
    return OrdersModel(
      orderId: map['orderId'] ?? '',
      usersId: map['usersId'] ?? '',
      products: List<CartModel>.from(
        (map['products'] ?? []).map((cartMap) => CartModel.fromMap(cartMap)),
      ),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? '',
      orderDate: DateTime.parse(
        map['orderDate'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

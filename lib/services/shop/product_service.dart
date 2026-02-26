import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:morden_ecommerce_app/models/product.dart';

class ProductService {
  //get collection of products
  final CollectionReference products = FirebaseFirestore.instance.collection(
    'products',
  );

  // Create a new product
  Future<void> createProduct(ProductModel product) async {
    await products.doc(product.productId).set({
      'productId': product.productId,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'stock': product.stock,
      'imagePath': product.imagePath,
      'categoryId': product.categoryId,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Stream all products — no orderBy to avoid index requirement
  Stream<List<ProductModel>> getProductsStream() {
    return products.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => ProductModel.fromMap({
              'productId': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList(),
    );
  }

  // Update a product
  Future<void> updateProduct(ProductModel product) async {
    await products.doc(product.productId).update(product.toMap());
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    await products.doc(productId).delete();
  }
}

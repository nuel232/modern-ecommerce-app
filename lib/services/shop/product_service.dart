import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:morden_ecommerce_app/models/product.dart';

class ProductService {
  //get collection of products
  final CollectionReference products = FirebaseFirestore.instance.collection(
    'products',
  );

  //create a new product
  Future<void> createProduct(ProductModel product) async {
    await products.doc(product.productId).set({
      ...product.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  //   Future<void> createProduct(Map<String, dynamic> product) async {
  //   await products.doc(product['productId']).set({
  //     ...product,
  //     'createdAt': FieldValue.serverTimestamp(),
  //   });
  // }

  //Read
  Stream<List<ProductModel>> getProductsStream() {
    return products
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
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

  //update
  Future<void> updateProduct(ProductModel product) async {
    await products.doc(product.productId).update(product.toMap());
  }

  //delete
  Future<void> deleteProduct(String productId) async {
    await products.doc(productId).delete();
  }
}

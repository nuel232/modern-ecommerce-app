import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  //get collection of products
  final CollectionReference cart = FirebaseFirestore.instance.collection(
    'cart',
  );
}

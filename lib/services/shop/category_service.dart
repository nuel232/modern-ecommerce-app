import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morden_ecommerce_app/models/category_model.dart';

class CategoryService {
  // get collection of categories
  final CollectionReference categories = FirebaseFirestore.instance.collection(
    'categories',
  );

  //create a new category
  Future<void> createCategory(Map<String, dynamic> category) async {
    try {
      await categories.doc(category['categoryId']).set(category);
    } catch (e) {
      print('Error creating category: $e');
      rethrow;
    }
  }

  //read
  Stream<List<CategoryModel>> getCategoryStream() {
    return categories.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => CategoryModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  //update
  Future<void> updateCategory(Map<String, dynamic> category) async {
    await categories.doc(category['categoryId']).update(category);
  }

  //delete
  Future<void> deleteCategory(String categoryId) async {
    await categories.doc(categoryId).delete();
  }
}

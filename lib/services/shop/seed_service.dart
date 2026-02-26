import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morden_ecommerce_app/models/product.dart';

class SeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<ProductModel> _dummyProducts = [
    // ===== SHOES (Cat_001) =====
    ProductModel(
      productId: '1',
      categoryId: 'Cat_001',
      name: 'Air Deldon',
      description: 'Built to break barriers, made for all athletes.',
      price: 160000,
      stock: 5,
      imagePath: 'lib/Images/Air-deldon.png',
    ),
    ProductModel(
      productId: '2',
      categoryId: 'Cat_001',
      name: 'G.T. Cut 3',
      description: 'Engineered for explosive guards.',
      price: 115000,
      stock: 5,
      imagePath: 'lib/Images/GT.png',
    ),
    ProductModel(
      productId: '3',
      categoryId: 'Cat_001',
      name: 'Tatum 3 Tie-Dye',
      description: 'Unleash your creativity with the Tatum 3.',
      price: 110000,
      stock: 5,
      imagePath: 'lib/Images/Tatum-3-tie-dye.png',
    ),
    ProductModel(
      productId: '4',
      categoryId: 'Cat_001',
      name: 'Tatum 3 Tie-Dye (Alt)',
      description: 'Bold colors meet elite performance.',
      price: 110000,
      stock: 5,
      imagePath: 'lib/Images/Tatum-3-tie-dye2.png',
    ),
    ProductModel(
      productId: '5',
      categoryId: 'Cat_001',
      name: 'Zoom Freak 4',
      description: 'Dominate like Giannis in the Nike Zoom Freak 4.',
      price: 130000,
      stock: 5,
      imagePath: 'lib/Images/Zoom-freek-4.jpg',
    ),
    ProductModel(
      productId: '6',
      categoryId: 'Cat_001',
      name: 'Black Shoe Air',
      description: 'Clean black design with everyday comfort.',
      price: 95000,
      stock: 8,
      imagePath: 'lib/Images/Black-shoe.jpeg',
    ),
    ProductModel(
      productId: '7',
      categoryId: 'Cat_001',
      name: 'H-Penny Sneakers',
      description: 'Classic street-style sneakers with comfort.',
      price: 105000,
      stock: 6,
      imagePath: 'lib/Images/HP-envy.jpg',
    ),
    ProductModel(
      productId: '8',
      categoryId: 'Cat_001',
      name: 'Brandon Step Loafer',
      description: 'Premium loafers for smart and casual wear.',
      price: 85000,
      stock: 7,
      imagePath: 'lib/Images/Brandon-Step-Loafer.jpeg',
    ),
    ProductModel(
      productId: '9',
      categoryId: 'Cat_001',
      name: 'Craft Arlo Lace',
      description: 'Handcrafted lace shoes with modern elegance.',
      price: 98000,
      stock: 6,
      imagePath: 'lib/Images/Craft-Arlo-Lace.jpeg',
    ),

    // ===== ACCESSORIES (Cat_002) =====
    ProductModel(
      productId: '10',
      categoryId: 'Cat_002',
      name: 'Adwin Cap',
      description: 'Stylish cap for casual and sporty outfits.',
      price: 18000,
      stock: 15,
      imagePath: 'lib/Images/Aldwin-Cap.jpg',
    ),
    ProductModel(
      productId: '11',
      categoryId: 'Cat_002',
      name: 'Classic Glasses',
      description: 'Fashion-forward glasses for daily wear.',
      price: 25000,
      stock: 12,
      imagePath: 'lib/Images/Glasses.jpg',
    ),

    // ===== SHIRTS (Cat_003) =====
    ProductModel(
      productId: '12',
      categoryId: 'Cat_003',
      name: 'Poplin Classic Fit Shirt',
      description: 'Comfortable classic-fit shirt for all occasions.',
      price: 42000,
      stock: 10,
      imagePath: 'lib/Images/POPLIN-CLASSIC-FIT-SHIRT.jpg',
    ),
    ProductModel(
      productId: '13',
      categoryId: 'Cat_003',
      name: 'Silk Cotton Blend Shirt',
      description: 'Soft silk-cotton blend for premium comfort.',
      price: 48000,
      stock: 9,
      imagePath: 'lib/Images/SILK-COTTON-BLEND-SHIRT.png',
    ),
    ProductModel(
      productId: '14',
      categoryId: 'Cat_003',
      name: 'Silk Cotton Blend Shirt (Alt)',
      description: 'Soft silk-cotton blend for premium comfort.',
      price: 48000,
      stock: 9,
      imagePath: 'lib/Images/SILK-COTTON-BLEND-SHIRT.png',
    ),
  ];

  /// Uploads dummy products only if the products collection is empty.
  /// Safe to call every time — won't duplicate.
  Future<void> seedProductsIfEmpty() async {
    final snapshot = await _firestore.collection('products').limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      print('SeedService: products already exist, skipping seed.');
      return;
    }

    print(
      'SeedService: no products found, seeding ${_dummyProducts.length} products...',
    );

    final batch = _firestore.batch();

    for (final product in _dummyProducts) {
      final ref = _firestore.collection('products').doc(product.productId);
      batch.set(ref, {
        ...product.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    print('SeedService: seeding complete.');
  }
}

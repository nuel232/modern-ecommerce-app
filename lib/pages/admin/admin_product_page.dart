import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:morden_ecommerce_app/models/product.dart';

class AdminProductPage extends StatefulWidget {
  const AdminProductPage({super.key});

  @override
  State<AdminProductPage> createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
  final nameController = TextEditingController();
  final stockController = TextEditingController();
  final priceController = TextEditingController();
  final DescriptionController = TextEditingController();
  final productIdController = TextEditingController();
  String? imagePath;
  final ImagePicker _picker = ImagePicker();

  // Pick image from camera
  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addProduct() {
    if (nameController.text.isEmpty ||
        stockController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final product = ProductModel(
      productId: productIdController.text,
      description: DescriptionController.text,
      name: nameController.text,
      price: priceController.text.isEmpty
          ? 0.0
          : double.parse(priceController.text),
      stock: stockController.text.isEmpty ? 0 : int.parse(stockController.text),
      imagePath: '',
    );

    // Clear fields
    nameController.clear();
    stockController.clear();
    priceController.clear();
    setState(() {
      imagePath = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Product added successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

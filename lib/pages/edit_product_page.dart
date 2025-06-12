import 'package:flutter/material.dart';
import 'package:project_tpm/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_tpm/service/data_service.dart';
import 'package:project_tpm/model/data_model.dart';

class EditProductPage extends StatefulWidget {
  final ModelApp product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late TextEditingController _ratingController;
  late String _selectedCategory;
  bool _isLoading = false;

  List<String> categories = [
    'elektronik',
    'pakaian pria',
    'pakaian wanita',
    'aksesoris'
  ];

// @override
// void initState() {
//   super.initState();
//   // Atur nilai awal _selectedCategory hanya jika ada di daftar
//   if (categories.contains(widget.product.category)) {
//     _selectedCategory = widget.product.category;
//   } else {
//     _selectedCategory = null;
//   }
// }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title ?? '');
    _priceController = TextEditingController(
      text: widget.product.price?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );
    _imageController = TextEditingController(text: widget.product.image ?? '');
    _ratingController = TextEditingController(
    text: widget.product.rating?.toString() ?? '',
  );
    _selectedCategory = widget.product.category ?? "aksesoris";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProduct = await AppService.updateProduct(
        id: widget.product.id!,
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        image: _imageController.text.trim(),
        category: _selectedCategory,
        rating: double.parse(_ratingController.text.trim()),
      );

      if (mounted) {
        // Show success dialog with updated product data
        _showSuccessDialog(updatedProduct);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(ModelApp updatedProduct) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text(
                'Update Successful!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Product has been updated successfully:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDataRow('ID', '${updatedProduct.id}'),
                      _buildDataRow('Title', updatedProduct.title ?? ''),
                      _buildDataRow('Price', '\Rp ${updatedProduct.price}'),
                      _buildDataRow(
                        'Description',
                        updatedProduct.description ?? '',
                      ),
                      _buildDataRow('Image', updatedProduct.image ?? ''),
                      _buildDataRow('Category', updatedProduct.category ?? ''),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                if (updatedProduct.image != null &&
                    updatedProduct.image!.isNotEmpty)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        updatedProduct.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Tutup dialog
                Navigator.of(context).pop();

                // Kembali ke home page dengan cara yang aman
                _navigateToHomePage();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Back to Home',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Navigate to home page with proper navigation
  void _navigateToHomePage() async {
    // Dapatkan username dari SharedPreferences atau context sebelumnya
    final username = await _getUsername();

    if (mounted) {
      // Pop sampai ke home page atau replace dengan home page baru
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage(username: username)),
        (route) => false, // Remove all previous routes
      );
    }
  }

  // Get username from SharedPreferences
  Future<String> _getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('username') ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: const Color.fromARGB(255, 14, 61, 127),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 14, 61, 127),
              Color.fromARGB(255, 166, 192, 235),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product ID Info
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Product ID: ${widget.product.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title Field
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Product Title',
                          prefixIcon: Icon(Icons.shopping_bag),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter product title';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Price Field
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (\Rp)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: InputBorder.none,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter price';
                          }
                          try {
                            double.parse(value.trim());
                          } catch (e) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
// Rating Field
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _ratingController,
                        decoration: const InputDecoration(
                          labelText: 'Rating (1.0 - 5.0)',
                          prefixIcon: Icon(Icons.star),
                          border: InputBorder.none,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter rating';
                          }
                          try {
                            final rating = double.parse(value.trim());
                            if (rating < 1.0 || rating > 5.0) {
                              return 'Rating must be between 1.0 and 5.0';
                            }
                          } catch (e) {
                            return 'Please enter a valid rating';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Category Dropdown
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: categories.toSet().map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Category'),
                        validator: (value) =>
                            value == null ? 'Please select a category' : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Image URL Field
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _imageController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                          prefixIcon: Icon(Icons.image),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter image URL';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description Field
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                          border: InputBorder.none,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Update Button
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 14, 61, 127),
                          Color.fromARGB(255, 42, 95, 170),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'UPDATE PRODUCT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

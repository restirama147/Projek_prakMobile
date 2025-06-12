import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_tpm/model/data_model.dart';

class AppService {
  static const url = 'https://6849b88c45f4c0f5ee729f94.mockapi.io/item';

  // READ - Get all products
  static Future<List<ModelApp>> getData() async {
    try {
      final response = await http.get(Uri.parse(url));
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => ModelApp.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error fetching data: $e");
      rethrow;
    }
  }

  // READ - Get a single product by ID
  static Future<ModelApp> getDataId(int id) async {
    try {
      final response = await http.get(Uri.parse("$url/$id"));
      print("Get product by ID - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return ModelApp.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load product with ID: $id');
      }
    } catch (e) {
      print("Error fetching product by ID: $e");
      rethrow;
    }
  }

  // CREATE - Add new product
  static Future<ModelApp> createProduct({
    required String title,
    required double price,
    required String description,
    required String image,
    required String category,
    required double rating,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'price': price,
          'description': description,
          'image': image,
          'category': category,
          'rating': rating
        }),
      );

      print("Create product - Status: ${response.statusCode}");
      print("Create product - Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ModelApp.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      print("Error creating product: $e");
      rethrow;
    }
  }

  static Future<ModelApp> updateProduct({
    required int id,
    required String title,
    required double price,
    required String description,
    required String image,
    required String category,
    required double rating,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$url/$id"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'price': price,
          'description': description,
          'image': image,
          'category': category,
          'rating': rating
        }),
      );

      print("Update product - Status: ${response.statusCode}");
      print("Update product - Body: ${response.body}");

      if (response.statusCode == 200) {
        return ModelApp.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update product with ID: $id');
      }
    } catch (e) {
      print("Error updating product: $e");
      rethrow;
    }
  }

  static Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse("$url/$id"));

      print("Delete product - Status: ${response.statusCode}");
      print("Delete product - Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete product with ID: $id');
      }
    } catch (e) {
      print("Error deleting product: $e");
      rethrow;
    }
  }

  static Future<ModelApp> createProductFromModel(ModelApp product) async {
    return createProduct(
      title: product.title ?? '',
      price: product.price ?? 0.0,
      description: product.description ?? '',
      image: product.image ?? '',
      category: product.category ?? '',
      rating: product.rating ?? 0.0,
    );
  }

  static Future<ModelApp> updateProductFromModel(ModelApp product) async {
    if (product.id == null) {
      throw Exception('Product ID is required for update');
    }

    return updateProduct(
      id: product.id!,
      title: product.title ?? '',
      price: product.price ?? 0.0,
      description: product.description ?? '',
      image: product.image ?? '',
      category: product.category ?? '',
      rating: product.rating ?? 0.0,
    );
  }
}

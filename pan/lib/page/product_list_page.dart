import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home.dart'; // เพื่อใช้ Product model และ POCKETBASE_URL
import 'product_edit_page.dart'; // หน้าสำหรับแก้ไขข้อมูล

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = _fetchProducts();
  }

  // ฟังก์ชันดึงข้อมูล (เหมือนใน home.dart)
  Future<List<Product>> _fetchProducts() async {
    final response = await http.get(Uri.parse('$POCKETBASE_URL/api/collections/product/records'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'];
      return items.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // ฟังก์ชันสำหรับลบข้อมูล
  Future<void> _deleteProduct(String productId) async {
    final response = await http.delete(
      Uri.parse('$POCKETBASE_URL/api/collections/product/records/$productId'),
    );

    if (response.statusCode == 204) { // 204 No Content คือลบสำเร็จ
      // หากลบสำเร็จ ให้ดึงข้อมูลใหม่เพื่ออัปเดตหน้าจอ
      setState(() {
        futureProducts = _fetchProducts();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ปุ่มแก้ไข
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                           // เมื่อกลับมาจากหน้า Edit ให้ refresh ข้อมูล
                           final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductEditPage(product: product),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              futureProducts = _fetchProducts();
                            });
                          }
                        },
                      ),
                      // ปุ่มลบ
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // แสดง Dialog ยืนยันก่อนลบ
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: Text('Are you sure you want to delete "${product.name}"?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _deleteProduct(product.id);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
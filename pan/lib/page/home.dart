import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // สำหรับแปลง JSON
import 'package:http/http.dart' as http; // สำหรับเรียก API
import 'cart_page.dart';
import 'product_list_page.dart'; // แก้ไข: เพิ่ม ; ท้ายบรรทัด

// --- ตั้งค่า POCKETBASE ---
const String POCKETBASE_URL = 'http://127.0.0.1:8090'; // <<!สำคัญ!>> แก้เป็น URL ของคุณ

// --- DATA MODELS (สำหรับข้อมูลจริงจาก PocketBase) ---
class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  // Factory constructor สำหรับสร้าง Product object จาก JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(), // แปลงเป็น double
    );
  }
}

// --- MAIN HOME PAGE WIDGET (เปลี่ยนเป็น StatefulWidget) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // สร้าง Future สำหรับเก็บข้อมูลสินค้าที่จะดึงมา
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    // เริ่มดึงข้อมูลทันทีที่หน้านี้ถูกสร้าง
    futureProducts = fetchProducts();
  }

  // --- ฟังก์ชันสำหรับดึงข้อมูลสินค้าจาก POCKETBASE ---
  Future<List<Product>> fetchProducts() async {
    final url = Uri.parse('$POCKETBASE_URL/api/collections/product/records');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        
        // แปลง List ของ JSON เป็น List ของ Product
        return items.map((item) => Product.fromJson(item)).toList();
      } else {
        // หาก Server ตอบกลับมาด้วย Error
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // หากเกิดปัญหาในการเชื่อมต่อ
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // --- ข้อมูลตัวอย่างสำหรับส่วนที่ยังไม่ได้เชื่อม API ---
  final List<String> topShops = ["Gadget", "Fashion", "Books", "Home", "Sports", "Beauty"];
  final List<Map<String, String>> popularReviews = [
    {"name": "Alex", "review": "Great quality headphones!"},
    {"name": "Maria", "review": "Smartwatch is a game-changer."}
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSphere', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // ==================== โค้ดที่เพิ่มเข้ามา ====================
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductListPage()),
              );
            },
          ),
          // ==========================================================
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1: TOP SHOPS (ยังใช้ข้อมูลตัวอย่าง) ---
              _buildSectionTitle('Top Shops'),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: topShops.length,
                  itemBuilder: (context, index) {
                    return _buildShopCircle(topShops[index]);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- SECTION 2: TOP PRODUCTS (ดึงข้อมูลจริง) ---
              _buildSectionTitle('Top Products'),
              SizedBox(
                height: 250,
                child: FutureBuilder<List<Product>>(
                  future: futureProducts, // ใช้ Future ที่เราสร้างไว้
                  builder: (context, snapshot) {
                    // กรณี: กำลังโหลดข้อมูล
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } 
                    // กรณี: เกิดข้อผิดพลาด
                    else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } 
                    // กรณี: โหลดข้อมูลสำเร็จ แต่ไม่มีข้อมูล
                    else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No products found.'));
                    } 
                    // กรณี: โหลดข้อมูลสำเร็จ
                    else {
                      final products = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(products[index]);
                        },
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- SECTION 3: POPULAR REVIEWS (ยังใช้ข้อมูลตัวอย่าง) ---
              _buildSectionTitle('Popular Reviews'),
              ...popularReviews.map((r) => _buildReviewCard(r['name']!, r['review']!)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS (มีการแก้ไขเล็กน้อย) ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildShopCircle(String shopName) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            child: Text(shopName.substring(0, 2), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text(shopName, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(String name, String review) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(review, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
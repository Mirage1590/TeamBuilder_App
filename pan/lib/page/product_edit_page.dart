import 'package:flutter/material.dart';
import 'home.dart'; // เพื่อใช้ Product model
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductEditPage extends StatefulWidget {
  final Product product;
  const ProductEditPage({super.key, required this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    // นำข้อมูลเดิมของสินค้ามาใส่ในฟอร์ม
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _imageUrlController = TextEditingController(text: widget.product.imageUrl);
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('$POCKETBASE_URL/api/collections/product/records/${widget.product.id}');
      final body = json.encode({
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'imageUrl': _imageUrlController.text,
      });

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!'), backgroundColor: Colors.green));
        Navigator.of(context).pop(true); // ส่ง true กลับไปเพื่อบอกให้ refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: ${response.body}'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || double.tryParse(value) == null) ? 'Please enter a valid price' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter an image URL' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateProduct,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
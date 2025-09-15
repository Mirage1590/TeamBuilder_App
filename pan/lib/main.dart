import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'page/home.dart'; // Make sure home.dart is in the same directory
import 'page/cart_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCommerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Example of setting a default font
      ),
      home: HomePage(),
    );
  }
}
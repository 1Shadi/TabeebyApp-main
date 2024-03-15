import 'package:flutter/material.dart';

class SearchProduct extends StatefulWidget {
  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Product Screen',
          style: TextStyle(
            color: Colors.black54,
            fontFamily: 'Signatra',
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}

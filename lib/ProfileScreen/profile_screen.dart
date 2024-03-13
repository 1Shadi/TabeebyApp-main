import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Profile Screen',
        style: TextStyle(
        color: Colors.black54,
        fontFamily: 'Signatra',
        fontSize: 30,
    ),),

    ));
  }
}

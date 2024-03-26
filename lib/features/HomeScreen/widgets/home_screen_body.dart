import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../SearchProduct/search_product.dart';
import '../../../core/Widgets/global_var.dart';
import '../../../core/Widgets/listview.dart';
import '../../ProfileScreen/profile_screen.dart';
import '../../UploadAdScreen/upload_ad_screen.dart';
import '../../WelcomeScreen/welcome_screen.dart';
import '../manager/home_screen_provider.dart';

class HomeScreenBody extends StatefulWidget {
  final HomeScreenProvider provider;

  const HomeScreenBody({super.key, required this.provider});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    widget.provider.initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.teal],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(sellerId: uid),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchProduct()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.search, color: Colors.orange),
              ),
            ),
            TextButton(
              onPressed: () {
                _auth.signOut().then((value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
                  );
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.logout,
                    color: Colors.orange), // Corrected the icon name
              ),
            ),
          ],
          title: const Text(
            'Home Screen',
            style: TextStyle(
              color: Colors.black54,
              fontFamily: 'Signatra',
              fontSize: 30,
            ),
          ),
          centerTitle: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.teal],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .orderBy('products', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ListViewWidget(
                        docId: snapshot.data!.docs[index].id,
                        itemColor: snapshot.data!.docs[index]['itemColor'],
                        img1: snapshot.data!.docs[index]['urlImage1'],
                        img2: snapshot.data!.docs[index]['urlImage2'],
                        img3: snapshot.data!.docs[index]['urlImage3'],
                        img4: snapshot.data!.docs[index]['urlImage4'],
                        img5: snapshot.data!.docs[index]['urlImage5'],
                        userImg: snapshot.data!.docs[index]['imgPro'],
                        name: snapshot.data!.docs[index]['userName'],
                        date: snapshot.data!.docs[index]['time'].toDate(),
                        userId: snapshot.data!.docs[index]['id'],
                        itemModel: snapshot.data!.docs[index]['itemModel'],
                        postId: snapshot.data!.docs[index]['postId'],
                        itemPrice: snapshot.data!.docs[index]['itemPrice'],
                        description: snapshot.data!.docs[index]['description'],
                        lat: snapshot.data!.docs[index]['lat'],
                        lng: snapshot.data!.docs[index]['lng'],
                        address: snapshot.data!.docs[index]['address'],
                        userNumber: snapshot.data!.docs[index]['userNumber']);
                  },
                );
              } else {
                return const Center(
                  child: Text('there is no item'),
                );
              }
            }
            return const Center(
              child: Text('something went wrong'),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Add Post',
          backgroundColor: Colors.black54,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadAdScreen(),
              ),
            );
          },
          child: const Icon(Icons.cloud_upload),
        ),
      ),
    );
  }
}

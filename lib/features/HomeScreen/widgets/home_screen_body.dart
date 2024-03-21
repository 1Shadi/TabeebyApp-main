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
              .collection('products') // Use the 'products' collection instead of 'items'
              .where('id', isEqualTo: _auth.currentUser!.uid) // Filter by user ID
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final document = snapshot.data!.docs[index];
                  return ListViewWidget(
                    docId: document.id,
                    itemColor: document['itemColor'],
                    img1: document['urlImage1'],
                    img2: document['urlImage2'],
                    img3: document['urlImage3'],
                    img4: document['urlImage4'],
                    img5: document['urlImage5'],
                    userImg: document['imgPro'],
                    name: document['userName'],
                    date: document['time'].toDate(),
                    userId: document['id'],
                    itemModel: document['itemModel'],
                    postId: document['postId'],
                    itemPrice: document['itemPrice'],
                    description: document['description'],
                    lat: document['lat'],
                    lng: document['lng'],
                    address: document['address'],
                    userNumber: document['userNumber'],
                  );
                },
              );
            } else {
              return const Center(
                child: Text('There are no tasks'),
              );
            }
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

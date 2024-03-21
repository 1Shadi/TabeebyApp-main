import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as Path;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tabeeby_app/features/HomeScreen/home_screen.dart';
import 'package:uuid/uuid.dart';

import '../../core/DialogBox/loading_dialog.dart';
import '../../core/Widgets/global_var.dart';

class UploadAdScreen extends StatefulWidget {

  const UploadAdScreen({
    super.key,
  });

  @override
  State<UploadAdScreen> createState() => _UploadAdScreenState();
}


class _UploadAdScreenState extends State<UploadAdScreen> {
  String postId = const Uuid().v4();
  bool uploading = false, next = false;
  final List<File> _image = [];
  List<String> urlslist = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String name = '';
  String phoneNo = '';
  double val = 0;
  CollectionReference? imgRef;
  String itemPrice = '';
  String itemModel = '';
  String itemWeight = '';
  String description = '';

  Future<void> chooseImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image.add(File(pickedFile.path)); // Add picked image to _image list
      });
    }
  }

  Future<void> uploadFile() async {
    int i = 1;
    urlslist.clear(); // Clear the URLs list before uploading new images
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      var ref = FirebaseStorage.instance
          .ref()
          .child('image/${Path.basename(img.path)}');

      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          urlslist.add(value);
          i++;
        });
      });
    }
  }

  Future<void> saveProductToFirestore() async {
    try {
      await uploadFile(); // Upload images first to get URLs
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(postId)
            .set({
          'userName': name,
          'id': currentUser.uid,
          'postId': postId,
          'userNumber': phoneNo,
          'itemPrice': itemPrice,
          'itemModel': itemModel,
          'itemWeight': itemWeight,
          'description': description,
          'urlImage1': urlslist.isNotEmpty ? urlslist[0] : '',
          'urlImage2': urlslist.length > 1 ? urlslist[1] : '',
          'urlImage3': urlslist.length > 2 ? urlslist[2] : '',
          'urlImage4': urlslist.length > 3 ? urlslist[3] : '',
          'urlImage5': urlslist.length > 4 ? urlslist[4] : '',
          'imgPro': userImageUrl,
        });
        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Close dialog
        // Navigate back to the home screen
        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ));
      } else {
        if (kDebugMode) {
          print('User not logged in');
        }
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload product: $error'),
          duration: const Duration(seconds: 3),
        ),
      );
      if (kDebugMode) {
        print("Failed to upload product: $error");
      }
      // Handle the error (e.g., show an error message)
    }
  }

  getNameOfUser() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid) // Use currentUser.uid to get the current user's ID
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          setState(() {
            name = snapshot.data()!['userName'];
            phoneNo = snapshot.data()!['userNumber'];
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //getNameOfUser();
    imgRef = FirebaseFirestore.instance.collection('imageUrls');
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
          title: Text(
            next ? "Please write products info" : "Choose product's image",
            style: const TextStyle(
              color: Colors.black54,
              fontFamily: 'Signatra',
              fontSize: 30,
            ),
          ),
          actions: [
            next
                ? Container()
                : ElevatedButton(
                    onPressed: () {
                      if (_image.length == 5) {
                        setState(() {
                          uploading = true;
                          next = true;
                        });
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Please select 5 images only.',
                          gravity: ToastGravity.CENTER,
                        );
                      }
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black54,
                        fontFamily: 'Varela',
                      ),
                    ),
                  ),
          ],
        ),
        body: next
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 5.0),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Product Price',
                        ),
                        onChanged: (value) {
                          setState(() {
                            itemPrice = value;
                          });
                        },
                      ),
                      const SizedBox(height: 5.0),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Product Name',
                        ),
                        onChanged: (value) {
                          setState(() {
                            itemModel = value;
                          });
                        },
                      ),
                      const SizedBox(height: 5.0),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Product Weight',
                        ),
                        onChanged: (value) {
                          setState(() {
                            itemWeight = value;
                          });
                        },
                      ),
                      const SizedBox(height: 5.0),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Write a description',
                        ),
                        onChanged: (value) {
                          setState(() {
                            description = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const LoadingAlertDialog(
                                  message: 'Uploading...',
                                );
                              },
                            );
                            uploadFile().whenComplete(() {
                              FirebaseFirestore.instance
                                  .collection('products')
                                  .doc(postId)
                                  .set({
                                'userName': name,
                                'id': _auth.currentUser!.uid,
                                'postId': postId,
                                'userNumber': phoneNo,
                                'itemPrice': itemPrice,
                                'itemModel': itemModel,
                                'itemWeight': itemWeight,
                                'description': description,
                                'urlImage1': urlslist[0].toString(),
                                'urlImage2': urlslist[1].toString(),
                                'urlImage3': urlslist[2].toString(),
                                'urlImage4': urlslist[3].toString(),
                                'urlImage5': urlslist[4].toString(),
                                'imgPro': userImageUrl,
                              }).then((value) {
                                Navigator.pop(context); // Close dialog
                                // Navigate back to the home screen
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ));
                              }).catchError((error) {
                                Navigator.pop(context); // Close dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Failed to upload product: $error'),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                if (kDebugMode) {
                                  print("Failed to upload product: $error");
                                }
                                // Handle the error (e.g., show an error message)
                              });
                            });
                          },
                          child: const Text(
                            'Upload',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: GridView.builder(
                      itemCount: _image.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) {
                        return index == 0
                            ? Center(
                                child: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    !uploading
                                        ? chooseImage(ImageSource.gallery)
                                        : null;
                                    // Add functionality for adding images from gallery
                                  },
                                ),
                              )
                            : Container(
                                margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(_image[index - 1]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                      },
                    ),
                  ),
                  uploading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Uploading...',
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CircularProgressIndicator(
                                value: val,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }
}

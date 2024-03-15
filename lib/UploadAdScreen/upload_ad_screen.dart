import 'dart:io'; // Import dart:io instead of dart:html

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tabeeby_app/DialogBox/loading_dialog.dart';
import 'package:tabeeby_app/Widgets/global_var.dart';
import 'package:uuid/uuid.dart';

class UploadAdScreen extends StatefulWidget {
  @override
  State<UploadAdScreen> createState() => _UploadAdScreenState();
}

class _UploadAdScreenState extends State<UploadAdScreen> {
  String postId = const Uuid().v4();
  bool uploading = false, next = false;
  final List<File> _image = [];
  List<String> urlslist = [];
  FirebaseAuth _auth = FirebaseAuth.instance;
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
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      var ref = FirebaseStorage.instance.ref().child('image/${Path.basename(img.path)}');

      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          urlslist.add(value);
          i++;
        });
      });
    }
  }

  getNameOfUser() {
    FirebaseFirestore.instance.collection('users')
        .doc(uid)
        .get()
        .then((snapshot) async{
      if(snapshot.exists)
      {
        setState(() {
          name = snapshot.data()!['userName'];
          phoneNo = snapshot.data()!['userNumber'];
        });
      }
    });
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
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter Product Price',
                  ),
                  onChanged: (value) {
                    setState(() {
                      itemPrice = value;
                    });
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter Product Name',
                  ),
                  onChanged: (value) {
                    setState(() {
                      itemModel = value;
                    });
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter Product Weight',
                  ),
                  onChanged: (value) {
                    setState(() {
                      itemWeight = value;
                    });
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Write a description',
                  ),
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                  },
                ),
                SizedBox(height: 15.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return LoadingAlertDialog(
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
                          // Optionally, you can navigate to another screen or show a success message
                        }).catchError((error) {
                          print("Failed to upload product: $error");
                          // Handle the error (e.g., show an error message)
                        });
                      });
                    },
                    child: Text(
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

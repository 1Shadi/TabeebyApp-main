

import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
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

  // final List<File> _image = [];

  File? _imageFile;
  List<String> urlslist = [];

  FirebaseAuth _auth = FirebaseAuth.instance;

  String name = '';
  String phoneNo = '';

  double val = 0;

  CollectionReference? imgRef;

  String itemPrice = '';
  String itemModel= '';
  String itemWeight = '';
  String description = '';




  Future<void> chooseImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Update _imageFile
      });
    }
  }

  Future uploadFile() async
  {
    int i = 1;
    for(var img in _image)
    {
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

  getNameOfUser()
  {
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
    // TODO: implement initState
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
            next
                ? "Please write products info"
                : "Choose product's image",
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
              onPressed: ()
              {
                if(_image.length == 5)
                {
                  setState(() {
                    uploading = true;
                    next = true;
                  });
                }

                else
                {
                  Fluttertoast.showToast(
                    msg: 'Please select 5 images only.',
                    gravity: ToastGravity.CENTER,

                  );

                }

                // Add the functionality for the Next button here
              },
              child: const Text(
                'Next',
                style: TextStyle(
                    fontSize: 19,
                    color: Colors.black54,
                    fontFamily: 'Varela'),
              ),
            ),
          ],
        ),
        body: next
            ? const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 5.0,),
                TextField(
                  decoration: InputDecoration(hintText: 'Enter Product Price'),
                  onChanged: (value)
                  {
                    itemPrice = value;


                  },
                ),
                SizedBox(height: 5.0,),
                TextField(
                  decoration: InputDecoration(hintText: 'Enter Product Name'),
                  onChanged: (value)
                  {
                    itemModel = value;


                  },
                ),
                SizedBox(height: 5.0,),
                TextField(
                  decoration: InputDecoration(hintText: 'Enter Product Weight'),
                  onChanged: (value)
                  {
                    itemWeight = value;


                  },
                ),
                SizedBox(height: 5.0,),
                TextField(
                  decoration: InputDecoration(hintText: 'Write a description'),
                  onChanged: (value)
                  {
                    description = value;

                  },
                ),
                SizedBox(height: 15.0,),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                      onPressed: ()
                      {
                        showDialog(context: context, builder: (context)
                        {
                          return LoadingAlertDialog(
                            message: 'Uploading...',
                          );
                        });
                        uploadFile().whenComplete(()
                        {

                          FirebaseFirestore.instance.
                          collection('products')
                              .doc(postId).set({
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


                          });

                        });

                      },
                      child: Text(
                        'Upload',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                )
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  return index == 0
                      ? Center(
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: ()
                      {
                        !uploading ? chooseImage() : null;
                        // Add functionality for adding images
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
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.green),
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'background.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SignUpBody(),
    );
  }
}

class SignUpBody extends StatefulWidget {
  const SignUpBody({super.key});

  @override
  State<SignUpBody> createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<SignUpBody> {
  File? _image;
  final signUpFormKey = GlobalKey<FormState>();
  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (croppedImage != null) {
      setState(() {
        _image = File(croppedImage.path);
      });
    }
  }

  void _shoeImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Plaese choose an option '),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            InkWell(
              onTap: () {
                _getFromCamera();
              },
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.camera, color: Colors.purple),
                  ),
                  Text('Camera', style: TextStyle(color: Colors.purple)),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                _getFromGallery();
              },
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.image, color: Colors.purple),
                  ),
                  Text('Gallery', style: TextStyle(color: Colors.purple)),
                ],
              ),
            )

          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SignupBackground(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: signUpFormKey,
              child: InkWell(
                onTap: () {_shoeImageDialog();},
                child: CircleAvatar(
                  radius: screenWidth * 0.20,
                  backgroundColor: Colors.white24,
                  backgroundImage: _image == null ? null : FileImage(_image!),
                  child: _image == null
                      ? Icon(Icons.camera_enhance,
                          size: screenWidth * 0.18, color: Colors.black54)
                      : null,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

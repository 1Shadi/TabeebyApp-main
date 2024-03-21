import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ForgetPassword/forget_password.dart';
import '../../core/Widgets/already_have_an_account_check.dart';
import '../../core/Widgets/rounded_button.dart';
import '../../core/Widgets/rounded_input_field.dart';
import '../../core/Widgets/rounded_password_field.dart';
import '../LoginScreen/login_screen.dart';
import 'background.dart';
import 'manager/sign_up_provider.dart';

class SignupBody extends StatefulWidget {
  const SignupBody({Key? key}) : super(key: key);

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignupProvider>(context);

    double screenHeight = MediaQuery.of(context).size.height;

    return SignupBackground(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: provider.signUpFormKey, // Use the signUpFormKey from the provider
              child: InkWell(
                onTap: () => provider.showImageDialog(context),
                child: CircleAvatar(
                  backgroundColor: Colors.white24,
                  backgroundImage: provider.image == null
                      ? null
                      : FileImage(provider.image!),
                  child: provider.image == null
                      ? Icon(
                    Icons.camera_enhance,
                    size: 80,
                    color: Colors.black,
                  )
                      : null,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            RoundedInputField(
              hintText: 'Name',
              icon: Icons.person,
              onChanged: (value) {
                _nameController.text = value;
              },
            ),
            RoundedInputField(
              hintText: 'Email',
              icon: Icons.person,
              onChanged: (value) {
                _emailController.text = value;
              },
            ),
            RoundedInputField(
              hintText: 'Phone Number',
              icon: Icons.phone_android,
              onChanged: (value) {
                _phoneController.text = value;
              },
            ),
            RoundedPasswordField(
              onChanged: (value) {
                _passwordController.text = value;
              },
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ForgetPassword()));
                },
                child: const Text(
                  'Forget Password',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Consumer<SignupProvider>(
              builder: (context, provider, _) => provider.isLoading
                  ? const Center(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(),
                ),
              )
                  : RoundedButton(
                text: 'SIGNUP',
                press: () {
                  provider.submitFormOnSignUp(
                    context,
                    provider.signUpFormKey,
                    _nameController.text.trim(),
                    _emailController.text.trim(),
                    _phoneController.text.trim(),
                    _passwordController.text.trim(),
                    provider.image,
                    _auth,
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

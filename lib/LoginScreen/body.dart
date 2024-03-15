import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tabeeby_app/DialogBox/loading_dialog.dart'; // Check this path
import 'package:tabeeby_app/ForgetPassword/forget_password.dart';
import 'package:tabeeby_app/HomeScreen/home_screen.dart';
import 'package:tabeeby_app/LoginScreen/background.dart';
import 'package:tabeeby_app/Widgets/already_have_an_account_check.dart';
import 'package:tabeeby_app/Widgets/rounded_button.dart';
import 'package:tabeeby_app/Widgets/rounded_input_field.dart';
import 'package:tabeeby_app/Widgets/rounded_password_field.dart';

import '../DialogBox/error_dialog.dart'; // Check this path
import '../SignupScreen/signup_screen.dart';

class LoginBody extends StatefulWidget {
  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _login() async {
    showDialog(
        context: context,
        builder: (_) {
          return LoadingAlertDialog(message: 'Please wait..');
        });
    User? currentUser;
    await _auth
        .signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return ErrorAlertDialog(message: error.message.toString());
          });
    });
    if (currentUser != null) {
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      print('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoginBackground(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.04),
            Image.asset(
              'assets/icons/login.png',
              height: size.height * 0.32,
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              hintText: 'Email',
              icon: Icons.person,
              onChanged: (value) {
                _emailController.text = value;
              },
            ),
            const SizedBox(height: 3),
            RoundedPasswordField(
              onChanged: (value) {
                _passwordController.text = value;
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgetPassword()),
                  );
                },
                child: const Text(
                  'Forgot your Password? ',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            RoundedButton(
              text: 'LOGIN',
              press: () {
                _emailController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty
                    ? _login()
                    : showDialog(
                    context: context,
                    builder: (context) {
                      return const ErrorAlertDialog(
                          message:
                          'Please write your email and password for login');
                    });
                // Add your login logic here
              },
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            AlreadyHaveAnAccountCheck(
              login: true,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

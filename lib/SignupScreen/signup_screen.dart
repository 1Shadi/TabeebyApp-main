import 'package:flutter/material.dart';
import 'package:tabeeby_app/SignupScreen/body.dart';

import 'background.dart';

class SignUpScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: SignupBody(),
      body: SignupBackground(child: UploadAdScreen(),),
    );
  }
}

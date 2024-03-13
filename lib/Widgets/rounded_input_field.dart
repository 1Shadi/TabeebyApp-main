import 'package:flutter/material.dart';
import 'package:tabeeby_app/Widgets/text_field_container.dart';

class RoundedInputField extends StatelessWidget {

  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;

  RoundedInputField({
    required this.hintText,
    this.icon = Icons.person,
    required this.onChanged,

});

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        onChanged: onChanged,
        cursorColor: Colors.teal,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: Colors.teal,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

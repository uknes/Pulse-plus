import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<CustomDialogButton> buttons;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.buttons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Nexa',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5EFF8B),
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          fontFamily: 'Nexa',
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      actions: buttons.map((button) {
        return TextButton(
          onPressed: button.onPressed,
          child: Text(
            button.label,
            style: TextStyle(color: Color(0xFF5EFF8B)),
          ),
        );
      }).toList(),
    );
  }
}

class CustomDialogButton {
  final String label;
  final VoidCallback onPressed;

  CustomDialogButton({
    required this.label,
    required this.onPressed,
  });
}

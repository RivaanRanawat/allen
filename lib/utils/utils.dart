import 'package:flutter/material.dart';

ScaffoldFeatureController ToastMessage(String text, BuildContext context) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

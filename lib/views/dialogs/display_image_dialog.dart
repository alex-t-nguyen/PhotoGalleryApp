import 'dart:io';

import 'package:flutter/material.dart';

class DisplayImageDialog extends StatelessWidget {
  final String photoPath;

  DisplayImageDialog({this.photoPath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
          child: Image.file(
        File(photoPath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      )),
    );
  }
}

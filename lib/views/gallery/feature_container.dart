import 'dart:io';

import 'package:flutter/material.dart';

class FeatureContainer extends StatelessWidget {
  final String path;
  final bool markDelete;

  FeatureContainer({this.path, this.markDelete});

  @override
  Widget build(BuildContext context) {
    return markDelete
        ? Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 20)),
            child: Image.file(
              File(path),
              width: 130.0,
              height: 130.0,
              fit: BoxFit.cover,
            ),
          )
        : Card(
            child: Image.file(
              File(path),
              width: 150.0,
              height: 150.0,
              fit: BoxFit.cover,
            ),
          );
  }
}

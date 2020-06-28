import 'package:flutter/material.dart';

class FeatureIcon extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final int data;
  final Color iconColor;

  FeatureIcon({this.icon, this.iconSize, this.data, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            //padding: const EdgeInsets.only(top: 25.0, bottom: 15.0),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
          Expanded(
            //flex: 1,
            //padding: const EdgeInsets.only(bottom: 25.0),
            child: Text(
              data.toString(),
              style: TextStyle(color: const Color(0xff565B5A)),
            ),
          ),
        ],
      ),
    );
  }
}

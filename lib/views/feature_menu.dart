import 'package:flutter/material.dart';

import 'Carousel.dart';
import './draggable_scroll_sheet/draggable_scroll_sheet.dart';

class FeatureMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feature Menu')),
      body: Stack(
        children: <Widget>[
          
          Container(
            color: const Color(0xff000000),
            child: Carousel()),
          // Can put container here to add space if needed
          DraggableScrollSheet(),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:gallery_app/components/album_floating_action_button.dart';

import '../components/Carousel.dart';
import './draggable_scroll_sheet/draggable_scroll_sheet.dart';

import 'package:gallery_app/providers/photo_provider.dart';

class FeatureMenu extends StatelessWidget {
  final PhotoProvider _photoProvider = PhotoProvider();

  @override
  Widget build(BuildContext context) {
    //_photoProvider.deleteDB();
    return Scaffold(
      appBar: AppBar(title: Text('Feature Menu')),
      body: Stack(
        children: <Widget>[
          Container(
            color: const Color(0xff000000),
            child: Carousel()),
          // Can put container here to add space if needed
          DraggableScrollSheet(),
          AlbumFloatingActionButton(),
        ],
      ),
    );
  }
}

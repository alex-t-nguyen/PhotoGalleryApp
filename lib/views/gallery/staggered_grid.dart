import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_size_getter/image_size_getter.dart';

import 'photo.dart';

class StaggeredGrid extends StatefulWidget {

  final List<Photo> photosList;
  final int numPhotos;

  StaggeredGrid({this.photosList, this.numPhotos});

  @override
  _StaggeredGridState createState() => _StaggeredGridState();
}

class _StaggeredGridState extends State<StaggeredGrid> {
  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(4.0),
      crossAxisCount: 4,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      itemCount: widget.photosList.length,
      itemBuilder: (BuildContext context, int index) => _buildGridTile(widget.photosList.length, index),
      staggeredTileBuilder: (int index) => StaggeredTile.count(2, 2),
    );
    
  }

/*
  List<Widget> _buildGridTiles(numPhotos) {
    List<Container> imageContainers =
        List<Container>.generate(numPhotos, (index) {
      return Container(
          child: Image.file(
        File(widget.photosList[index].photoPath),
        fit: BoxFit.cover,
      ));
    });
    return imageContainers;
  }
*/
  Container _buildGridTile(numPhotos, index) {
    return Container(
          child: Image.file(
        File(widget.photosList[index].photoPath),
        fit: BoxFit.cover,
      ));
  }

  int createImageHeight(index) {
    File file = File(widget.photosList[index].photoPath);
    final size = ImageSizGetter.getSize(file);
    if (size.height == size.width)
    {
      return 2;
    }
    else if (size.height > size.width)
    {
      return 4;
    }
    else
    {
      return 2;
    }
  }

  int createImageWidth(index) {
    File file = File(widget.photosList[index].photoPath);
    final size = ImageSizGetter.getSize(file);
    if (size.height == size.width)
    {
      return 2;
    }
    else if (size.width > size.height)
    {
      return 4;
    }
    else
    {
      return 2;
    }
  }
}

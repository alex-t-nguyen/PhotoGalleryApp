import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_app/gallery_icons.dart';
import 'package:gallery_app/providers/photo_provider.dart';
import 'models/photo.dart';

class StaggeredGrid extends StatefulWidget {
  final List<Photo> photosList;
  final int numPhotos;
  final String albumName;
  final VoidCallback deleteSelect;
  final bool deletion;
  final bool moving;

  StaggeredGrid(
      {this.photosList,
      this.numPhotos,
      this.albumName,
      this.deleteSelect,
      this.deletion,
      this.moving});

  @override
  _StaggeredGridState createState() => _StaggeredGridState();
}

class _StaggeredGridState extends State<StaggeredGrid> {
  final PhotoProvider _photoProvider = PhotoProvider();
  bool checkBoxValue;

  @override
  void initState() {
    checkBoxValue = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      padding: EdgeInsets.all(0.0),
      maxCrossAxisExtent: 150.0,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      //itemCount: widget.photosList.length,
      children: _buildGridTile(widget.photosList.length),
      //staggeredTileBuilder: (int index) => StaggeredTile.count(3, 3),
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
  List<Widget> _buildGridTile(numPhotos) {
    List<Stack> containers = new List<Stack>.generate(numPhotos, (int index) {
      return Stack(
        alignment: const Alignment(-1.0, 1.0),
        children: <Widget>[
          Container(
            child: Image.file(
              File(widget.photosList[index].photoPath),
              width: 150.0,
              height: 150.0,
              fit: BoxFit.cover,
            ),
          ),
          Align(  // Delete photo checkbox
              alignment: Alignment(-1.0, -1.0),
              child: Visibility(
                  visible: widget.deletion,
                  child: Checkbox(
                    value: widget.photosList[index].delete == 1 ? true : false,
                    onChanged: (value) {
                      setState(() {
                        markImageDelete(index);
                        //refreshImages();
                        widget.photosList[index].delete == 1
                            ? widget.photosList[index].delete = 0
                            : widget.photosList[index].delete = 1;
                      });
                    },
                  ))),
          Align(  // Move photo checkbox
              alignment: Alignment(-1.0, -1.0),
              child: Visibility(
                  visible: widget.moving,
                  child: Checkbox(
                    value: widget.photosList[index].move == 1 ? true : false,
                    onChanged: (value) {
                      setState(() {
                        markImageMove(index);
                        //refreshImages();
                        widget.photosList[index].move == 1
                            ? widget.photosList[index].move = 0
                            : widget.photosList[index].move = 1;
                      });
                    },
                  ))),
          Container(
            height: 30.0,
            width: 30.0,
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, .5),
            ),
            child: widget.photosList[index].favorite == 1
                ? IconButton(
                    iconSize: 16.0,
                    icon: Icon(
                      GalleryIcons.heart_full,
                      color: const Color(0xff01C699),
                    ),
                    onPressed: () {
                      //widget.deleteSelect();
                      favoriteImage(index);
                      //refreshImages();
                    },
                  )
                : IconButton(
                    icon: Icon(GalleryIcons.heart_empty,
                        color: const Color(0xff01C699)),
                    iconSize: 16.0,
                    onPressed: () {
                      //widget.deleteSelect();
                      favoriteImage(index);
                      //refreshImages();
                    },
                  ),
          ),
        ],
      );
    });
    return containers;
/*
    return Container(
        child: Stack(
      children: <Widget>[
        Image.file(
          File(widget.photosList[index].photoPath),
          fit: BoxFit.cover,
        ),
        Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              color: Color.fromRGBO(0, 0, 0, .7),
              //height: 40,
              //width: 40,
              child: _isFavorite
                  ? IconButton(
                      icon: Icon(
                        GalleryIcons.heart_full,
                        color: const Color(0xff01C699),
                      ),
                      onPressed: () => favoriteImage(_isFavorite, index),
                    )
                  : IconButton(
                      icon: Icon(GalleryIcons.heart_empty,
                          color: const Color(0xff01C699)),
                      onPressed: () => favoriteImage(_isFavorite, index)),
            )),
      ],
    ));
    */
  }

/*
  int createImageHeight(index) {
    File file = File(widget.photosList[index].photoPath);
    final size = ImageSizGetter.getSize(file);
    if (size.height == size.width) {
      return 2;
    } else if (size.height > size.width) {
      return 4;
    } else {
      return 2;
    }
  }

  int createImageWidth(index) {
    File file = File(widget.photosList[index].photoPath);
    final size = ImageSizGetter.getSize(file);
    if (size.height == size.width) {
      return 2;
    } else if (size.width > size.height) {
      return 4;
    } else {
      return 2;
    }
  }
*/
  void favoriteImage(int index) async {
    await _photoProvider.changeFavorite(widget.photosList[index].photoPath);
    refreshImages();
  }

  refreshImages() {
    _photoProvider.getPhotos(widget.albumName).then((imgs) {
      setState(() {
        widget.photosList.clear();
        widget.photosList.addAll(imgs);
      });
    });
  }

  markImageDelete(int index) async {
    await _photoProvider.markForDelete(widget.photosList[index].photoPath);
    //refreshImages();
  }

  markImageMove(int index) async  {
    await _photoProvider.markForMove(widget.photosList[index].photoPath);
  }
}

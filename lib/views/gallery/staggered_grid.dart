import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_app/gallery_icons.dart';
import 'package:gallery_app/providers/photo_provider.dart';
import 'package:gallery_app/views/dialogs/display_image_dialog.dart';
import 'models/photo.dart';

class StaggeredGrid extends StatefulWidget {
  final List<Photo> photosList;
  final int numPhotos;
  final String albumName;
  final VoidCallback deleteSelect;
  final bool deletion;
  final bool moving;
  final bool sharing;
  final double gridCrossAxisExtent;

  StaggeredGrid(
      {this.photosList,
      this.numPhotos,
      this.albumName,
      this.deleteSelect,
      this.deletion,
      this.moving,
      this.sharing,
      this.gridCrossAxisExtent});

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
    return widget.gridCrossAxisExtent != null && widget.gridCrossAxisExtent >= 0
        ? GridView.extent(
            padding: EdgeInsets.all(0.0),
            maxCrossAxisExtent: widget.gridCrossAxisExtent,
            mainAxisSpacing: 2.0,
            crossAxisSpacing: 2.0,
            children: _buildGridTile(widget.photosList.length),
          )
        : Center(
            child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(const Color(0xff01C699))));
  }

  List<Widget> _buildGridTile(numPhotos) {
    List<Stack> containers = new List<Stack>.generate(numPhotos, (int index) {
      return Stack(
        alignment: const Alignment(-1.0, 1.0),
        children: <Widget>[
          Container(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayImageDialog(photoPath: widget.photosList[index].photoPath))),
                          child: Image.file(
                File(widget.photosList[index].photoPath),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
              // Delete photos checkbox
              alignment: Alignment(-1.0, -1.0),
              child: Visibility(
                  visible: widget.deletion,
                  child: Checkbox(
                    value: widget.photosList[index].delete == 1 ? true : false,
                    onChanged: (value) {
                      setState(() {
                        markImageDelete(index);
                        widget.photosList[index].delete == 1
                            ? widget.photosList[index].delete = 0
                            : widget.photosList[index].delete = 1;
                      });
                    },
                  ))),
          Align(
              // Move photos checkbox
              alignment: Alignment(-1.0, -1.0),
              child: Visibility(
                  visible: widget.moving,
                  child: Checkbox(
                    value: widget.photosList[index].move == 1 ? true : false,
                    onChanged: (value) {
                      setState(() {
                        markImageMove(index);
                        widget.photosList[index].move == 1
                            ? widget.photosList[index].move = 0
                            : widget.photosList[index].move = 1;
                      });
                    },
                  ))),
          Align(
              // Share photos checkbox
              alignment: Alignment(-1.0, -1.0),
              child: Visibility(
                  visible: widget.sharing,
                  child: Checkbox(
                    value: widget.photosList[index].share == 1 ? true : false,
                    onChanged: (value) {
                      setState(() {
                        markImageShare(index);
                        widget.photosList[index].share == 1
                            ? widget.photosList[index].share = 0
                            : widget.photosList[index].share = 1;
                      });
                    },
                  ))),
          Container(
            height: widget.gridCrossAxisExtent / 5,
            width: widget.gridCrossAxisExtent / 5,
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, .5),
            ),
            child: widget.photosList[index].favorite == 1
                ? IconButton(
                    iconSize: widget.gridCrossAxisExtent * (8 / 75),
                    icon: Icon(
                      GalleryIcons.heart_full,
                      color: const Color(0xff01C699),
                    ),
                    onPressed: () {
                      favoriteImage(index);
                    },
                  )
                : IconButton(
                    icon: Icon(GalleryIcons.heart_empty,
                        color: const Color(0xff01C699)),
                    iconSize: widget.gridCrossAxisExtent * (8 / 75),
                    onPressed: () {
                      favoriteImage(index);
                    },
                  ),
          ),
        ],
      );
    });
    return containers;
  }

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
  }

  markImageMove(int index) async {
    await _photoProvider.markForMove(widget.photosList[index].photoPath);
  }

  markImageShare(int index) async {
    await _photoProvider.markForShare(widget.photosList[index].photoPath);
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_app/views/dialogs/move_photos_dialog.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gallery_app/providers/photo_provider.dart';

import 'models/photo.dart';
import 'staggered_grid.dart';
import 'models/photo_settings.dart';

class GridViewGallery extends StatefulWidget {
  final String itemHolder;
  final VoidCallback albumRefresh;

  GridViewGallery({Key key, @required this.itemHolder, this.albumRefresh})
      : super(key: key);

  @override
  _GridViewGalleryState createState() => _GridViewGalleryState();
}

class _GridViewGalleryState extends State<GridViewGallery> {
  Future<File> imageFile;
  File imagePath;
  PhotoProvider photoProvider;
  List<Photo> photosList;
  ImagePicker imagePicker;
  bool deletion;
  bool moving;
  final scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    photosList = [];
    photoProvider = PhotoProvider();
    imagePicker = ImagePicker();
    deletion = false;
    moving = false;
    refreshImages();
  }

  /// Get all images from database, then clear iamges list,
  /// then add new images from database into images list
  refreshImages() {
    photoProvider.getPhotos(widget.itemHolder).then((imgs) {
      setState(() {
        photosList.clear();
        photosList.addAll(imgs);
      });
    });
  }

  addImageFromGallery() async {
    var pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = File(pickedFile.path);
      });
      Photo photo = Photo(
          id: await photoProvider.getSize(),
          photoPath: pickedFile.path.toString(),
          album: widget.itemHolder,
          favorite: 0,
          delete: 0,
          move: 0);
      photoProvider.save(photo);
    }
    refreshImages();
  }

  deleteImageFromGallery() {
    setState(() {
      if (deletion) {
        photoProvider.resetDeletion();
        deletion = false;
      } else {
        deletion = true;
        refreshImages();
      }
    });
  }

  removeDeleteWhenLiked() {
    //setState(() {
    photoProvider.resetDeletion();
    deletion = false;
    //});
  }

  moveImageFromGallery() async {
    setState(() {
      if (moving) {
        photoProvider.resetMoving();
        moving = false;
      } else {
        moving = true;
        refreshImages();
      }
    });
  }

  shareImages() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text(widget.itemHolder),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              deleteImageFromGallery();
              moveImageFromGallery();
              deletion = false;
              moving = false;
              Navigator.pop(context);
            }),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                if (moving) {
                  moving = false;
                  Navigator.pop(context);
                }
                deleteImageFromGallery();
                showDeleteBottomSheet(scaffoldState, deletion);
              }),
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                if (moving || deletion) {
                  moving = false;
                  deletion = false;
                  Navigator.pop(context);
                }
                shareImages;
              }),
          PopupMenuButton<String>(
            onSelected: settingsAction,
            itemBuilder: (BuildContext context) {
              return PhotoSettings.photoSettingsList.map((String selection) {
                return PopupMenuItem<String>(
                    value: selection, child: Text(selection));
              }).toList();
            },
          ),
        ],
      ),
      body: StaggeredGrid(
        photosList: photosList,
        numPhotos: photosList.length,
        albumName: widget.itemHolder,
        deleteSelect: removeDeleteWhenLiked,
        deletion: deletion,
        moving: moving,
      ),
    );
  }

  void settingsAction(String selection) {
    if (selection == PhotoSettings.ADD) {
      if (moving || deletion) {
        moving = false;
        deletion = false;
        Navigator.pop(context);
      }
      addImageFromGallery();
    } else if (selection == PhotoSettings.MOVE) {
      if (deletion) {
        deletion = false;
        Navigator.pop(context);
      }
      moveImageFromGallery();
      showMoveBottomSheet(scaffoldState, moving);
    }
  }

  @override
  void dispose() {
    photoProvider.resetDeletion();
    super.dispose();
  }

  void showDeleteBottomSheet(GlobalKey<ScaffoldState> key, bool deletion) {
    if (deletion) {
      var bottomSheetController =
          key.currentState.showBottomSheet((context) => Container(
                color: Theme.of(context).canvasColor,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      topRight: const Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            deleteImageFromGallery();
                          },
                          child: Text('Cancel')),
                      FlatButton(
                          onPressed: () {
                            deleteImages(widget.itemHolder);
                            Navigator.pop(context);
                            deleteImageFromGallery();
                            widget.albumRefresh();
                          },
                          child: Text('Delete')),
                    ],
                  ),
                ),
              ));
      bottomSheetController.closed.then((value) {
        setState(() {
          deletion = false;
          refreshImages();
        });
      });
    } else {
      Navigator.pop(context);
    }
  }

  void showMoveBottomSheet(GlobalKey<ScaffoldState> key, bool move) {
    if (move) {
      var bottomSheetController =
          key.currentState.showBottomSheet((context) => Container(
                color: Theme.of(context).canvasColor,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      topRight: const Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            moveImageFromGallery();
                          },
                          child: Text('Cancel')),
                      FlatButton(
                          onPressed: () {
                            moveImages(widget.itemHolder);
                            //Navigator.pop(context);
                            //moveImageFromGallery();
                            refreshImages();
                            widget.albumRefresh();
                            //moveImageFromGallery();
                          },
                          child: Text('Move')),
                    ],
                  ),
                ),
              ));
      bottomSheetController.closed.then((value) {
        setState(() {
          moving = false;
          refreshImages();
        });
      });
    } else {
      Navigator.pop(context);
    }
  }

  void deleteImages(String albumName) async {
    await photoProvider.deleteImages(albumName);
    refreshImages();
  }

  void moveImagesD(String albumName, String destinationAlbum) async {
    await photoProvider.moveImages(albumName, destinationAlbum);
    refreshImages();
  }

  void moveImages(String albumOrigin) async {
    String albumDestination = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return MovePhotosDialog();
        });
    if (albumDestination != null) {
      await photoProvider.moveImages(albumOrigin, albumDestination);
    }
    Navigator.pop(context);
    moveImageFromGallery();
    refreshImages();
  }
}

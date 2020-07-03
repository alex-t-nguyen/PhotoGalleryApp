import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gallery_app/providers/photo_provider.dart';

import 'models/photo.dart';
import 'staggered_grid.dart';
import 'models/photo_settings.dart';

class GridViewGallery extends StatefulWidget {
  final String itemHolder;
  final VoidCallback albumRefresh;

  GridViewGallery({Key key, @required this.itemHolder, this.albumRefresh}) : super(key: key);

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
  final scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    photosList = [];
    photoProvider = PhotoProvider();
    imagePicker = ImagePicker();
    deletion = false;
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
          delete: 0);
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

  moveImageFromGallery() async {}

  shareImages() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text(widget.itemHolder),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteImageFromGallery();
                showDeleteBottomSheet(scaffoldState, deletion);
              }),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: shareImages,
          ),
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
      ),
    );
  }

  void settingsAction(String selection) {
    if (selection == PhotoSettings.ADD) {
      addImageFromGallery();
    } else if (selection == PhotoSettings.MOVE) {
      moveImageFromGallery();
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

  void deleteImages(String albumName) async {
    await photoProvider.deleteImages(albumName);
    refreshImages();
  }
}

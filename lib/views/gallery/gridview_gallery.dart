import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_app/views/dialogs/move_photos_dialog.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gallery_app/providers/photo_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

import 'models/photo.dart';
import 'staggered_grid.dart';
import 'models/photo_settings.dart';

class GridViewGallery extends StatefulWidget {
  final String itemHolder;
  final Function albumRefresh;

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
  bool sharing;
  double gridCrossAxisExtent;
  final scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    photosList = [];
    photoProvider = PhotoProvider();
    imagePicker = ImagePicker();
    deletion = false;
    moving = false;
    sharing = false;
    _assignInitialGridSize(); // initializes gridCrossAxisExtent
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
          move: 0,
          share: 0);
      photoProvider.save(photo);
    }
    widget.albumRefresh();
    refreshImages();
  }

  deleteImageFromGallery() async {
    setState(() {
      if (deletion) {
        photoProvider.resetDeletion();
        deletion = false;
      } else {
        deletion = true;
        refreshImages();
      }
    });
    widget.albumRefresh();
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
    widget.albumRefresh();
  }

  shareImageFromGallery() async {
    setState(() {
      if (sharing) {
        photoProvider.resetSharing();
        sharing = false;
      } else {
        sharing = true;
        refreshImages();
      }
    });
    widget.albumRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        deleteImageFromGallery();
        moveImageFromGallery();
        deletion = false;
        moving = false;
        Navigator.pop(context, true);
        return;
      },
          child: Scaffold(
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
                sharing = false;
                Navigator.pop(context, true);
              }),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  if (moving || sharing) {
                    moving = false;
                    sharing = false;
                    Navigator.pop(context, true);
                  }
                  deleteImageFromGallery();
                  showDeleteBottomSheet(scaffoldState, deletion);
                }),
            IconButton(
                icon: Icon(Icons.apps),
                onPressed: () {
                  if (moving || deletion) {
                    moving = false;
                    deletion = false;
                    Navigator.pop(context);
                  }
                  changeGridSize();
                  //shareImageFromGallery();
                  //showShareBottomSheet(scaffoldState, sharing);
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
          deletion: deletion,
          moving: moving,
          sharing: sharing,
          gridCrossAxisExtent: gridCrossAxisExtent,
        ),
      ),
    );
  }
/*
  void changeGridSize() {
    setState(() {
      if (gridCrossAxisExtent == 150)
        gridCrossAxisExtent = 225;
      else if (gridCrossAxisExtent == 225)
        gridCrossAxisExtent = MediaQuery.of(context).size.width;
      else
        gridCrossAxisExtent = 150;
    });
  }*/

  void settingsAction(String selection) {
    if (selection == PhotoSettings.ADD) {
      if (moving || deletion || sharing) {
        moving = false;
        deletion = false;
        sharing = false;
        Navigator.pop(context);
      }
      addImageFromGallery();
    } else if (selection == PhotoSettings.MOVE) {
      if (deletion || sharing) {
        deletion = false;
        sharing = false;
        Navigator.pop(context);
      }
      moveImageFromGallery();
      showMoveBottomSheet(scaffoldState, moving);
    }
  }

  @override
  void dispose() {
    photoProvider.resetDeletion();
    photoProvider.resetMoving();
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
                            //Navigator.pop(context);
                            //deleteImageFromGallery();
                            widget.albumRefresh();
                            refreshImages();
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
                            widget.albumRefresh();
                            refreshImages();
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

  void showShareBottomSheet(GlobalKey<ScaffoldState> key, bool sharing) {
    if (sharing) {
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
                            shareImageFromGallery();
                          },
                          child: Text('Cancel')),
                      FlatButton(
                          onPressed: () {
                            shareImages(context);
                            Navigator.pop(context);
                            widget.albumRefresh();
                            shareImageFromGallery();
                          },
                          child: Text('Share')),
                    ],
                  ),
                ),
              ));
      bottomSheetController.closed.then((value) {
        setState(() {
          sharing = false;
          refreshImages();
        });
      });
    } else {
      Navigator.pop(context);
    }
  }

  void deleteImages(String albumName) async {
    await photoProvider.deleteImages(albumName);
    Navigator.pop(context);
    deleteImageFromGallery();
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

  void shareImages(BuildContext context) async {
    List<Photo> photosList = await photoProvider.getSharedImages();
    debugPrint("Length " + photosList.length.toString());
    if (photosList != null && photosList.length > 0) {
      for (Photo photo in photosList) {
        final ByteData bytes =
            ByteData.view(File(photo.photoPath).readAsBytesSync().buffer);
        await WcFlutterShare.share(
            sharePopupTitle: 'Share',
            fileName: ' ',
            mimeType: 'image/png',
            bytesOfFile: bytes.buffer.asUint8List());
      }
    }
    refreshImages();
  }

  Future<double> getGridSizeFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final gridSize = prefs.getDouble('gridSize');
    if (gridSize == null) {
      return 150.0;
    }
    return gridSize;
  }

  Future<void> changeGridSize() async {
    final prefs = await SharedPreferences.getInstance();

    double previousGridSize = await getGridSizeFromSharedPref();
    setState(() {
      if (previousGridSize == 225.0)
        gridCrossAxisExtent = MediaQuery.of(context).size.width;
      else if (previousGridSize== 150.0)
        gridCrossAxisExtent = 225.0;
      else
        gridCrossAxisExtent = 150.0;
    });

    await prefs.setDouble('gridSize', gridCrossAxisExtent);
  }

  _assignInitialGridSize() async {
    final prefs = await SharedPreferences.getInstance();
    final gridSize = prefs.getDouble('gridSize');
    setState(() {
      if (gridSize == null) {
        gridCrossAxisExtent = 150.0;
      }
      else
        gridCrossAxisExtent = gridSize;
    });
  }
}

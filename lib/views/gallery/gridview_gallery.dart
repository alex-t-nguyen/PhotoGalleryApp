import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gallery_app/providers/photo_provider.dart';

import 'models/photo.dart';
import 'staggered_grid.dart';
import 'models/photo_settings.dart';

class GridViewGallery extends StatefulWidget {
  final String itemHolder;

  GridViewGallery({Key key, @required this.itemHolder}) : super(key: key);

  @override
  _GridViewGalleryState createState() => _GridViewGalleryState();
}

class _GridViewGalleryState extends State<GridViewGallery> {
  Future<File> imageFile;
  File imagePath;
  PhotoProvider photoProvider;
  List<Photo> photosList;
  ImagePicker imagePicker;

  @override
  void initState() {
    super.initState();
    photosList = [];
    photoProvider = PhotoProvider();
    imagePicker = ImagePicker();
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
          favorite: 0);
      photoProvider.save(photo);
    }
    refreshImages();
  }

  deleteImageFromGallery() async {}

  moveImageFromGallery() async {}

  shareImages() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemHolder),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete), onPressed: deleteImageFromGallery),
          IconButton(icon: Icon(Icons.share), onPressed: shareImages,),
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
      body: StaggeredGrid(photosList: photosList, numPhotos: photosList.length, albumName: widget.itemHolder,),
    );
  }

/*
  List<Widget> _buildGridTiles(numPhotos) {
    List<Container> imageContainers =
        List<Container>.generate(numPhotos, (index) {
      return Container(
          child: Image.file(
        File(photosList[index].photoPath),
        fit: BoxFit.cover,
      ));
    });
    return imageContainers;
  }
  */

  void settingsAction(String selection) {
    if (selection == PhotoSettings.ADD) {
      addImageFromGallery();
    } else if (selection == PhotoSettings.MOVE) {
      moveImageFromGallery();
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gallery_app/providers/photo_provider.dart';

import 'models/photo.dart';
import 'staggered_grid.dart';

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
    setState(() {
      imagePath = File(pickedFile.path);
    });
    Photo photo = Photo(
        //id: await photoProvider.getSize(),
        photoPath: pickedFile.path.toString(),
        album: widget.itemHolder,
        favorite: 0);
    photoProvider.save(photo);
    refreshImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemHolder),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: addImageFromGallery),
        ],
      ),
      body: StaggeredGrid(photosList: photosList, numPhotos: photosList.length),
      /*
      StaggeredGridView.extent(
        maxCrossAxisExtent: MediaQuery.of(context).size.width,
        children: _buildGridTiles(photosList.length)),
          Padding(
              padding: EdgeInsets.all(3.0),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                children: photosList.map((photo) {
                  return Image.file(File(photo.photoPath));
                }).toList(),
              )),*/

      //),
    );
  }
  
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
}

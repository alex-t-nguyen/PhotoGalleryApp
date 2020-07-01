import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gallery_app/gallery_icons.dart';
import 'package:gallery_app/providers/photo_provider.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'models/photo.dart';

class StaggeredGrid extends StatefulWidget {
  final List<Photo> photosList;
  final int numPhotos;
  final String albumName;

  StaggeredGrid({this.photosList, this.numPhotos, this.albumName});

  @override
  _StaggeredGridState createState() => _StaggeredGridState();
}

class _StaggeredGridState extends State<StaggeredGrid> {
  final PhotoProvider _photoProvider = PhotoProvider();

  @override
  void initState() {
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
      /*
      _photoProvider
          .checkFavorite(widget.photosList[index].photoPath)
          .then((favorite) {
        
          debugPrint('Favorite: ' + favorite.toString());
          _isFavorite = favorite;
     
      });
      */
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
                      favoriteImage(index);
                      refreshImages();
                    },
                  )
                : IconButton(
                    icon: Icon(GalleryIcons.heart_empty,
                        color: const Color(0xff01C699)),
                    iconSize: 16.0,
                    onPressed: () {
                      favoriteImage(index);
                      refreshImages();
                    },),
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
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'models/album.dart';
import 'package:gallery_app/providers/photo_provider.dart';

import 'models/photo.dart';

class AlbumContainer extends StatefulWidget {
  final int index;
  final String albumTitle;
  final int albumNumPhotos;

  AlbumContainer({this.index, this.albumTitle, this.albumNumPhotos});

  @override
  _AlbumContainerState createState() => _AlbumContainerState();
}

class _AlbumContainerState extends State<AlbumContainer> {
  PhotoProvider _photoProvider;
  List<Album> albumList;
  List<Photo> photoList;

  /*
  List<Album> albumList = [
    Album("Empty album", 0),
    Album("Camera", 0),
    Album("Favorites", 1),
    Album("Download", 0),
    Album("Instagram", 0),
    Album("Photography", 0),
  ];
  */

  @override
  initState() {
    super.initState();
    albumList = [];
    photoList = [];
    _photoProvider = PhotoProvider();
    _getImageList();
  }

  @override
  void didUpdateWidget(AlbumContainer oldWidget) {
    _photoProvider.getPhotos(widget.albumTitle).then((value) {
      photoList.clear();
      photoList.addAll(value);
    });
    super.didUpdateWidget(oldWidget);
  }

  _getImageList() async {
    await _photoProvider.getPhotos(widget.albumTitle).then((value) {
      setState(() {
        photoList.clear();
        photoList.addAll(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            //colorFilter: ColorFilter.mode(Colors.white.withOpacity(1), BlendMode.dstATop),
            image: photoList.length > 0 ? FileImage(File(photoList[0].photoPath)) : NetworkImage('https://www.solidbackgrounds.com/images/950x350/950x350-black-solid-color-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Card(     
          color: Colors.transparent,  
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 80.0, bottom: 4.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        widget.albumTitle,
                        style: TextStyle(fontSize: 23.0, color: Colors.white),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.photo_library, color: Colors.white),
                      Text(
                        ' ' + widget.albumNumPhotos.toString(),
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                      Text(
                        widget.albumNumPhotos != 1 ? ' photos' : ' photo',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                      Spacer(),
                    ],
                  ),
                )
              ],
            )));
  }

  Future<String> getAlbumTitle(index) async {
    Album album = await _photoProvider.getAlbum(index);
    //debugPrint('Album Title: ' + album.title);
    return album.title;
  }

  Future<int> getAlbumNumPhotos(index) async {
    Album album = await _photoProvider.getAlbum(index);
    //debugPrint('Album Number of Photos: ' + album.numPhotos.toString());
    return album.numPhotos;
  }
}

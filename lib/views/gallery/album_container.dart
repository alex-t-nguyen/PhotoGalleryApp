import 'package:flutter/material.dart';
import 'models/album.dart';
import 'package:gallery_app/providers/photo_provider.dart';

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
    _photoProvider = PhotoProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
            color: const Color(0xff000000),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 80.0, bottom: 4.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        widget.albumTitle,
                        style: TextStyle(fontSize: 23.0, color: Colors.white60),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.photo_library, color: Colors.white60),
                      Text(
                        ' ' + widget.albumNumPhotos.toString(),
                        style: TextStyle(fontSize: 18.0, color: Colors.white60),
                      ),
                      Text(
                        widget.albumNumPhotos != 1 ? ' photos' : ' photo',
                        style: TextStyle(fontSize: 18.0, color: Colors.white60),
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

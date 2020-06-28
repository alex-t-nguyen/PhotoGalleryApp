import 'package:flutter/material.dart';
import 'models/album.dart';
import 'package:gallery_app/providers/photo_provider.dart';

class AlbumContainer extends StatefulWidget {

  final int index;

  AlbumContainer(this.index);

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
    refreshAlbums();
  }

  refreshAlbums() {
    _photoProvider.getAlbumList().then((albums) {
      setState(() {
        albumList.clear();
        albumList.addAll(albums);
      });
    });
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
                        albumList[widget.index].title,
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
                        " " + albumList[widget.index].numPhotos.toString(),
                        style: TextStyle(fontSize: 18.0, color: Colors.white60),
                      ),
                      Text(
                        albumList[widget.index].numPhotos != 1 ? ' photos' : ' photo',
                        style: TextStyle(fontSize: 18.0, color: Colors.white60),
                      ),
                      Spacer(),
                    ],
                  ),
                )
              ],
            )));
  }
}
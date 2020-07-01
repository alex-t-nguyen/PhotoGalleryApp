
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:gallery_app/providers/photo_provider.dart';
import 'package:gallery_app/views/dialogs/add_album_dialog.dart';
import 'package:gallery_app/views/dialogs/delete_album_dialog.dart';
import 'package:gallery_app/views/gallery/models/album.dart';

class AlbumFloatingActionButton extends StatefulWidget {
  @override
  _AlbumFloatingActionButtonState createState() =>
      _AlbumFloatingActionButtonState();
}

class _AlbumFloatingActionButtonState extends State<AlbumFloatingActionButton> {
  PhotoProvider _photoProvider;
  List<Album> albumList;
  bool addAlbumFlag = false;

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

  _addAlbum() async {
    String albumTitle = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddAlbumDialog();
        });
    if (albumTitle != null) {
      Album album = Album(
        id: await _photoProvider.getNumAlbums(),
        title: albumTitle,
        numPhotos: 0,
      );
      _photoProvider.saveAlbum(album);
    }
  }

  _deleteAlbum() async {
    String albumTitle = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteAlbumDialog();
        });
    if (albumTitle != null) {
      _photoProvider.deleteAlbum(albumTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        closeManually: false,
        child: Icon(Icons.menu),
        overlayColor: Colors.black,
        overlayOpacity: 0.2,
        curve: Curves.easeIn,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            label: "Add album",
            backgroundColor: Colors.green,
            labelBackgroundColor: Colors.white70,
            onTap: () => _addAlbum(),
          ),
          SpeedDialChild(
            child: Icon(Icons.delete_outline),
            backgroundColor: Colors.red,
            labelBackgroundColor: Colors.white70,
            label: "Delete album",
            onTap: () => _deleteAlbum(),
          )
        ],
      ),
    );
  }
}

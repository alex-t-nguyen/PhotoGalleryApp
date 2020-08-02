
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:gallery_app/providers/photo_provider.dart';
import 'package:gallery_app/views/dialogs/add_album_dialog.dart';
import 'package:gallery_app/views/dialogs/delete_album_dialog.dart';
import 'package:gallery_app/views/dialogs/delete_feature_dialog.dart';
import 'package:gallery_app/views/gallery/models/album.dart';
import 'package:gallery_app/views/gallery/models/feature_photo.dart';
import 'package:image_picker/image_picker.dart';

class AlbumFloatingActionButton extends StatefulWidget {
  final Function refreshMenu;

  AlbumFloatingActionButton({this.refreshMenu});

  @override
  _AlbumFloatingActionButtonState createState() =>
      _AlbumFloatingActionButtonState();
}

class _AlbumFloatingActionButtonState extends State<AlbumFloatingActionButton> {
  PhotoProvider _photoProvider;
  List<Album> albumList;
  bool addAlbumFlag = false;
  
  final ImagePicker _imagePicker = ImagePicker();

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
      widget.refreshMenu();
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
      widget.refreshMenu();
    }
  }

  _addFeature() async {
    var pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        FeaturePhoto feature = FeaturePhoto(
            id: await _photoProvider.getSize(),
            path: pickedFile.path,
            delete: 0);
        _photoProvider.addFeatureImage(feature);
        widget.refreshMenu();
      }
  }

  _deleteFeature() async {
    bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteFeatureDialog();
        });
    if (confirmDelete != null && confirmDelete) {
      await _photoProvider.deleteFeatures();
    }
    await _photoProvider.resetDeleteFeatures();
    widget.refreshMenu();
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      marginBottom: 32.0,
      marginRight: 32.0,
      animatedIcon: AnimatedIcons.menu_close,
      closeManually: false,
      child: Icon(Icons.menu),
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
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
          child: Icon(Icons.remove),
          backgroundColor: Colors.red,
          labelBackgroundColor: Colors.white70,
          label: "Delete album",
          onTap: () => _deleteAlbum(),
        ),
        SpeedDialChild(
          child: Icon(Icons.image),
          backgroundColor: Colors.blueAccent,
          labelBackgroundColor: Colors.white70,
          label: "Add feature",
          onTap: () => _addFeature(),
        ),
        SpeedDialChild(
          child: Icon(Icons.delete_outline),
          backgroundColor: Colors.redAccent,
          labelBackgroundColor: Colors.white70,
          label: "Delete feature",
          onTap: () => _deleteFeature(),
        ),
      ],
    );
  }
}

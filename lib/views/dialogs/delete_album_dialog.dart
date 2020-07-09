import 'package:flutter/material.dart';
import 'package:gallery_app/providers/photo_provider.dart';
import 'package:gallery_app/views/gallery/models/album.dart';

class DeleteAlbumDialog extends StatefulWidget {
  @override
  _DeleteAlbumDialogState createState() => _DeleteAlbumDialogState();
}

class _DeleteAlbumDialogState extends State<DeleteAlbumDialog> {
  PhotoProvider _photoProvider = PhotoProvider();

  List<Album> _albumsList = [];
  List<DropdownMenuItem<Album>> _dropdownMenuItems = [];
  Album _selectedAlbum;

  @override
  void initState() {
    getAlbums();
    //debugPrint('Test: ' + _albumsList.toString());
    super.initState();
  }

  getAlbums() {
    _photoProvider.getAlbumList().then((albums) {
      setState(() {
        _albumsList.clear();
        _albumsList.addAll(albums);
        _dropdownMenuItems = buildDropdownMenuItems(_albumsList);
        _selectedAlbum = _dropdownMenuItems[0].value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //_selectedAlbum = _dropdownMenuItems[0].value;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(top: 66),
      decoration: new BoxDecoration(
        color: const Color(0xff333333),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Select an album', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          DropdownButton(
            value: _selectedAlbum,
            items: _dropdownMenuItems,
            onChanged: onChangeDropdownItem,
            style: TextStyle(color: Colors.white),
            dropdownColor: Colors.black87,           
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  )),
              FlatButton(
                  onPressed: () {
                    if(_selectedAlbum.title != 'Select album')
                      Navigator.pop(context, _selectedAlbum.title);
                  },
                  child: Text(
                    'Delete album',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  onChangeDropdownItem(Album selectedAlbum) {
    setState(() {
      _selectedAlbum = selectedAlbum;
    });
  }

  List<DropdownMenuItem<Album>> buildDropdownMenuItems(List<Album> albums) {
    List<DropdownMenuItem<Album>> items = List();
    for (int i = 0; i < albums.length; i++) {
      items.add(
        DropdownMenuItem(
          value: albums[i],
          child: Text(albums[i].title),
        ),
      );
    }
    return items;
  }
}

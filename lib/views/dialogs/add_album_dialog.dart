
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_app/providers/photo_provider.dart';
import 'package:gallery_app/views/gallery/models/album.dart';

class AddAlbumDialog extends StatefulWidget {
  @override
  _AddAlbumDialogState createState() => _AddAlbumDialogState();
}

class _AddAlbumDialogState extends State<AddAlbumDialog> {
  final TextEditingController textController = new TextEditingController();
  final PhotoProvider _photoProvider = PhotoProvider();

  bool _validate = false;
  String textError = '';
  List<Album> albums = [];

  @override
  Widget build(BuildContext context) {
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
          TextFormField(
            autofocus: true,
            style: TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
                labelText: 'Album name',
                hintStyle: TextStyle(color: Colors.white),
                errorText: _validate ? textError : null),
            controller: textController,
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
                    isValidName();
                    if (!_validate) Navigator.pop(context, textController.text);
                  },
                  child: Text(
                    'Add album',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  void isValidName() {
    _photoProvider.getAlbumList().then((value) {
      setState(() {
        albums.clear();
        albums.addAll(value);
        _validate = false;
        textError = '';
      });
    });
    if (textController.text.isEmpty) {
      setState(() {
        textError = 'Field cannot be empty';
        _validate = true;
      });
    }
    for (Album album in albums) {
      if (album.title == textController.text) {
        setState(() {
          textError = 'Album name already exists';
          _validate = true;
        });
        break;
      }
    }
  }
}

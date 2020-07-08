import 'package:flutter/material.dart';

import 'package:gallery_app/providers/photo_provider.dart';
import 'package:gallery_app/views/gallery/album_container.dart';
import 'package:gallery_app/views/gallery/gridview_gallery.dart';
import 'package:gallery_app/gallery_icons.dart';
import 'package:gallery_app/views/gallery/models/album.dart';
import 'package:gallery_app/views/gallery/feature_icon.dart';

class DraggableScrollSheet extends StatefulWidget {
  final int totalPhotos;
  final int numFavoritePhotos;

  DraggableScrollSheet({this.totalPhotos, this.numFavoritePhotos});

  @override
  _DraggableScrollSheetState createState() => _DraggableScrollSheetState();
}

class _DraggableScrollSheetState extends State<DraggableScrollSheet> {
  PhotoProvider _photoProvider;
  List<Album> albumList;

  List<int> photoData;

  /*
    final List<Album> albumList = [
    Album(title: "Empty album", numPhotos: 0),
    Album(title: "Camera", numPhotos: 0),
    Album(title: "Favorites", numPhotos: 1),
    Album(title: "Download", numPhotos: 0),
    Album(title: "Instagram", numPhotos: 0),
    Album(title: "Photography", numPhotos: 0),
  ];
  */

  @override
  initState() {
    super.initState();
    albumList = [];
    _photoProvider = PhotoProvider();
    photoData = [0, 0];
    //refreshAlbums();
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
    _photoProvider.getPhotoData().then((value) {
      photoData = value;
    });
    return Container(
        height: MediaQuery.of(context).size.height,
        child: DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.55,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: const Color(0xff141518),
                    child: FutureBuilder<List>(
                      future: _photoProvider.getAlbumList(),
                      builder:
                          (BuildContext context, AsyncSnapshot<List> snapshot) {
                        if (snapshot.hasData) {
                          refreshAlbums();
                          return ListView.builder(
                              controller: scrollController,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  return Container(
                                    color: const Color(0xff000000),
                                    height: 80.0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, //Center Row contents horizontally
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center, //Center Row contents vertically
                                      children: <Widget>[
                                        FeatureIcon(
                                          icon: GalleryIcons.picture_outline,
                                          iconSize: 20,
                                          data: photoData[1],
                                          iconColor: const Color(0xff01C699),
                                        ),
                                        FeatureIcon(
                                          icon: GalleryIcons.heart_empty,
                                          iconSize: 20,
                                          data: photoData[0],
                                          iconColor: const Color(0xff01C699),
                                        ),
                                        FeatureIcon(
                                          icon: GalleryIcons.album,
                                          iconSize: 20,
                                          data: snapshot.data.length - 1,
                                          iconColor: const Color(0xff01C699),
                                        ),
                                      ],
                                    ),
                                  );
                                }                              
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GridViewGallery(
                                                      itemHolder:
                                                          albumList[index]
                                                              .title, albumRefresh: refreshAlbums,)));
                                    },
                                    child: AlbumContainer(
                                      index: index,
                                      albumTitle: snapshot.data[index].title,
                                      albumNumPhotos: snapshot.data[index].numPhotos,
                                    ));
                              });
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xff01C699)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ));
  }

  Future<String> getAlbumTitle(index) async {
    Album album = await _photoProvider.getAlbum(index);
    return album.title;
  }

  Future<int> getAlbumNumPhotos(index) async {
    Album album = await _photoProvider.getAlbum(index);
    return album.numPhotos;
  }
/*
  Widget buildAlbum(BuildContext context, int index) {
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
                        albumList[index].title,
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
                        " " + albumList[index].numPhotos.toString(),
                        style: TextStyle(fontSize: 18.0, color: Colors.white60),
                      ),
                      Text(
                        albumList[index].numPhotos != 1 ? ' photos' : ' photo',
                        style: TextStyle(fontSize: 18.0, color: Colors.white60),
                      ),
                      Spacer(),
                    ],
                  ),
                )
              ],
            )));
  }
  */
}

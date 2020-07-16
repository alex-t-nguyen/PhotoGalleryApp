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
  Future<List<Album>> albums;
  int counter;

  @override
  initState() {
    super.initState();
    albumList = [];
    _photoProvider = PhotoProvider();
    photoData = [0, 0];
    albums = _getAlbums();
    refreshAlbums();
  }

  @override
  void didUpdateWidget(DraggableScrollSheet oldWidget) {
    _photoProvider.getAlbumList().then((value) {
      setState(() {
        albumList.clear();
        albumList.addAll(value);
        albums = _getAlbums();
      });
    });
    super.didUpdateWidget(oldWidget);
  }

  refreshAlbums() {
    _photoProvider.getAlbumList().then((albums) {
      setState(() {
        //albumList.clear();
        //albumList.addAll(albums);
        getNumFavorites().then((value) => photoData[0] = value);
        getNumPhotos().then((value) => photoData[1] = value);
        this.albums = _getAlbums();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        child: DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.45,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: const Color(0xff0e0e0e),
                    child: FutureBuilder<List>(
                      future: albums,
                      builder:
                          (BuildContext context, AsyncSnapshot<List> snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              controller: scrollController,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  return Container(
                                    color: const Color(0xff0e0e0e),
                                    width: MediaQuery.of(context).size.width,
                                    height: 70.0,
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
                                                    itemHolder: snapshot
                                                        .data[index].title,
                                                    albumRefresh: updateAlbums,
                                                  ))).then((value) {
                                        value || value == null
                                            ? updateAlbums()
                                            : debugPrint("No update");
                                      });
                                    },
                                    child: AlbumContainer(
                                      index: index,
                                      albumTitle: snapshot.data[index].title,
                                      albumNumPhotos:
                                          snapshot.data[index].numPhotos,
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

  Future<List<Album>> _getAlbums() async {
    return await _photoProvider.getAlbumList();
  }

  Future<int> getNumPhotos() async {
    return await _photoProvider.getSize();
  }

  Future<int> getNumFavorites() async {
    return await _photoProvider.getNumFavorite();
  }

  void updateAlbums() {
    setState(() {
      getNumFavorites().then((value) => photoData[0] = value);
      getNumPhotos().then((value) => photoData[1] = value);
      albums = _getAlbums();
    });
  }
}

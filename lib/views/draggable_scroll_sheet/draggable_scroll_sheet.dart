import 'package:flutter/material.dart';

import 'package:gallery_app/views/gallery/album_container.dart';
import 'package:gallery_app/views/gallery/gridview_gallery.dart';
import 'package:gallery_app/gallery_icons.dart';
import 'package:gallery_app/views/gallery/models/album.dart';
import 'package:gallery_app/views/gallery/feature_icon.dart';

class DraggableScrollSheet extends StatefulWidget {
  @override
  _DraggableScrollSheetState createState() => _DraggableScrollSheetState();
}

class _DraggableScrollSheetState extends State<DraggableScrollSheet> {
  final List<Album> albumList = [
    Album(title: "Empty album", numPhotos: 0),
    Album(title: "Camera", numPhotos: 0),
    Album(title: "Favorites", numPhotos: 1),
    Album(title: "Download", numPhotos: 0),
    Album(title: "Instagram", numPhotos: 0),
    Album(title: "Photography", numPhotos: 0),
  ];

  @override
  Widget build(BuildContext context) {
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
                    child: ListView.builder(
                        controller: scrollController,
                        itemCount: albumList.length,
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
                                    data: 69,
                                    iconColor: const Color(0xff01C699),
                                  ),
                                  FeatureIcon(
                                    icon: GalleryIcons.heart_empty,
                                    iconSize: 20,
                                    data: 1,
                                    iconColor: const Color(0xff01C699),
                                  ),
                                  FeatureIcon(
                                    icon: GalleryIcons.album,
                                    iconSize: 20,
                                    data: albumList.length,
                                    iconColor: const Color(0xff01C699),
                                  ),
                                  /*
                                  new Expanded(
                                    child: Icon(GalleryIcons.picture_outline,
                                        color: const Color(0xff01C699),
                                        size: 20),
                                  ),
                                  new Expanded(
                                    child: Icon(GalleryIcons.heart_empty,
                                        color: const Color(0xff01C699),
                                        size: 20),
                                  ),
                                  new Expanded(
                                    child: Icon(GalleryIcons.album,
                                        color: const Color(0xff01C699),
                                        size: 20),
                                  ),*/
                                ],
                              ),
                            );
                          }
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GridViewGallery(
                                            itemHolder:
                                                albumList[index].title)));
                              },
                              child: AlbumContainer(index));
                        }),
                  ),
                ),
              ],
            );
          },
        ));
  }

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
}

import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
import 'package:gallery_app/views/gallery/models/album.dart';
import 'package:gallery_app/views/gallery/models/photo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class PhotoProvider {
  static Database _db;
  static const String ID = 'id';
  static const String PATH = 'photoPath';
  static const String ALBUM = 'album';
  static const String FAVORITE_NAME = 'favorite';
  static const String ALBUM_ID = 'albumID';
  static const String ALBUM_LIST = 'title';
  static const String ALBUM_PHOTO_NUM = 'numPhotos';
  static const String TABLE = 'PhotosTable';
  static const String DB_NAME = 'photos.db';

  Future<Database> get db async {
    if (null != _db) {
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  Future<void> deleteDB() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);

    await deleteDatabase(path);
  }

  initDB() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $TABLE ($ID INTEGER, $PATH TEXT, $ALBUM TEXT, $FAVORITE_NAME INTEGER, $ALBUM_ID INTEGER, $ALBUM_LIST TEXT, $ALBUM_PHOTO_NUM INTEGER)');
    db.rawInsert(
        'INSERT INTO $TABLE ($ALBUM_ID, $ALBUM_LIST, $ALBUM_PHOTO_NUM) VALUES(?, ?, ?)',
        [0, 'Select album', 0]);
  }

  Future<Photo> save(Photo photo) async {
    var dbClient = await db;
    photo.id = await dbClient.insert(TABLE, photo.toMap());
    List<Album> albumList = await getAlbumList();
    Album temp = Album();
    for (int i = 0; i < albumList.length; i++) {
      if (albumList[i].title == photo.album) {
        temp = albumList[i];
        break;
      }
    }
    temp.numPhotos += 1;
    await dbClient.update(TABLE, temp.toMap(),
        where: '$ALBUM_LIST = ?', whereArgs: [photo.album]);
    return photo;
  }

  Future<List<Photo>> getPhotos(String albumName) async {
    var dbClient = await db; // call database getter function
    List<Map> maps =
        await dbClient.query(TABLE, columns: [ID, PATH, ALBUM, FAVORITE_NAME]);
    List<Photo> photos = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        if (Photo.fromMap(maps[i]).photoPath != null &&
            Photo.fromMap(maps[i]).album == albumName)
          photos.add(Photo.fromMap(maps[i]));
      }
    }
    return photos;
  }

  Future<int> getSize() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT($PATH) FROM $TABLE'));
  }

  Future<List<Album>> getAlbumList() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(TABLE, columns: [ALBUM_ID, ALBUM_LIST, ALBUM_PHOTO_NUM]);
    List<Album> albums = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        if (Album.fromMap(maps[i]).title != null)
          albums.add(Album.fromMap(maps[i]));
      }
    }
    return albums;
  }

  Future<List<Photo>> getPhotosList() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ID, PATH, ALBUM, FAVORITE_NAME]);
    List<Photo> photos = [];
    if(maps.length > 0) {
      for(int i = 0; i < maps.length; i++) {
        if(Photo.fromMap(maps[i]).photoPath != null)
          photos.add(Photo.fromMap(maps[i]));
      }
    }
    return photos;
  }

  Future<Album> saveAlbum(Album album) async {
    var dbClient = await db;
    album.id = await dbClient.insert(TABLE, album.toMap());
    return album;
  }

  Future<int> getNumPhotosInAlbum(String albumName) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ALBUM]);
    int numPhotos = 0;
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        if (Photo.fromMap(maps[i]).album == albumName) numPhotos++;
      }
    }
    return numPhotos;
  }

  Future<int> getNumAlbums() async {
    List<Album> albumList = await getAlbumList();
    return albumList.length;
  }

  Future<Album> getAlbum(index) async {
    List<Album> albumList = await getAlbumList();
    return albumList[index];
  }

  Future<List<int>> getPhotoData() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [FAVORITE_NAME]);
    int numFavorites = 0;
    int numPhotos = 0;
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        if (Photo.fromMap(maps[i]).favorite == 1) numFavorites++;
      }
    }
    numPhotos = await getSize();
    List<int> photoData = [numFavorites, numPhotos];
    return photoData;
  }

  Future<int> getTotalNumPhotos() async {
    List<Album> albumList = await getAlbumList();
    int numPhotos = 0;
    for (Album album in albumList) {
      numPhotos += await getNumPhotosInAlbum(album.title);
    }
    return numPhotos;
  }

  Future<void> deleteAlbum(String albumName) async {
    var dbClient = await db;
    // Deletes all photos in album
    dbClient.delete(TABLE, where: '$ALBUM = ?', whereArgs: [albumName]);
    // Deletes album
    dbClient.delete(TABLE, where: '$ALBUM_LIST = ?', whereArgs: [albumName]);
  }

  Future<bool> checkFavorite(String path) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [PATH, FAVORITE_NAME]);
    //debugPrint(maps.length.toString());
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        if (Photo.fromMap(maps[i]).photoPath == path)
        {
          debugPrint(Photo.fromMap(maps[i]).favorite.toString());
          return Photo.fromMap(maps[i]).favorite == 1 ? true : false;
        }
      }
    }
    return false;
  }

  Future<void> changeFavorite(String path) async {
    var dbClient = await db;
    List<Photo> photosList = await getPhotosList();
    Photo temp = Photo();
    for(int i = 0; i < photosList.length; i++)
    {
      if(photosList[i].photoPath == path)
      {
        temp = photosList[i];
        break;
      }
    }
    if(temp.favorite == 0)
      temp.favorite = 1;
    else 
      temp.favorite = 0;
    await dbClient.update(TABLE, temp.toMap(),
        where: '$PATH = ?', whereArgs: [path]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

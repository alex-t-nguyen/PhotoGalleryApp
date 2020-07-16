import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
import 'package:gallery_app/views/gallery/models/album.dart';
import 'package:gallery_app/views/gallery/models/feature_photo.dart';
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
  static const String DELETE = 'deletion';
  static const String MOVE = 'moving';
  static const String SHARING = 'sharing';
  static const String ALBUM_ID = 'albumID';
  static const String ALBUM_LIST = 'title';
  static const String ALBUM_PHOTO_NUM = 'numPhotos';
  static const String FEATURE_ID = 'featureID';
  static const String FEATURES = 'featurePath';
  static const String DELETE_FEATURE = 'featureDelete';
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
        'CREATE TABLE $TABLE ($ID INTEGER, $PATH TEXT, $ALBUM TEXT, $FAVORITE_NAME INTEGER, $DELETE INTEGER, $MOVE INTEGER, $SHARING INTEGER, $ALBUM_ID INTEGER, $ALBUM_LIST TEXT, $ALBUM_PHOTO_NUM INTEGER, $FEATURE_ID INTEGER, $FEATURES TEXT, $DELETE_FEATURE INTEGER)');
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
    List<Map> maps = await dbClient
        .query(TABLE, columns: [ID, PATH, ALBUM, FAVORITE_NAME, DELETE, MOVE]);
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
        if (Album.fromMap(maps[i]).title != null) {
          albums.add(Album.fromMap(maps[i]));
        }
      }
    }
    return albums;
  }

  Future<List<Photo>> getPhotosList() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, PATH, ALBUM, FAVORITE_NAME, DELETE, MOVE, SHARING]);
    List<Photo> photos = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        if (Photo.fromMap(maps[i]).photoPath != null)
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

  Future<int> getNumFavorite() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [FAVORITE_NAME]);
    int numFavorites = 0;
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        if (Photo.fromMap(maps[i]).favorite == 1) numFavorites++;
      }
    }
    return numFavorites;
  }

  Future<bool> checkFavorite(String path) async {
    var dbClient = await db;
    List<Map> maps =
        await dbClient.query(TABLE, columns: [PATH, FAVORITE_NAME]);
    //debugPrint(maps.length.toString());
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        if (Photo.fromMap(maps[i]).photoPath == path) {
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
    for (int i = 0; i < photosList.length; i++) {
      if (photosList[i].photoPath == path) {
        temp = photosList[i];
        break;
      }
    }
    if (temp.favorite == 0)
      temp.favorite = 1;
    else
      temp.favorite = 0;
    await dbClient
        .update(TABLE, temp.toMap(), where: '$PATH = ?', whereArgs: [path]);
  }

  Future<void> markForDelete(String path) async {
    var dbClient = await db;
    List<Photo> photosList = await getPhotosList();
    Photo temp = Photo();
    for (int i = 0; i < photosList.length; i++) {
      if (photosList[i].photoPath == path) {
        temp = photosList[i];
        break;
      }
    }
    //debugPrint(temp.delete.toString());
    if (temp.delete == 0)
      temp.delete = 1;
    else
      temp.delete = 0;
    //debugPrint(temp.toMap().toString());
    await dbClient
        .update(TABLE, temp.toMap(), where: '$PATH = ?', whereArgs: [path]);
  }

  Future<void> resetDeletion() async {
    var dbClient = await db;
    List<Photo> photosList = await getPhotosList();
    for (int i = 0; i < photosList.length; i++) {
      Photo temp = photosList[i];
      temp.delete = 0;
      await dbClient.update(TABLE, temp.toMap(),
          where: '$PATH = ?', whereArgs: [photosList[i].photoPath]);
    }
  }

  Future<void> deleteImages(String albumName) async {
    var dbClient = await db;
    await dbClient.delete(TABLE,
        where: '$ALBUM = ? and $DELETE = ?', whereArgs: [albumName, 1]);
    List<Album> albums = await getAlbumList();
    Album album = Album();
    for (int i = 0; i < albums.length; i++) {
      if (albums[i].title == albumName) {
        album = albums[i];
        break;
      }
    }
    album.numPhotos = await getNumPhotosInAlbum(albumName);
    dbClient.update(TABLE, album.toMap(),
        where: '$ALBUM_LIST = ?', whereArgs: [albumName]);
  }

  Future<void> resetMoving() async {
    var dbClient = await db;
    List<Photo> photosList = await getPhotosList();
    for (int i = 0; i < photosList.length; i++) {
      Photo temp = photosList[i];
      temp.move = 0;
      await dbClient.update(TABLE, temp.toMap(),
          where: '$PATH = ?', whereArgs: [photosList[i].photoPath]);
    }
  }

  Future<void> moveImages(String albumName, String destinationAlbum) async {
    var dbClient = await db;
    List<Photo> photosList = await getPhotos(albumName);
    for (Photo temp in photosList) {
      if (temp.move == 1) {
        temp.album = destinationAlbum;
        await dbClient.update(TABLE, temp.toMap(),
            where: '$ALBUM = ? and $PATH = ?',
            whereArgs: [albumName, temp.photoPath]);
      }
    }
    // Update original album num photos
    List<Album> albums = await getAlbumList();
    Album album = Album();
    for (int i = 0; i < albums.length; i++) {
      if (albums[i].title == albumName) {
        album = albums[i];
        break;
      }
    }
    album.numPhotos = await getNumPhotosInAlbum(albumName);
    dbClient.update(TABLE, album.toMap(),
        where: '$ALBUM_LIST = ?', whereArgs: [albumName]);

    // Update destination album num photos
    for (int i = 0; i < albums.length; i++) {
      if (albums[i].title == destinationAlbum) {
        album = albums[i];
        break;
      }
    }
    album.numPhotos = await getNumPhotosInAlbum(destinationAlbum);
    dbClient.update(TABLE, album.toMap(),
        where: '$ALBUM_LIST = ?', whereArgs: [destinationAlbum]);
  }

  Future<void> markForMove(String path) async {
    var dbClient = await db;
    List<Photo> photosList = await getPhotosList();
    Photo temp = Photo();
    for (int i = 0; i < photosList.length; i++) {
      if (photosList[i].photoPath == path) {
        temp = photosList[i];
        break;
      }
    }
    if (temp.move == 0)
      temp.move = 1;
    else
      temp.move = 0;
    await dbClient
        .update(TABLE, temp.toMap(), where: '$PATH = ?', whereArgs: [path]);
  }

  Future<List<FeaturePhoto>> getFeatureImages() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(TABLE, columns: [FEATURE_ID, FEATURES, DELETE_FEATURE]);
    List<FeaturePhoto> featureList = [];
    for (int i = 0; i < maps.length; i++) {
      if (FeaturePhoto.fromMap(maps[i]).path != null)
        featureList.add(FeaturePhoto.fromMap(maps[i]));
    }
    return featureList;
  }

  Future<void> addFeatureImage(FeaturePhoto featurePhoto) async {
    var dbClient = await db;
    featurePhoto.id = await dbClient.insert(TABLE, featurePhoto.toMap());
  }

  Future<void> deleteFeatures() async {
    var dbClient = await db;
    dbClient.delete(TABLE, where: '$DELETE_FEATURE = ?', whereArgs: [1]);
  }

  Future<void> markFeatureDelete(path) async {
    var dbClient = await db;
    List<FeaturePhoto> featureList = await getFeatureImages();
    FeaturePhoto temp = FeaturePhoto();
    for (int i = 0; i < featureList.length; i++) {
      if (featureList[i].path == path) {
        temp = featureList[i];
        break;
      }
    }
    if (temp.delete == 0)
      temp.delete = 1;
    else
      temp.delete = 0;
    await dbClient
        .update(TABLE, temp.toMap(), where: '$FEATURES = ?', whereArgs: [path]);
  }

  Future<void> resetDeleteFeatures() async {
    var dbClient = await db;
    List<FeaturePhoto> featureList = await getFeatureImages();
    for (int i = 0; i < featureList.length; i++) {
      FeaturePhoto temp = featureList[i];
      temp.delete = 0;
      await dbClient.update(TABLE, temp.toMap(),
          where: '$FEATURES = ?', whereArgs: [featureList[i].path]);
    }
  }

  Future<void> markForShare(String path) async {
    var dbClient = await db;
    List<Photo> photosList = await getPhotosList();
    Photo temp = Photo();
    for (int i = 0; i < photosList.length; i++) {
      if (photosList[i].photoPath == path) {
        temp = photosList[i];
        break;
      }
    }
    if (temp.share == 0)
      temp.share = 1;
    else
      temp.share = 0;
    await dbClient
        .update(TABLE, temp.toMap(), where: '$PATH = ?', whereArgs: [path]);
  }

  Future<List<Photo>> getSharedImages() async {
    List<Photo> photosList = await getPhotosList();
    List<Photo> sharedPhotos = List<Photo>();
    for (Photo photo in photosList) {
      if (photo.share == 1) sharedPhotos.add(photo);
    }
    return sharedPhotos;
  }

  Future<void> resetSharing() async {
    var dbClient = await db;
    List<Photo> photosList = await getPhotosList();
    for (int i = 0; i < photosList.length; i++) {
      Photo temp = photosList[i];
      temp.share = 0;
      await dbClient.update(TABLE, temp.toMap(),
          where: '$PATH = ?', whereArgs: [photosList[i].photoPath]);
    }
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

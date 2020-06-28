import 'dart:async';
import 'dart:io' as io;
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

  initDB() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE $TABLE ($ID INTEGER, $PATH TEXT, $ALBUM TEXT, $FAVORITE_NAME INTEGER, $ALBUM_ID INTEGER, $ALBUM_LIST TEXT, $ALBUM_PHOTO_NUM INTEGER)');
  }

  Future<Photo> save(Photo photo) async {
    var dbClient = await db;
    photo.id = await dbClient.insert(TABLE, photo.toMap());
    return photo;
  }

  Future<List<Photo>> getPhotos(String albumName) async {
    var dbClient = await db;  // call database getter function
    List<Map> maps = await dbClient.query(TABLE, columns: [ID, PATH, ALBUM, FAVORITE_NAME]);
    List<Photo> photos = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++)
      {
        if(Photo.fromMap(maps[i]).album == albumName)
          photos.add(Photo.fromMap(maps[i]));
      }
    }
    return photos;
  }

  Future<int> getSize() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $TABLE'));
  }

  Future<List<Album>> getAlbumList() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ALBUM_ID, ALBUM_LIST, ALBUM_PHOTO_NUM]);
    List<Album> albums = [];
    if (maps.length > 0)
    {
      for (int i = 0; i < maps.length; i++)
      {
        albums.add(Album.fromMap(maps[i]));
      }
    }
    return albums;
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
    if(maps.length > 0)
    {
      for (int i = 0; i < maps.length; i++)
      {
        if (Photo.fromMap(maps[i]).album == albumName)
          numPhotos++;
      }
    }
    return numPhotos;
  }

  
  
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_app/views/gallery/photo.dart';

class PhotoProvider {
  static Database _db;
  static const String ID = 'id';
  static const String PATH = 'photoPath';
  static const String ALBUM = 'album';
  static const String FAVORITE_NAME = 'favorite';
  static const int FAVORITE = 0;
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
    await db.execute('CREATE TABLE $TABLE ($ID INTEGER, $PATH TEXT, $ALBUM TEXT, $FAVORITE_NAME INTEGER)');
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

  
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

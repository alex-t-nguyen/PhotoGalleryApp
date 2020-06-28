class Photo {
  int id;
  String photoPath;
  String album;
  int favorite;

  Photo({this.id, this.photoPath, this.album, this.favorite});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'id': id,
      'photoPath': photoPath,
      'album': album,
      'favorite': favorite,
    };
    return map;
  }

  Photo.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    photoPath = map['photoPath'];
    album = map['album'];
    favorite = map['favorite'];
  }
}
class Photo {
  int id;
  String photoPath;
  String album;
  int favorite;
  int delete;
  int move;
  int share;

  Photo({this.id, this.photoPath, this.album, this.favorite, this.delete, this.move, this.share});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'id': id,
      'photoPath': photoPath,
      'album': album,
      'favorite': favorite,
      'deletion': delete,
      'moving': move,
      'sharing': share,
    };
    return map;
  }

  Photo.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    photoPath = map['photoPath'];
    album = map['album'];
    favorite = map['favorite'];
    delete = map['deletion'];
    move = map['moving'];
    share = map['sharing'];
  }
}
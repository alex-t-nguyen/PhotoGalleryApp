class Album {
  int id;
  String title;
  int numPhotos;

  Album({this.id, this.title, this.numPhotos});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'id': id,
      'title': title,
      'numAlbumPhotos': numPhotos,
    };
    return map;
  }

  Album.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    numPhotos = map['numPhotos'];
  }
}
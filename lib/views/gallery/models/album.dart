class Album {
  int id;
  String title;
  int numPhotos;

  Album({this.id, this.title, this.numPhotos});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'albumID': id,
      'title': title,
      'numPhotos': numPhotos,
    };
    return map;
  }

  Album.fromMap(Map<String, dynamic> map) {
    id = map['albumID'];
    title = map['title'];
    numPhotos = map['numPhotos'];
  }
}
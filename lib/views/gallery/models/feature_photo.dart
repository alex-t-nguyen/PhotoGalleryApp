class FeaturePhoto {
  int id;
  String path;
  int delete;

  FeaturePhoto({this.id, this.path, this.delete});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'featureID': id,
      'featurePath': path,
      'featureDelete': delete,
    };
    return map;
  }

  FeaturePhoto.fromMap(Map<String, dynamic> map) {
    id = map['featureID'];
    path = map['featurePath'];
    delete = map['featureDelete'];
  }
}
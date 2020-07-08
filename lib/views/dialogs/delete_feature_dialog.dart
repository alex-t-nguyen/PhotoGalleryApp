import 'package:flutter/material.dart';
import 'package:gallery_app/providers/photo_provider.dart';
import 'package:gallery_app/views/gallery/feature_container.dart';
import 'package:gallery_app/views/gallery/models/feature_photo.dart';

class DeleteFeatureDialog extends StatefulWidget {
  @override
  _DeleteFeatureDialogState createState() => _DeleteFeatureDialogState();
}

class _DeleteFeatureDialogState extends State<DeleteFeatureDialog> {
  final PhotoProvider _photoProvider = PhotoProvider();
  List<FeaturePhoto> featureList;

  Future<List<FeaturePhoto>> features;

  @override
  void initState() {
    super.initState();
    features = _getFeaturesList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(top: 66),
        decoration: new BoxDecoration(
          color: const Color(0xff333333),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: Text(
                'Select feature images to delete',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
                child: Container(
              child: FutureBuilder<List<FeaturePhoto>>(
                future: features,
                builder: (BuildContext context,
                    AsyncSnapshot<List<FeaturePhoto>> snapshot) {
                  if (snapshot.hasData) {
                    //refreshFeatures();
                    return ListView(
                      children: List.generate(snapshot.data.length, (index) {
                        return GestureDetector(
                            onTap: () {
                              debugPrint("Before toggle: " +
                                  snapshot.data[index].delete.toString());
                              setState(() {
                                _toggleDelete(index);
                                snapshot.data[index].delete == 1
                                    ? snapshot.data[index].delete = 0
                                    : snapshot.data[index].delete = 1;
                                //features = _getFeaturesList();
                              });
                              //refreshFeatures();
                            },
                            child: FeatureContainer(
                                path: snapshot.data[index].path,
                                markDelete: snapshot.data[index].delete == 1
                                    ? true
                                    : false));
                      }),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xff01C699)),
                      ),
                    );
                  }
                },
              ),
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    )),
                FlatButton(
                    onPressed: () {
                      _photoProvider.deleteFeatures();
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      'Delete features',
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          ],
        ));
  }

  Future<List<FeaturePhoto>> _getFeaturesList() {
    return _photoProvider.getFeatureImages();
  }

  void _toggleDelete(int index) async {
    featureList = await _photoProvider.getFeatureImages();
    _photoProvider.markFeatureDelete(featureList[index].path);
    //features = _getFeaturesList();
    //refreshFeatures();
    //getFeaturesList();
  }

  void refreshFeatures() {
    setState(() {
      features = _getFeaturesList();
    });
  }
}

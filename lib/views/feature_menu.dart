import 'package:flutter/material.dart';
import 'package:gallery_app/components/album_floating_action_button.dart';
import 'package:gallery_app/views/gallery/models/feature_photo.dart';
import 'package:image_picker/image_picker.dart';

import '../components/Carousel.dart';
import './draggable_scroll_sheet/draggable_scroll_sheet.dart';

import 'package:gallery_app/providers/photo_provider.dart';

import 'dialogs/delete_feature_dialog.dart';
import 'gallery/models/feature_settings.dart';

class FeatureMenu extends StatefulWidget {
  @override
  _FeatureMenuState createState() => _FeatureMenuState();
}

class _FeatureMenuState extends State<FeatureMenu> {
  final PhotoProvider _photoProvider = PhotoProvider();

  final ImagePicker _imagePicker = ImagePicker();
  List<FeaturePhoto> featuresList = [];

  @override
  initState() {
    //_photoProvider.deleteDB();
    _getFeatureList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feature Menu'),
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: settingsAction,
              itemBuilder: (BuildContext context) {
                return FeatureSettings.featureSettingsList
                    .map((String selection) {
                  return PopupMenuItem<String>(
                      value: selection, child: Text(selection));
                }).toList();
              }),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
              color: const Color(0xff000000),
              child: Carousel(feature: featuresList)),
          // Can put container here to add space if needed
          DraggableScrollSheet(),
          AlbumFloatingActionButton(),
        ],
      ),
    );
  }

  void settingsAction(String selection) async {
    if (selection == FeatureSettings.ADD_FEATURE) {
      var pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        FeaturePhoto feature = FeaturePhoto(
            id: await _photoProvider.getSize(),
            path: pickedFile.path,
            delete: 0);
        _photoProvider.addFeatureImage(feature);
        featuresList = await _photoProvider.getFeatureImages();
        setState(() {});
      }
    } else if (selection == FeatureSettings.DELETE_FEATURE) {
      await _deleteFeature();
      setState(() {});
    }
  }

  _deleteFeature() async {
    bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteFeatureDialog();
        });
    if (confirmDelete != null && confirmDelete) {
      await _photoProvider.deleteFeatures();
      featuresList = await _photoProvider.getFeatureImages();
    }
    await _photoProvider.resetDeleteFeatures();
  }

  _getFeatureList() async {
    await _photoProvider.getFeatureImages().then((value) {
      setState(() {
        featuresList.clear();
        featuresList.addAll(value);
      });
    });
  }
}

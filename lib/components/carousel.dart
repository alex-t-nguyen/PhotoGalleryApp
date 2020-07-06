import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_app/providers/photo_provider.dart';
import 'package:gallery_app/views/gallery/models/feature_photo.dart';

import 'carousel_indicator.dart';

class Carousel extends StatefulWidget {
  final List<FeaturePhoto> feature;

  Carousel({this.feature});

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  PhotoProvider _photoProvider = PhotoProvider();
  PageController pageController;
  bool pageFlag;

  int _repeat(int index) =>
      widget.feature.length * ((index / widget.feature.length).floor());
  int _index(int index) =>
      index > widget.feature.length - 1 ? index - _repeat(index) : index;

  PageController get controller => pageController;

  void _pageChanged(int index) => setState(() {});

/*
  List<Image> images = [
    Image(image: AssetImage('assets/images/Fox In Forest.jpg')),
    Image(
        image:
            AssetImage('assets/images/Howl\'s Moving Castle Background.jpg')),
    Image(image: AssetImage('assets/images/Your name wallpaper.jpg')),
    Image(image: AssetImage('assets/images/Yuru Camp Wallpaper.jpg')),
  ];
  */

  List<String> images = [
    /*
    'https://c4.wallpaperflare.com/wallpaper/902/955/807/yuru-camp-nadeshiko-kagamihara-rin-shima-chiaki-oogaki-wallpaper-preview.jpg',
    'https://free4kwallpapers.com/uploads/originals/2019/04/02/mount-fuji-from-the-yuru-camp-intro-wallpaper.jpg',
    'https://images.alphacoders.com/555/thumb-1920-555565.jpg',
    'https://wallpapercave.com/wp/wp4286320.jpg'
    */
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 99, viewportFraction: 0.75);
    pageFlag = true;
    //getFeatures();
    //getFeaturePaths();
  }

  @override
  Widget build(BuildContext context) {
    /*if (widget.feature.length > 0) {
      for (FeaturePhoto feature in widget.feature) {
        images.add(feature.path);
      }
    }*/
    //debugPrint(images.length.toString());
    return /*Scaffold(
      appBar: AppBar(
        title: Text('Photo Gallery'),
      ),
      body:*/
        Column(
      children: <Widget>[
        Container(
          height: 250,
          child: PageView.builder(
              onPageChanged: _pageChanged,
              controller: pageController,
              //itemCount: images.length, //Giving item count makes scrolling finite
              itemBuilder: (context, position) {
                if (pageController.hasClients && pageFlag) {
                  pageFlag = false;
                  pageController.animateToPage(100,
                      duration: Duration(microseconds: 1),
                      curve: Curves.easeInOut);
                }
                return imageSlider(position);
              }),
        ),
        CarouselIndicator(controller: pageController, itemCount: 5),
      ],
    ); //,
    //);
  }

  imageSlider(int index) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, widget) {
        double value = 1;
        if (pageController.position.haveDimensions) {
          value = pageController.page - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 200,
            width: Curves.easeInOut.transform(value) * 300,
            child: widget,
          ),
        );
      },
      child: Container(
          //margin: EdgeInsets.all(3),
          child: widget.feature.length > 0
              ? Image.file(File(widget.feature[_index(index)].path),
                  fit: BoxFit.cover)
              : Center(
                  child: Text(
                  'No feature images available',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ))),
    );
  }

/*
  getFeatures() async {
    featuresList = await _photoProvider.getFeatureImages();
  }

  getFeaturePaths() {
    setState(() {
      for (FeaturePhoto feature in featuresList) {
        images.add(feature.path);
      }
    });
  }
  */
}

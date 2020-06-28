import 'package:flutter/material.dart';

import '../components/carousel_indicator.dart';

class Carousel extends StatefulWidget {
  Carousel();

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  PageController pageController;

  int _repeat(int index) => images.length * ((index / images.length).floor());
  int _index(int index) =>
      index > images.length - 1 ? index - _repeat(index) : index;

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
    'https://c4.wallpaperflare.com/wallpaper/902/955/807/yuru-camp-nadeshiko-kagamihara-rin-shima-chiaki-oogaki-wallpaper-preview.jpg',
    'https://free4kwallpapers.com/uploads/originals/2019/04/02/mount-fuji-from-the-yuru-camp-intro-wallpaper.jpg',
    'https://images.alphacoders.com/555/thumb-1920-555565.jpg',
    'https://wallpapercave.com/wp/wp4286320.jpg'
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 101, viewportFraction: 0.75);
  }

  @override
  Widget build(BuildContext context) {
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
          child: Image.network(images[_index(index)], fit: BoxFit.cover)),
    );
  }
}

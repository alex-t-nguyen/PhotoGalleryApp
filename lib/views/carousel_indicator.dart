import 'package:flutter/material.dart';

class CarouselIndicator extends StatelessWidget {
  CarouselIndicator({
    this.controller,
    this.itemCount,
  }) : assert(controller != null);

  /// PageView Controller
  final PageController controller;

  /// Number of indicators
  final int itemCount;

  /// Ordinary colours
  final Color normalColor = const Color(0xff6E6B6C);

  /// Selected color
  final Color selectedColor = const Color(0xffC1575C);

  /// Size of points
  final double size = 8.0;

  /// Spacing of points
  final double spacing = 4.0;

  /// Point Widget
  Widget _buildIndicator(
      int index, int pageCount, double dotSize, double spacing) {
    // Is the current page selected?
    bool isCurrentPageSelected = index ==
        (controller.page != null ? controller.page.round() % pageCount : 0);

    return new Container(
      height: size,
      width: size + (2 * spacing),
      child: new Center(
        child: new Material(
          color: isCurrentPageSelected ? selectedColor : normalColor,
          type: MaterialType.circle,
          child: new Container(
            width: dotSize,
            height: dotSize,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, (int index) {
        return _buildIndicator(index, itemCount, size, spacing);
      }),
    );
  }
}
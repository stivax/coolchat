import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class IconCarousel extends StatefulWidget {
  @override
  _IconCarouselState createState() => _IconCarouselState();
}

class _IconCarouselState extends State<IconCarousel> {
  final List<IconData> icons = [
    Icons.home,
    Icons.business,
    Icons.school,
    Icons.settings,
    Icons.notifications
  ];
  final CarouselController _controller = CarouselController();

  void onIconTap(int index) {
    print('Icon tapped: ${icons[index]}');
    _controller.animateToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: icons.length,
      carouselController: _controller,
      options: CarouselOptions(
          height: 300,
          enlargeCenterPage: true,
          viewportFraction: 0.2,
          onPageChanged: (index, reason) {
            // Automatically triggers function associated with top positioned icon
            if (reason == CarouselPageChangedReason.manual) {
              onIconTap(index);
            }
          }),
      itemBuilder: (context, index, realIndex) {
        return IconButton(
          icon: Icon(icons[index], size: 50),
          onPressed: () => onIconTap(index),
        );
      },
    );
  }
}

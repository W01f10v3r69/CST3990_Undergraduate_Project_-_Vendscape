import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:vendscape/constants.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

final _controller = PageController(
  initialPage: 0,
);

int _currentPage = 0;

List<Widget> _pages=[
  Column(
    children: [
      Expanded(child: Image.asset('images/enteraddress.png')),
      Text('Set Your Delivery Details', style: kPageViewTextStyle, textAlign: TextAlign.center,)
    ],
  ),Column(
    children: [
      Expanded(child: Image.asset('images/orderfood.png')),
      Text('Order Online From Your Favourite Vendors', style: kPageViewTextStyle, textAlign: TextAlign.center,)
    ],
  ),
  Column(
    children: [
      Expanded(child: Image.asset('images/deliverfood.png')),
      Text('Quick Delivery To Your Doorstep', style: kPageViewTextStyle, textAlign: TextAlign.center,)
    ],
  ),
];

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
        child: PageView(
          controller: _controller,
          children: _pages,
          onPageChanged: (index){
            setState(() {
              _currentPage = index;
            });
          },
        ),
      ),
        SizedBox(height: 20,),
        DotsIndicator(
          dotsCount: _pages.length,
          position: _currentPage.toDouble(),
          decorator: DotsDecorator(
              size: const Size.square(9.0),
              activeSize: const Size(18.0, 9.0),
              activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              activeColor: Colors.lightBlue
          ),
        ),
        SizedBox(height: 20,),
      ],
    );
  }
}

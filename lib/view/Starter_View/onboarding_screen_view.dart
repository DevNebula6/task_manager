import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/Auth/Bloc/auth_bloc.dart';
import 'package:task_manager/Auth/Bloc/auth_event.dart';
import 'package:task_manager/utilities/Visuals/animated_widget.dart';
import 'package:task_manager/utilities/Visuals/glassbox.dart';
import 'package:task_manager/utilities/Visuals/page_indicator.dart';
import 'dart:math';

class OnboardingScreenView extends StatefulWidget {
  const OnboardingScreenView({super.key});

  @override
  State<StatefulWidget> createState() => _OnboardingScreenViewState();
}

class _OnboardingScreenViewState extends State<OnboardingScreenView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      quote: "Embrace the grind, elevate your potential",
      info: "Track tasks, boost productivity, and conquer your goals",
      image: "assets/backgrounds/thought-catalog-505eectW54k-unsplash.jpg",
    ),
    OnboardingPage(
      quote: "Success is a journey of persistent effort",
      info: "Build lasting habits that transform your life",
      image: "assets/backgrounds/Asthetic-study.jpg",
    ),
    OnboardingPage(
      quote: "Get things done, one task at a time",
      info: "just a click away from a more organized you",
      image: "assets/backgrounds/ella-jardim-iqf-qO711ys-unsplash.jpg",
      isLast: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    //_precacheImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheImages();
  }

  void _precacheImages() {
    for (var page in _pages) {
      precacheImage(AssetImage(page.image), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                PageIndicator(
                  currentPage: _currentPage,
                  pageCount: _pages.length,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.3),
                  dotWidth: 10,
                  activeDotWidth: 30,
                  dotHeight: 10,
                  spacing: 8,
                ),
                const SizedBox(height: 20),
                if (_currentPage != _pages.length - 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          _pageController.jumpToPage(_pages.length - 1);
                        },
                        child: const Text('Skip',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 610),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Next',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(page.image),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            AnimatedWidgetSlide(
              direction: _getRandomDirection(),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Text(
                    page.quote,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.081,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            const Spacer(),
            AnimatedWidgetSlide(
              direction: _getRandomDirection(),
              duration: const Duration(milliseconds: 850),
              curve: Curves.easeOutCubic,
              child: Glassbox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,
                blur: 2,
                borderRadius: 30,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.05),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 610),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: child,
                          );
                        },
                        child: Text(
                          page.info,
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.055,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (page.isLast)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                context
                                    .read<AuthBloc>()
                                    .add(const AuthEventNavigateToSignIn());                               
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Start your journey',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  AnimationDirection _getRandomDirection() {
    const directions = AnimationDirection.values;
    return directions[Random().nextInt(directions.length)];
  }
}

class OnboardingPage {
  final String quote;
  final String info;
  final String image;
  final bool isLast;

  OnboardingPage({
    required this.quote,
    required this.info,
    required this.image,
    this.isLast = false,
  });
}

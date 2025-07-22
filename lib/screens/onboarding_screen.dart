import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Welcome to Weatherly',
      description:
          'Your beautiful weather companion. Get real-time updates and stunning visuals.',
      image: Icons.wb_sunny,
      bgGradient: [Color(0xFF4a90e2), Color(0xFF87ceeb)],
    ),
    _OnboardingPageData(
      title: 'Animated Weather',
      description:
          'Experience dynamic backgrounds and icons that reflect real conditions.',
      image: Icons.cloud,
      bgGradient: [Color(0xFF6b92b5), Color(0xFF9fb5c7)],
    ),
    _OnboardingPageData(
      title: 'Interactive Map',
      description:
          'Explore weather on a map, search locations, and view analytics.',
      image: Icons.map,
      bgGradient: [Color(0xFF54717a), Color(0xFF8b9ea5)],
    ),
    _OnboardingPageData(
      title: 'Personalized Experience',
      description: 'Save favorite locations and customize your settings.',
      image: Icons.favorite,
      bgGradient: [Color(0xFFe57373), Color(0xFFf06292)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _pages[_currentPage].bgGradient,
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(page.image, size: 120, color: Colors.white)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(duration: 600.ms),
                  const SizedBox(height: 32),
                  Text(
                    page.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) => _buildDot(i)),
                ),
                const SizedBox(height: 24),
                AnimatedOpacity(
                  opacity: _currentPage == _pages.length - 1 ? 1 : 0.7,
                  duration: const Duration(milliseconds: 400),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        Navigator.of(context).pop();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutExpo,
                        );
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: _currentPage == index ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final IconData image;
  final List<Color> bgGradient;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.image,
    required this.bgGradient,
  });
}

import 'package:flutter/material.dart';
import 'package:lumina/core/theme/app_colors.dart';
import 'package:lumina/core/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "Welcome to Lumina",
      description:
          "Your offline-first AI study buddy that fits in your pocket.",
      imagePath: "assets/images/welcome.png",
    ),
    OnboardingContent(
      title: "Scan & Extract",
      description:
          "Snap a photo of your notes and let Lumina turn them into text instantly.",
      imagePath: "assets/images/scan.png",
    ),
    OnboardingContent(
      title: "Generate Quizzes",
      description:
          "Create Multiple Choice or Fill-in-the-Blank quizzes using our smart engine.",
      imagePath: "assets/images/quiz.png",
    ),
  ];

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentIndex == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentIndex == index
            ? AppColors.primaryPurple
            : AppColors.primaryPurple.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_run', false);
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: _contents.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school,
                        size: 100,
                        color: AppColors.primaryPurple,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _contents[index].title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMainLight,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _contents[index].description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _contents.length,
              (index) => _buildDot(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentIndex > 0
                    ? BigButton(
                        label: "Previous",
                        color: Colors.transparent,
                        textColor: AppColors
                            .primaryPurple, 
                        hasShadow: false,
                        onTap: () {
                          _controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      )
                    : const SizedBox.shrink(),

                BigButton(
                  label: _currentIndex == _contents.length - 1
                      ? "Get Started"
                      : "Next",
                  color: AppColors.primaryPurple, 
                  textColor: Colors.white,
                  onTap: () {
                    if (_currentIndex == _contents.length - 1) {
                      _completeOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

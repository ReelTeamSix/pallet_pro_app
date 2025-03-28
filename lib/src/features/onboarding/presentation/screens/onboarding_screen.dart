import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/core/utils/responsive_utils.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';

/// The onboarding screen.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates a new [OnboardingScreen] instance.
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Pallet Pro',
      description:
          'The ultimate inventory management solution for resellers and small businesses.',
      icon: AppIcons.pallet,
    ),
    OnboardingPage(
      title: 'Track Your Inventory',
      description:
          'Easily manage your pallets, items, and expenses. Keep track of what\'s selling and what\'s not.',
      icon: AppIcons.inventory,
    ),
    OnboardingPage(
      title: 'Analyze Your Business',
      description:
          'Get insights into your business with detailed analytics and reports. Set goals and track your progress.',
      icon: AppIcons.analytics,
    ),
    OnboardingPage(
      title: 'Let\'s Get Started',
      description:
          'Set up your account and start managing your inventory like a pro.',
      icon: AppIcons.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(userSettingsControllerProvider.notifier)
          .updateHasCompletedOnboarding(true);
      
      if (mounted) {
        context.goNamed('home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException 
                  ? e.message 
                  : 'Failed to complete onboarding: ${e.toString()}'
            ),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _isLoading ? null : () => _pageController.jumpToPage(_pages.length - 1),
                  child: Text('Skip'),
                ),
              ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return ResponsiveUtils.centerContent(
                    context: context,
                    maxWidth: 600,
                    child: Padding(
                      padding: EdgeInsets.all(context.spacingLg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            page.icon,
                            size: 100,
                            color: context.primaryColor,
                          ),
                          SizedBox(height: context.spacingLg),
                          Text(
                            page.title,
                            style: context.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.spacingMd),
                          Text(
                            page.description,
                            style: context.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? context.primaryColor
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.spacingMd),
            
            // Navigation buttons
            Padding(
              padding: EdgeInsets.all(context.spacingLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: _isLoading ? null : _previousPage,
                      icon: Icon(Icons.arrow_back),
                      label: Text('Back'),
                    )
                  else
                    SizedBox.shrink(),
                  
                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _nextPage,
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.onPrimaryColor,
                            ),
                          )
                        : Text(
                            _currentPage < _pages.length - 1
                                ? 'Next'
                                : 'Get Started',
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A page in the onboarding flow.
class OnboardingPage {
  /// Creates a new [OnboardingPage] instance.
  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  /// The title of the page.
  final String title;

  /// The description of the page.
  final String description;

  /// The icon of the page.
  final IconData icon;
}

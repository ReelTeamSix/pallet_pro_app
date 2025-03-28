import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/core/utils/responsive_utils.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (_isLoading) return; // Prevent double click
    
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('OnboardingScreen: Starting direct onboarding completion');
      
      // First, ensure user settings exist
      await _ensureUserSettingsExist();
      
      // Get the client and user
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // First update the onboarding status in the database directly
      debugPrint('OnboardingScreen: Updating has_completed_onboarding in database');
      try {
        // Use the update with the correct field name
        await client
          .from('user_settings')
          .update({'has_completed_onboarding': true})
          .eq('id', user.id); // Use 'id' not 'user_id'
        debugPrint('OnboardingScreen: Database update successful');
      } catch (updateError) {
        debugPrint('OnboardingScreen: Error updating database: $updateError');
        // Continue anyway - we'll try to navigate
      }
      
      // Attempt to refresh the user settings in the provider
      try {
        debugPrint('OnboardingScreen: Refreshing user settings provider');
        await ref.read(userSettingsControllerProvider.notifier).refreshSettings();
      } catch (refreshError) {
        debugPrint('OnboardingScreen: Error refreshing settings: $refreshError');
        // Continue anyway - we'll try to navigate
      }
      
      // Navigate with query parameter to bypass settings checks in router
      if (mounted) {
        debugPrint('OnboardingScreen: Navigating to home with bypass parameter');
        try {
          // Use the new approach with query parameter
          final uri = Uri(
            path: '/home',
            queryParameters: {'fromOnboarding': 'true'}
          );
          context.go(uri.toString());
          debugPrint('OnboardingScreen: Navigation to home with bypass parameter successful');
          return;
        } catch (e) {
          debugPrint('OnboardingScreen: Error navigating with URI: $e, trying fallback');
          
          // Fallback to direct navigation
          try {
            context.go('/home');
            debugPrint('OnboardingScreen: Fallback navigation successful');
            return;
          } catch (fallbackError) {
            debugPrint('OnboardingScreen: Fallback navigation failed: $fallbackError');
            throw Exception('Failed to navigate to home screen: $fallbackError');
          }
        }
      } else {
        debugPrint('OnboardingScreen: Widget not mounted for navigation');
        throw Exception('Widget not mounted for navigation');
      }
    } catch (e) {
      debugPrint('OnboardingScreen: Error in complete onboarding flow: $e');
      
      // Show error and reset loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException 
                  ? e.message 
                  : 'Failed: ${e.toString()}'
            ),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }
  
  /// Ensures that user settings exist for the current user
  Future<void> _ensureUserSettingsExist() async {
    debugPrint('OnboardingScreen: Ensuring user settings exist');
    
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    
    if (user == null) {
      debugPrint('OnboardingScreen: No current user');
      throw Exception('User not authenticated');
    }
    
    try {
      // First try to get existing settings
      try {
        debugPrint('OnboardingScreen: Checking if settings exist');
        final response = await client
            .from('user_settings')
            .select()
            .eq('id', user.id)  // Use 'id' instead of 'user_id' based on the DB schema
            .limit(1)
            .maybeSingle();
        
        if (response != null) {
          debugPrint('OnboardingScreen: User settings exist');
          return;
        }
      } catch (e) {
        debugPrint('OnboardingScreen: Error checking if settings exist: $e');
        // Continue to creation if we couldn't find settings
      }
      
      // If we get here, settings don't exist, so create them
      debugPrint('OnboardingScreen: Creating user settings');
      
      // Create default settings - use the exact column names from the database schema
      final defaultSettings = {
        'id': user.id,  // This should be 'id' not 'user_id' based on the DB schema
        'theme': 'system',
        'has_completed_onboarding': false,
        'stale_threshold_days': 30,
        'cost_allocation_method': 'even',  // DB default is 'even' not 'average'
        'enable_biometric_unlock': false,  // Not 'use_biometric_auth'
        'show_break_even': true,  // Not 'show_break_even_price'
        'daily_goal': 0,
        'weekly_goal': 0,
        'monthly_goal': 0,
        'yearly_goal': 0
      };
      
      await client
          .from('user_settings')
          .insert(defaultSettings);
      
      debugPrint('OnboardingScreen: User settings created successfully');
    } catch (e) {
      debugPrint('OnboardingScreen: Error creating user settings: $e');
      throw Exception('Failed to create user settings: $e');
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

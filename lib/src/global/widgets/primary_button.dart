import 'package:flutter/material.dart';

/// A reusable primary button widget for the application.
///
/// Uses the theme's primary color for the background and provides
/// consistent styling and behavior.
class PrimaryButton extends StatelessWidget {
  /// Creates a primary button.
  ///
  /// The [text] argument is required and displays the button's label.
  /// The [onPressed] argument is the callback that is executed when the
  /// button is tapped. If null, the button will be disabled.
  /// The [isLoading] argument, if true, shows a progress indicator
  /// instead of the text and disables the button. Defaults to false.
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width, // Add optional width parameter for testing
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width; // Optional width for test environments

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDisabled = isLoading || onPressed == null;

    // Create a button with safe constraints to prevent layout issues
    return Container(
      width: width ?? double.maxFinite, // Use provided width or max finite width
      constraints: const BoxConstraints(maxWidth: 600), // Prevent excessive width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.5),
          disabledForegroundColor: theme.colorScheme.onPrimary.withOpacity(0.7),
          minimumSize: const Size(0, 48), // Minimum height, let width be determined by constraints
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: isDisabled ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                  strokeWidth: 3,
                ),
              )
            : Text(text.toUpperCase()),
      ),
    );
  }
} 
import 'package:flutter/material.dart';

/// Utility class for responsive design.
class ResponsiveUtils {
  /// Creates a new [ResponsiveUtils] instance.
  const ResponsiveUtils._();

  // Breakpoints
  /// Extra small screen width breakpoint (< 600).
  static const double breakpointXs = 600;
  /// Small screen width breakpoint (>= 600).
  static const double breakpointSm = 600;
  /// Medium screen width breakpoint (>= 960).
  static const double breakpointMd = 960;
  /// Large screen width breakpoint (>= 1280).
  static const double breakpointLg = 1280;
  /// Extra large screen width breakpoint (>= 1920).
  static const double breakpointXl = 1920;

  /// Determines if the current screen width is extra small (< 600).
  static bool isExtraSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < breakpointXs;

  /// Determines if the current screen width is small (>= 600 && < 960).
  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointSm &&
      MediaQuery.of(context).size.width < breakpointMd;

  /// Determines if the current screen width is medium (>= 960 && < 1280).
  static bool isMedium(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointMd &&
      MediaQuery.of(context).size.width < breakpointLg;

  /// Determines if the current screen width is large (>= 1280 && < 1920).
  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointLg &&
      MediaQuery.of(context).size.width < breakpointXl;

  /// Determines if the current screen width is extra large (>= 1920).
  static bool isExtraLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointXl;

  /// Determines if the current screen is a mobile device (< 600).
  static bool isMobile(BuildContext context) => isExtraSmall(context);

  /// Determines if the current screen is a tablet (>= 600 && < 1280).
  static bool isTablet(BuildContext context) =>
      isSmall(context) || isMedium(context);

  /// Determines if the current screen is a desktop (>= 1280).
  static bool isDesktop(BuildContext context) =>
      isLarge(context) || isExtraLarge(context);

  /// Returns a value based on the current screen size.
  ///
  /// - [mobile]: Value for mobile screens (< 600).
  /// - [tablet]: Value for tablet screens (>= 600 && < 1280).
  /// - [desktop]: Value for desktop screens (>= 1280).
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Returns a value based on the current screen width.
  ///
  /// - [xs]: Value for extra small screens (< 600).
  /// - [sm]: Value for small screens (>= 600 && < 960).
  /// - [md]: Value for medium screens (>= 960 && < 1280).
  /// - [lg]: Value for large screens (>= 1280 && < 1920).
  /// - [xl]: Value for extra large screens (>= 1920).
  static T breakpointValue<T>({
    required BuildContext context,
    required T xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
  }) {
    if (isExtraLarge(context)) {
      return xl ?? lg ?? md ?? sm ?? xs;
    } else if (isLarge(context)) {
      return lg ?? md ?? sm ?? xs;
    } else if (isMedium(context)) {
      return md ?? sm ?? xs;
    } else if (isSmall(context)) {
      return sm ?? xs;
    } else {
      return xs;
    }
  }

  /// Returns the number of grid columns based on the current screen size.
  static int getGridColumns(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 4,
    );
  }

  /// Returns the grid item extent based on the current screen size.
  static double getGridItemExtent(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: 150,
      tablet: 200,
      desktop: 250,
    );
  }

  /// Returns the padding based on the current screen size.
  static EdgeInsets getPadding(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: const EdgeInsets.all(8),
      tablet: const EdgeInsets.all(16),
      desktop: const EdgeInsets.all(24),
    );
  }

  /// Returns the maximum width for content based on the current screen size.
  static double getMaxContentWidth(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: double.infinity,
      tablet: 768,
      desktop: 1200,
    );
  }

  /// Returns a widget that adapts to the current screen size.
  ///
  /// - [mobile]: Widget for mobile screens (< 600).
  /// - [tablet]: Widget for tablet screens (>= 600 && < 1280).
  /// - [desktop]: Widget for desktop screens (>= 1280).
  static Widget responsiveWidget({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return responsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Returns a layout builder that provides the available width and height.
  static Widget layoutBuilder({
    required Widget Function(BuildContext context, BoxConstraints constraints)
        builder,
  }) {
    return LayoutBuilder(builder: builder);
  }

  /// Returns a widget that centers its child within the available space.
  ///
  /// If [maxWidth] is provided, the child will be constrained to that width.
  static Widget centerContent({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? getMaxContentWidth(context),
        ),
        child: child,
      ),
    );
  }

  /// Returns a widget that adapts its layout based on the screen orientation.
  ///
  /// - [portrait]: Widget for portrait orientation.
  /// - [landscape]: Widget for landscape orientation.
  static Widget orientationBuilder({
    required BuildContext context,
    required Widget portrait,
    required Widget landscape,
  }) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait ? portrait : landscape;
  }

  /// Returns a boolean indicating if the screen is in portrait orientation.
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Returns a boolean indicating if the screen is in landscape orientation.
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Returns the screen width.
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Returns the screen height.
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Returns the screen size.
  static Size screenSize(BuildContext context) =>
      MediaQuery.of(context).size;

  /// Returns the screen aspect ratio (width / height).
  static double screenAspectRatio(BuildContext context) =>
      screenWidth(context) / screenHeight(context);

  /// Returns the safe area padding.
  static EdgeInsets safeAreaPadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  /// Returns the keyboard height.
  static double keyboardHeight(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom;

  /// Returns a boolean indicating if the keyboard is visible.
  static bool isKeyboardVisible(BuildContext context) =>
      keyboardHeight(context) > 0;
}

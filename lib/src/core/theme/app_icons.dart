import 'package:flutter/material.dart';

/// The application icons.
///
/// This class provides a centralized place for all icons used in the application.
/// We use Material Icons as our primary icon set for consistency.
class AppIcons {
  /// Creates a new [AppIcons] instance.
  const AppIcons._();

  // Navigation Icons
  /// Home icon.
  static const IconData home = Icons.home_outlined;
  /// Inventory icon.
  static const IconData inventory = Icons.inventory_2_outlined;
  /// Analytics icon.
  static const IconData analytics = Icons.analytics_outlined;
  /// Settings icon.
  static const IconData settings = Icons.settings_outlined;

  // Action Icons
  /// Add icon.
  static const IconData add = Icons.add;
  /// Edit icon.
  static const IconData edit = Icons.edit_outlined;
  /// Delete icon.
  static const IconData delete = Icons.delete_outline;
  /// Save icon.
  static const IconData save = Icons.save_outlined;
  /// Close icon.
  static const IconData close = Icons.close;
  /// Search icon.
  static const IconData search = Icons.search;
  /// Filter icon.
  static const IconData filter = Icons.filter_list;
  /// Sort icon.
  static const IconData sort = Icons.sort;
  /// More icon.
  static const IconData more = Icons.more_vert;
  /// Share icon.
  static const IconData share = Icons.share_outlined;
  /// Download icon.
  static const IconData download = Icons.download_outlined;
  /// Upload icon.
  static const IconData upload = Icons.upload_outlined;
  /// Camera icon.
  static const IconData camera = Icons.camera_alt_outlined;
  /// Gallery icon.
  static const IconData gallery = Icons.photo_library_outlined;
  /// Scan icon.
  static const IconData scan = Icons.qr_code_scanner_outlined;

  // Status Icons
  /// Success icon.
  static const IconData success = Icons.check_circle_outline;
  /// Error icon.
  static const IconData error = Icons.error_outline;
  /// Warning icon.
  static const IconData warning = Icons.warning_amber_outlined;
  /// Info icon.
  static const IconData info = Icons.info_outline;
  /// Stale icon.
  static const IconData stale = Icons.access_time;
  /// Sold icon.
  static const IconData sold = Icons.monetization_on_outlined;
  /// Available icon.
  static const IconData available = Icons.check_outlined;
  /// Reserved icon.
  static const IconData reserved = Icons.bookmark_border;

  // Pallet & Item Icons
  /// Pallet icon.
  static const IconData pallet = Icons.view_module_outlined;
  /// Item icon.
  static const IconData item = Icons.inventory_outlined;
  /// Tag icon.
  static const IconData tag = Icons.local_offer_outlined;
  /// Price icon.
  static const IconData price = Icons.attach_money;
  /// Expense icon.
  static const IconData expense = Icons.account_balance_wallet_outlined;
  /// Supplier icon.
  static const IconData supplier = Icons.business_outlined;
  /// Type icon.
  static const IconData type = Icons.category_outlined;
  /// Description icon.
  static const IconData description = Icons.description_outlined;
  /// Quantity icon.
  static const IconData quantity = Icons.format_list_numbered;
  /// Date icon.
  static const IconData date = Icons.calendar_today_outlined;
  
  // Additional Icons
  /// Business icon
  static const IconData business = Icons.business_outlined;
  /// Storefront icon
  static const IconData storefront = Icons.storefront_outlined;
  /// Category icon
  static const IconData category = Icons.category_outlined;
  /// Money icon
  static const IconData money = Icons.attach_money;
  /// Calendar icon
  static const IconData calendar = Icons.calendar_today_outlined;

  // Authentication Icons
  /// Login icon.
  static const IconData login = Icons.login_outlined;
  /// Logout icon.
  static const IconData logout = Icons.logout_outlined;
  /// User icon.
  static const IconData user = Icons.person_outline;
  /// Password icon.
  static const IconData password = Icons.lock_outline;
  /// Email icon.
  static const IconData email = Icons.email_outlined;
  /// Biometric icon.
  static const IconData biometric = Icons.fingerprint;
  /// Fingerprint icon (alias for biometric).
  static const IconData fingerprint = Icons.fingerprint;

  // Theme Icons
  /// Light theme icon.
  static const IconData lightTheme = Icons.light_mode_outlined;
  /// Dark theme icon.
  static const IconData darkTheme = Icons.dark_mode_outlined;
  /// System theme icon.
  static const IconData systemTheme = Icons.brightness_auto;
  
  // Utility Icons
  /// Retry icon.
  static const IconData retry = Icons.refresh;

  // Placeholder: Replace with actual icons from your chosen font package (e.g., FontAwesome, MaterialCommunityIcons, or custom)
  static const IconData goals = Icons.flag_outlined; // Placeholder for goals
  static const IconData security = Icons.security_outlined; // Placeholder for security
  static const IconData barcode = Icons.qr_code_scanner; // Added
  static const IconData report = Icons.description_outlined; // Added
}

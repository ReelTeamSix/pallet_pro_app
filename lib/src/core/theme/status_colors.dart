import 'package:flutter/material.dart';

/// Centralized definitions for status-related colors used throughout the app.
///
/// This ensures consistency in status color representation for both pallets
/// and items across different UI components.
///
/// Color System (per UI/UX Guidelines):
/// - Muted colors (2dp hairline): in_stock, sold
/// - Vibrant colors (6dp border): listed, stale
class StatusColors {
  // Item status colors (per UI/UX Guidelines Section 1)
  // Muted tones for passive states
  static const Color inStock = Color(0xFF9E9E9E); // Grey 500 - muted
  static const Color sold = Color(0xFF81C784); // Green 300 - muted

  // Vibrant tones for action states
  static const Color listed = Color(0xFF64B5F6); // Blue 300 - vibrant
  static const Color forSale = Color(0xFF64B5F6); // Same as listed
  static const Color stale = Color(0xFFFFB74D); // Orange 300 - vibrant

  // Pallet status colors
  static const Color inProgress = Colors.amber;
  static const Color processed = Color(0xFF81C784); // Green 300 - matches sold
  static const Color archived = Color(0xFF9E9E9E); // Grey 500 - matches inStock

  // Error and default colors
  static const Color error = Colors.red;
  static const Color unknown = Color(0xFF9E9E9E); // Grey 500

  // Status edge widths (per UI/UX Guidelines Section 2)
  /// Hairline width for passive states (in_stock, sold)
  static const double hairlineWidth = 2.0;

  /// Border width for action states (listed, stale)
  static const double borderWidth = 6.0;

  /// Reduced width when filtered by status (redundant signal)
  static const double filteredWidth = 3.0;

  /// Returns the appropriate color for a given item status.
  static Color forItemStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_stock':
      case 'instock':
        return inStock;
      case 'for_sale':
      case 'forsale':
      case 'listed':
        return listed;
      case 'sold':
        return sold;
      case 'stale':
        return stale;
      default:
        return unknown;
    }
  }

  /// Returns the appropriate edge width for a given item status.
  /// Muted states get hairline (2dp), action states get border (6dp).
  static double edgeWidthForStatus(String status, {bool isFiltered = false}) {
    if (isFiltered) return filteredWidth;

    switch (status.toLowerCase()) {
      case 'in_stock':
      case 'instock':
      case 'sold':
        return hairlineWidth; // Muted states
      case 'for_sale':
      case 'forsale':
      case 'listed':
      case 'stale':
        return borderWidth; // Action states
      default:
        return hairlineWidth;
    }
  }

  /// Returns true if the status is an action state (vibrant color, 6dp border).
  static bool isActionState(String status) {
    switch (status.toLowerCase()) {
      case 'for_sale':
      case 'forsale':
      case 'listed':
      case 'stale':
        return true;
      default:
        return false;
    }
  }

  /// Returns the appropriate color for a given pallet status.
  static Color forPalletStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'inprogress':
        return inProgress;
      case 'processed':
        return processed;
      case 'archived':
        return archived;
      default:
        return unknown;
    }
  }
}

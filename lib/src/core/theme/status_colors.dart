import 'package:flutter/material.dart';

/// Centralized definitions for status-related colors used throughout the app.
/// 
/// This ensures consistency in status color representation for both pallets 
/// and items across different UI components.
class StatusColors {
  // Item status colors
  static const Color inStock = Colors.blue;
  static const Color listed = Colors.purple;
  static const Color forSale = Colors.orange;
  static const Color sold = Colors.green;
  
  // Pallet status colors
  static const Color inProgress = Colors.amber;
  static const Color processed = Colors.green;
  static const Color archived = Colors.grey;
  
  // Error and default colors
  static const Color error = Colors.red;
  static const Color unknown = Colors.grey;
  
  /// Returns the appropriate color for a given item status.
  static Color forItemStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_stock':
        return inStock;
      case 'for_sale':
      case 'listed':
        return listed;
      case 'sold':
        return sold;
      default:
        return unknown;
    }
  }
  
  /// Returns the appropriate color for a given pallet status.
  static Color forPalletStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
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
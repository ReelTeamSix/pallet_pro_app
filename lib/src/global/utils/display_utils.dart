import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';

/// Returns the appropriate currency symbol based on the user's locale
/// Currently defaults to USD ($) but could be expanded based on user settings
String getCurrencySymbol() {
  // Default to USD
  return NumberFormat.simpleCurrency(locale: 'en_US').currencySymbol;
  
  // For future implementation with user-selected currency:
  // final userCurrency = ref.watch(userSettingsProvider).currency ?? 'USD';
  // return NumberFormat.simpleCurrency(name: userCurrency).currencySymbol;
}

/// Formats a price value with the appropriate currency symbol
String formatPrice(double price) {
  return '${getCurrencySymbol()}${price.toStringAsFixed(2)}';
}

/// Formats a date as a short readable string (e.g., "Mar 15, 2023")
String formatShortDate(DateTime? date) {
  if (date == null) return 'N/A';
  return DateFormat.yMMMd().format(date);
}

/// Formats a date with time (e.g., "Mar 15, 2023 at 2:30 PM")
String formatDateWithTime(DateTime? date) {
  if (date == null) return 'N/A';
  return DateFormat.yMMMd().add_jm().format(date);
}

/// Calculates profit and returns it formatted with color
Widget getProfitWidget(double revenue, double cost) {
  final profit = revenue - cost;
  final isProfit = profit >= 0;
  
  return Text(
    formatPrice(profit.abs()),
    style: TextStyle(
      color: isProfit ? Colors.green : Colors.red,
      fontWeight: FontWeight.bold,
    ),
    overflow: TextOverflow.ellipsis,
  );
}

/// Calculates profit margin as a percentage
String getProfitMargin(double revenue, double cost) {
  if (revenue <= 0) return '0%';
  
  final margin = ((revenue - cost) / revenue) * 100;
  return '${margin.toStringAsFixed(1)}%';
}

/// Returns a color based on profit margin
Color getProfitMarginColor(double revenue, double cost) {
  if (revenue <= 0) return Colors.grey;
  
  final margin = ((revenue - cost) / revenue) * 100;
  
  if (margin >= 30) return Colors.green;
  if (margin >= 15) return Colors.lightGreen;
  if (margin >= 5) return Colors.amber;
  if (margin >= 0) return Colors.orange;
  return Colors.red;
} 
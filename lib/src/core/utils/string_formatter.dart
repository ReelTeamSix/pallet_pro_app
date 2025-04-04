/// Utility methods for string formatting commonly used throughout the app.
class StringFormatter {
  /// Formats a snake_case string to Title Case.
  /// 
  /// For example, converts "in_stock" to "In Stock".
  static String snakeCaseToTitleCase(String input) {
    if (input.isEmpty) return '';
    
    return input
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
} 
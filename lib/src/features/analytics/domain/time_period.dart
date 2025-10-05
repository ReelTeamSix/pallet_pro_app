import 'package:flutter/material.dart';

/// Time period options for analytics filtering
enum TimePeriod {
  last7Days('Last 7 Days', 7),
  last30Days('Last 30 Days', 30),
  last90Days('Last 90 Days', 90), // FREE tier limit
  allTime('All Time', null), // PREMIUM feature
  custom('Custom Range', null); // PREMIUM feature

  const TimePeriod(this.label, this.days);

  final String label;
  final int? days;

  /// Convert to DateTimeRange
  DateTimeRange toDateRange({DateTime? customStart, DateTime? customEnd}) {
    final now = DateTime.now();

    switch (this) {
      case TimePeriod.last7Days:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      case TimePeriod.last30Days:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
      case TimePeriod.last90Days:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 90)),
          end: now,
        );
      case TimePeriod.allTime:
        // Use a very early date (or fetch from first item)
        return DateTimeRange(
          start: DateTime(2020, 1, 1),
          end: now,
        );
      case TimePeriod.custom:
        if (customStart == null || customEnd == null) {
          throw ArgumentError('Custom period requires start and end dates');
        }
        return DateTimeRange(start: customStart, end: customEnd);
    }
  }

  /// Check if this is a premium feature
  bool get isPremium => this == TimePeriod.allTime || this == TimePeriod.custom;

  /// Get icon for time period
  IconData get icon {
    switch (this) {
      case TimePeriod.last7Days:
        return Icons.calendar_view_week;
      case TimePeriod.last30Days:
        return Icons.calendar_view_month;
      case TimePeriod.last90Days:
        return Icons.calendar_today;
      case TimePeriod.allTime:
        return Icons.all_inclusive;
      case TimePeriod.custom:
        return Icons.date_range;
    }
  }
}

/// Time resolution for grouping data in charts
enum TimeResolution {
  day('Daily', 1),
  week('Weekly', 7),
  month('Monthly', 30),
  year('Yearly', 365);

  const TimeResolution(this.label, this.days);

  final String label;
  final int days;

  /// Determine best resolution based on date range
  static TimeResolution forDateRange(DateTimeRange range) {
    final duration = range.duration;

    if (duration.inDays <= 31) {
      return TimeResolution.day;
    } else if (duration.inDays <= 180) {
      return TimeResolution.week;
    } else if (duration.inDays <= 730) {
      // ~2 years
      return TimeResolution.month;
    } else {
      return TimeResolution.year;
    }
  }

  /// Get SQL date truncation string for PostgreSQL
  String get sqlTruncation {
    switch (this) {
      case TimeResolution.day:
        return 'day';
      case TimeResolution.week:
        return 'week';
      case TimeResolution.month:
        return 'month';
      case TimeResolution.year:
        return 'year';
    }
  }
}


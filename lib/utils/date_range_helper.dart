// lib/utils/date_range_helper.dart
import 'package:flutter/material.dart';

/// Helper class for date range operations used across the app.
class DateRangeHelper {
  /// Returns the current month's date range with time set to start and end of day.
  static DateTimeRange getCurrentMonthRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateTimeRange(start: startOfMonth, end: endOfMonth);
  }

  /// Formats a DateTimeRange into a readable label.
  /// Returns 'All Time' if dateRange is null.
  static String getDateLabel(DateTimeRange? dateRange) {
    if (dateRange == null) {
      return 'All Time';
    }
    final startStr = formatDate(dateRange.start);
    final endStr = formatDate(dateRange.end);
    return '$startStr - $endStr';
  }

  /// Formats a single date as d/M/yyyy.
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Ensures the end time of a DateTimeRange includes the full day (23:59:59).
  static DateTimeRange withFullEndDay(DateTimeRange range) {
    final endDate = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      23,
      59,
      59,
    );
    return DateTimeRange(start: range.start, end: endDate);
  }

  /// Shows the date range picker dialog with proper constraints.
  /// Returns the selected DateTimeRange or null if cancelled.
  static Future<DateTimeRange?> showPicker(
    BuildContext context, {
    DateTimeRange? initialRange,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    try {
      final now = DateTime.now();
      final effectiveLastDate =
          lastDate ?? DateTime(now.year, now.month, now.day);
      final effectiveFirstDate = firstDate ?? DateTime(2020);

      DateTimeRange? clampedInitialRange;
      if (initialRange != null) {
        // Clamp the existing date range to ensure it's within valid bounds
        final clampedStart = initialRange.start.isBefore(effectiveFirstDate)
            ? effectiveFirstDate
            : (initialRange.start.isAfter(effectiveLastDate)
                  ? effectiveLastDate
                  : initialRange.start);
        final clampedEnd = initialRange.end.isAfter(effectiveLastDate)
            ? effectiveLastDate
            : (initialRange.end.isBefore(clampedStart)
                  ? clampedStart
                  : initialRange.end);
        clampedInitialRange = DateTimeRange(start: clampedStart, end: clampedEnd);
      }

      final picked = await showDateRangePicker(
        context: context,
        firstDate: effectiveFirstDate,
        lastDate: effectiveLastDate,
        initialDateRange: clampedInitialRange,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600, maxHeight: 600),
                child: child,
              ),
            ),
          );
        },
      );

      if (picked != null) {
        return withFullEndDay(picked);
      }
      return null;
    } catch (e) {
      debugPrint('Error showing date range picker: $e');
      return null;
    }
  }
}

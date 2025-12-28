/// Date utilities for consistent expiry calculations across the app
///
/// This is the SINGLE SOURCE OF TRUTH for all expiry-related calculations.
/// All screens should use these utilities instead of calculating directly.
class DateUtils {
  DateUtils._();

  /// Normalize a DateTime to midnight (00:00:00) of the same day
  /// This ensures consistent date comparisons regardless of time
  static DateTime normalizeToMidnight(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Calculate days until expiry from today
  ///
  /// Returns:
  /// - Positive number: days until expiry
  /// - Zero: expires today
  /// - Negative number: days since expired
  static int daysUntilExpiry(DateTime expiryDate) {
    final today = normalizeToMidnight(DateTime.now());
    final expiry = normalizeToMidnight(expiryDate);
    return expiry.difference(today).inDays;
  }

  /// Check if a date is expiring soon (within 3 days)
  static bool isExpiringSoon(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    final days = daysUntilExpiry(expiryDate);
    return days >= 0 && days <= 3;
  }

  /// Check if a date is today
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    return daysUntilExpiry(date) == 0;
  }

  /// Check if a date has expired
  static bool isExpired(DateTime? date) {
    if (date == null) return false;
    return daysUntilExpiry(date) < 0;
  }

  /// Format days until expiry as human-readable text
  ///
  /// Examples:
  /// - -2 days: "Expired"
  /// - 0 days: "Today"
  /// - 1 day: "Tomorrow"
  /// - 5 days: "In 5 days"
  static String formatDaysUntilExpiry(DateTime? date) {
    if (date == null) return 'Set date';

    final days = daysUntilExpiry(date);

    if (days < 0) return 'Expired';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 7) return 'In $days days';

    // For dates more than a week away, let the caller format it
    return 'In $days days';
  }
}

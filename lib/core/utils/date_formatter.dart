/// Tiny date helpers (avoids pulling in the `intl` package).
class DateFormatter {
  DateFormatter._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// e.g. `06 Oct 2026`
  static String date(DateTime? value) {
    if (value == null) return '—';
    final d = value.toLocal();
    return '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';
  }

  /// e.g. `5 min ago`, `2 days ago`
  static String timeAgo(DateTime? value) {
    if (value == null) return 'just now';
    final diff = DateTime.now().difference(value.toLocal());
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    return date(value);
  }
}

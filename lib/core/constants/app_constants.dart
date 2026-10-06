/// App-wide constants. Keep magic strings here so they are defined once.
class AppConstants {
  AppConstants._();

  static const String appName = 'FixIt';
  static const String tagline = 'See it. Report it. Fix it.';
  static const String footer = 'FIXIT • Community Issue Resolution';
}

/// Built-in admin account. It is created automatically the first time these
/// credentials are used on the login screen. Change them before a real release
/// (and keep firestore.rules `adminEmail` in sync).
class DefaultAdmin {
  DefaultAdmin._();

  static const String email = 'admin@fixit.com';
  static const String password = 'Admin@123';
  static const String name = 'FixIt Admin';
  static const String phone = '0000000000';
}

/// Firestore collection names.
class Collections {
  Collections._();

  static const String users = 'users';
  static const String issues = 'issues';
}

/// Roles stored in `users/{uid}.role`.
class UserRole {
  UserRole._();

  static const String user = 'user';
  static const String admin = 'admin';
}

/// Issue lifecycle statuses stored in `issues/{id}.status`.
class IssueStatus {
  IssueStatus._();

  static const String reported = 'Reported';
  static const String inProgress = 'In Progress';
  static const String resolved = 'Resolved';

  static const List<String> all = [reported, inProgress, resolved];
}

/// Categories a citizen can pick when reporting an issue.
class IssueCategories {
  IssueCategories._();

  static const List<String> all = [
    'Road & Pothole',
    'Street Light',
    'Waste Management',
    'Water Supply',
    'Drainage',
    'Public Safety',
    'Other',
  ];
}

// Error and validation messages
class StringConstants {
  // Auth messages
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordWeakness =
      'Password must contain uppercase, lowercase, and number';
  static const String emptyName = 'Name cannot be empty';
  static const String loginSuccess = 'Logged in successfully';
  static const String logoutSuccess = 'Logged out successfully';
  static const String registerSuccess = 'Account created successfully';

  // Scan messages
  static const String scanInProgress = 'Analyzing food...';
  static const String scanSuccess = 'Food detected successfully';
  static const String scanFailed = 'Failed to analyze image';
  static const String uploadInProgress = 'Uploading image...';
  static const String uploadFailed = 'Failed to upload image';

  // Profile messages
  static const String profileUpdated = 'Profile updated successfully';
  static const String profileUpdateFailed = 'Failed to update profile';
  static const String invalidWeight = 'Weight must be between 20 and 300 kg';
  static const String invalidHeight = 'Height must be between 50 and 250 cm';
  static const String invalidAge = 'Age must be between 10 and 120';

  // Network messages
  static const String networkError = 'No internet connection';
  static const String serverError = 'Server error. Please try again';
  static const String timeoutError = 'Request timeout. Please try again';
  static const String unknownError = 'An unknown error occurred';

  // General
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String ok = 'OK';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
}

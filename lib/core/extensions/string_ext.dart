// Extension methods for String
extension StringExt on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Check if email is valid
  bool get isValidEmail {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(this);
  }

  /// Check if password is strong
  bool get isStrongPassword {
    return length >= 8 &&
        contains(RegExp(r'[A-Z]')) &&
        contains(RegExp(r'[0-9]'));
  }

  /// Remove all whitespace
  String get removeWhitespace {
    return replaceAll(' ', '');
  }
}

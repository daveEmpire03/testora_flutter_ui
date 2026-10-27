import 'package:flutter/material.dart';

/// Formats an integer amount of naira with ₦ prefix and comma separators.
/// Used across all payment screens.
String formatNaira(int amount) {
  final raw = amount.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < raw.length; index++) {
    if (index > 0 && (raw.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(raw[index]);
  }

  return '₦$buffer';
}

/// Resolves an [IconData] from a string icon key stored on a package/entity.
/// Add new keys here as needed.
IconData paymentIconFor(String key) {
  switch (key) {
    case 'school':
      return Icons.school_outlined;
    case 'menu_book':
      return Icons.menu_book_outlined;
    case 'account_balance':
      return Icons.account_balance_outlined;
    case 'workspace_premium':
      return Icons.workspace_premium_outlined;
    default:
      return Icons.quiz_outlined;
  }
}

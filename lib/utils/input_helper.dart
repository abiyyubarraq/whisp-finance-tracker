import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Allow empty string
    if (text.isEmpty) return newValue;

    // Only allow digits and one decimal point
    final regex = RegExp(r'^\d*\.?\d*$');
    if (!regex.hasMatch(text)) {
      return oldValue; // Reject the change
    }

    // Prevent multiple decimal points
    final decimalCount = '.'.allMatches(text).length;
    if (decimalCount > 1) {
      return oldValue; // Reject the change
    }

    return newValue;
  }
}

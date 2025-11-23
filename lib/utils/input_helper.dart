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

/// Formatter that multiplies first digit by 1000, then appends subsequent digits
/// Pattern: empty -> type 3 -> 3000, then type 4 -> 34000, then type 5 -> 345000
class ThousandMultiplierFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    // Allow empty string (deletion)
    if (newText.isEmpty) return newValue;

    // Only allow digits and one decimal point
    final regex = RegExp(r'^\d*\.?\d*$');
    if (!regex.hasMatch(newText)) {
      return oldValue; // Reject the change
    }

    // Prevent multiple decimal points
    final decimalCount = '.'.allMatches(newText).length;
    if (decimalCount > 1) {
      return oldValue; // Reject the change
    }

    // Handle deletion (if new text is shorter, allow it)
    if (newText.length < oldText.length) {
      return newValue;
    }

    // Check if a new digit is being added
    if (newText.length > oldText.length) {
      // Get the newly added digit(s)
      final addedText = newText.substring(oldText.length);
      final newDigitMatch = RegExp(r'^\d').firstMatch(addedText);

      if (newDigitMatch != null) {
        final newDigit = int.parse(newDigitMatch.group(0)!);

        // If field was empty, multiply first digit by 1000
        if (oldText.isEmpty) {
          final multipliedValue = (newDigit * 1000).toString();
          return TextEditingValue(
            text: multipliedValue,
            selection: TextSelection.collapsed(offset: multipliedValue.length),
          );
        }

        // For subsequent digits: previous_value * 10 + new_digit * 1000
        final oldValueNum = double.tryParse(oldText);
        if (oldValueNum != null) {
          final newValueNum = (oldValueNum * 10) + (newDigit * 1000);
          final newValueStr = newValueNum.toStringAsFixed(0);
          return TextEditingValue(
            text: newValueStr,
            selection: TextSelection.collapsed(offset: newValueStr.length),
          );
        }
      }
    }

    // For other cases (like decimal point), allow normal input
    return newValue;
  }
}

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class InputNumberFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    //remove existing commas
    String cleaned = newValue.text.replaceAll(',', ',');

    //parse as number
    final number = int.tryParse(cleaned);
    if (number == null) return oldValue;

    final newString = _formatter.format(number);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

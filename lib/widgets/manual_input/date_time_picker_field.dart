// lib/widgets/manual_input/date_time_picker_field.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../glass_container.dart';

class DateTimePickerField extends StatelessWidget {
  final DateTime selectedDateTime;
  final Function(DateTime) onDateTimeChanged;

  const DateTimePickerField({
    super.key,
    required this.selectedDateTime,
    required this.onDateTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _pickDateTime(context),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 20),
              SizedBox(width: 12),
              Text(
                DateFormat('MMM dd, yyyy').format(selectedDateTime),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      // Set time to 12:00 PM (noon) automatically
      onDateTimeChanged(
        DateTime(date.year, date.month, date.day, 12, 0),
      );
    }
  }
}

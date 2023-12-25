import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/consts.dart';
import '../utils/strings.dart';
import '../water_reminder_page.dart';

/// card widget
/// [title] - widget title
/// [checkBoxTitle] - checkbox description text
/// [isStart] - define widget designation
/// true - its the start time widget
/// false - its the end time widget
class CardWidget extends StatefulWidget {
  final String title;
  final String checkBoxTitle;
  final bool isStart;

  const CardWidget(
      {super.key,
      required this.title,
      required this.checkBoxTitle,
      required this.isStart});

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {

  bool _checkBoxValue = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  late String _hour, _minute, _dateTimeFormatted;

  @override
  void initState() {
    super.initState();
    _dateTimeToString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey,
      shadowColor: Colors.black,
      margin: const EdgeInsets.all(20),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(widget.title, style: textStyle),
          Text(_dateTimeFormatted),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(children: [
                Checkbox(
                    value: _checkBoxValue,
                    onChanged: (bool? newValue) {
                      setState(() {
                        /// update parent widget values
                        /// use only findAncestorStateOfType
                        if (widget.isStart) {
                          context
                              .findAncestorStateOfType<WaterReminderPageState>()
                              ?.isStartAtOnce = newValue!;
                        } else {
                          context
                              .findAncestorStateOfType<WaterReminderPageState>()
                              ?.isEndlessly = newValue!;
                        }
                        _checkBoxValue = newValue!;
                      });
                    }),
                Text(widget.checkBoxTitle),
              ]),
              OutlinedButton(
                  onPressed: () => _selectDateTime(context),
                  child: const Text(Strings.btnText)
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    await _selectDate(context);
    if (!context.mounted) return;
    await _selectTime(context);
  }

  /// show Date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        initialDatePickerMode: DatePickerMode.day);

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (widget.isStart) {
          context.findAncestorStateOfType<WaterReminderPageState>()?.startDate =
              _selectedDate;
        } else {
          context.findAncestorStateOfType<WaterReminderPageState>()?.endDate =
              _selectedDate;
        }
        _dateTimeToString();
      });
    }
  }

  /// show Time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        if (widget.isStart) {
          context.findAncestorStateOfType<WaterReminderPageState>()?.startTime =
              _selectedTime;
        } else {
          context.findAncestorStateOfType<WaterReminderPageState>()?.endTime =
              _selectedTime;
        }
        _dateTimeToString();
      });
    }
  }

  /// convert date and time to formatted output string value
  void _dateTimeToString() {
    _dateTimeFormatted = DateFormat.yMd().format(_selectedDate);
    _hour = _selectedTime.hour.toString();
    _minute = _selectedTime.minute.toString();
    _dateTimeFormatted = '$_dateTimeFormatted - $_hour:$_minute';
  }

}

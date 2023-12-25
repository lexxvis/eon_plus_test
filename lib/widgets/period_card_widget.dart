import 'package:eon_plus_test/water_reminder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/consts.dart';
import '../utils/strings.dart';

const _inputDecoration = InputDecoration(
  filled: true,
  counterText: '',
  isDense: true,
  fillColor: Colors.white,
  border: InputBorder.none,
  contentPadding: EdgeInsets.only(left: 5, right: 5),
  errorStyle: TextStyle(fontSize: 0),
);

class PeriodCardWidget extends StatefulWidget {
  const PeriodCardWidget({super.key});

  @override
  State<PeriodCardWidget> createState() => _PeriodCardWidgetState();
}

class _PeriodCardWidgetState extends State<PeriodCardWidget> {

  final _formKey = GlobalKey<FormState>();

  /// input controllers
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;

  bool _isDisable = false;

  @override
  void initState() {
    super.initState();

    FocusManager.instance.primaryFocus?.unfocus();
    _hoursController = TextEditingController(
        text: context
            .findAncestorStateOfType<WaterReminderPageState>()
            ?.periodHours
            .toString())
      ..addListener(() {
        /// check if input field is empty or not to control Start button
        if (_hoursController.text.isEmpty) {
          _isDisable = true;
        } else {
          _isDisable = false;
        }
        setState(() {});
      });

    _minutesController = TextEditingController(
        text: context
            .findAncestorStateOfType<WaterReminderPageState>()
            ?.periodMinutes
            .toString())
      ..addListener(() {
        /// check if input field is empty or
        /// minutes > 15 and < 60
        /// to control Start button
        /// min 15 minutes - this this the limitation of workmangaer plugin
        if ((_minutesController.text.isEmpty) ||
            (int.parse(_minutesController.text) > 59)) {
          _isDisable = true;
        } else {
          _isDisable = false;
        }
        if ((int.parse(_hoursController.text) == 0) &&
            (int.parse(_minutesController.text) <= 15)) {
          _isDisable = true;
        }
        setState(() {});
      });
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _hoursController.dispose();
    super.dispose();
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
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               Expanded(
                child: Text(Strings.changeTimeWidgetTitle, style: textStyle),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                        flex: 2,
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(Strings.hours))),
                    Expanded(
                        flex: 1,
                        child: TextFormField(
                          autofocus: false,
                          maxLength: 2,
                          controller: _hoursController,
                          decoration: _inputDecoration,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        )),
                    const Expanded(flex: 1, child: SizedBox()),
                    const Expanded(flex: 2, child: Text(Strings.minutes)),
                    Expanded(
                        flex: 1,
                        child: TextFormField(
                          autofocus: false,
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _minutesController,
                          decoration: _inputDecoration,
                        )),
                    const Expanded(flex: 1, child: SizedBox()),
                  ],
                ),
              ),
              OutlinedButton(
                  onPressed: _isDisable
                      ? null
                      : () {
                    /// start work manager, invokes from parent widget
                          final hours = int.parse(_hoursController.text);
                          final minutes = int.parse(_minutesController.text);
                          context
                              .findAncestorStateOfType<WaterReminderPageState>()
                              ?.startReminder(hours, minutes);
                        },
                  child: const Text(Strings.startBtnText)
              ),
            ],
          ),
        ),
      ),
    );
  }
}

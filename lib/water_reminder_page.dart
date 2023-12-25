import 'package:eon_plus_test/utils/consts.dart';
import 'package:eon_plus_test/utils/strings.dart';
import 'package:eon_plus_test/widgets/card_widget.dart';
import 'package:eon_plus_test/widgets/period_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';


SnackBar _snack(String msg) {
  return  SnackBar(
    backgroundColor: Colors.deepPurple,
    content: Text(msg),
    duration: snackBarDuration,
  );
}


class WaterReminderPage extends StatefulWidget {
  const WaterReminderPage({super.key});

  @override
  State<WaterReminderPage> createState() => WaterReminderPageState();
}

class WaterReminderPageState extends State<WaterReminderPage> {

  DateTime startDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();

  DateTime endDate = DateTime.now();
  TimeOfDay endTime = TimeOfDay.now();

  bool isStartAtOnce = false;
  bool isEndlessly = false;

  /// default period
  int periodHours = 1;
  int periodMinutes = 30;

  @override
  Widget build(BuildContext context) {
    DateTime lastExitTime = DateTime.now();
    return WillPopScope(
      /// handle back btn press
        onWillPop: () async {
          if (DateTime.now().difference(lastExitTime) >= const Duration(seconds: 2)) {
            ScaffoldMessenger.of(context)
                .showSnackBar(_snack(Strings.exitConfirmationMsg));
            lastExitTime = DateTime.now();
            return false; // disable back press
          } else {
            return true; //  exit the app
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Center(child: Text(Strings.appTitle)),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            /// use CustomScrollView with Slivers to correct widget visualization
            /// when soft keyboard is appeared
            body: const CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: CardWidget(
                              title: Strings.startTimeWidgetTitle,
                              checkBoxTitle: Strings.startTimeWidgetCheckBox,
                              isStart: true),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: CardWidget(
                              title: Strings.endTimeWidgetTitle,
                              checkBoxTitle: Strings.endTimeWidgetCheckBox,
                              isStart: false),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: PeriodCardWidget(),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
        )
    );
  }

  /// start reminder service
  Future<void> startReminder(int hours, int minutes) async {

    /// generate full start period DateTime
    DateTime fullStartDate = DateTime(startDate.year, startDate.month,
        startDate.day, startTime.hour, startTime.minute);

    /// generate full end period DateTime
    DateTime fullEndDate = DateTime(
        endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);

    /// generate full current DateTime with seconds = 0
    DateTime fullCurrentDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        DateTime.now().hour,
        DateTime.now().minute
    );

    /// check start and end periods fo correct values
    bool startFlag = false;
    if (fullCurrentDate.compareTo(fullStartDate) > 0 ||
        fullStartDate.compareTo(fullEndDate) > 0) {
      startFlag = true;
    }

    /// disable check periods if flag [isStartAtOnce] is set
    if(isStartAtOnce) startFlag = false;

    bool endFlag = false;
    if(fullCurrentDate.compareTo(fullEndDate) >= 0) {
      endFlag = true;
    }
    /// disable check periods if flag [isStartAtOnce] is set
    if(isEndlessly) endFlag = false;


    if (startFlag || endFlag) {
      /// date time periods error, show snackbar
      /// (i.e current time > start or end time, or end time > start time
      ScaffoldMessenger.of(context).showSnackBar(_snack(Strings.errorDateSnackMsg));
    } else {
      final prefs = await SharedPreferences.getInstance();
      /// save end period and endlessly flag
      prefs.setString(sharedPrefEndDateKey, fullEndDate.toString());
      prefs.setBool(sharedPrefEndlessKey, isEndlessly);
      Workmanager().cancelAll();
      if (!isStartAtOnce) {
        /// start workmanager if start period is not set
        /// use delay = period
        final dif = fullStartDate.difference(fullCurrentDate);
        Workmanager().registerPeriodicTask(
            rescheduledTaskKey, rescheduledTaskKey,
            initialDelay: dif,
            frequency: Duration(hours: hours, minutes: minutes));
      } else {
        /// start workmanager with previously set period
        Workmanager().registerPeriodicTask(
            rescheduledTaskKey, rescheduledTaskKey,
            initialDelay: Duration(hours: hours, minutes: minutes),
            frequency: Duration(hours: hours, minutes: minutes));
      }
      /// check if context exist (after await calls)
      if (!context.mounted) return;
      /// chow snackbar
      ScaffoldMessenger.of(context).showSnackBar(_snack(Strings.startOkSnackMsg));
    }
  }

}

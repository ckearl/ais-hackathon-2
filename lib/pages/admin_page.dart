import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../widgets/riverpod_stuff.dart';

final startTimeProvider = StateNotifierProvider<StartTimeNotifier, TimeOfDay>(
  (ref) => StartTimeNotifier(),
);
final endTimeProvider = StateNotifierProvider<EndTimeNotifier, TimeOfDay>(
  (ref) => EndTimeNotifier(),
);
final startDayProvider = StateNotifierProvider<StartDayNotifier, DateTime>(
  (ref) => StartDayNotifier(),
);
final endDayProvider = StateNotifierProvider<EndDayNotifier, DateTime>(
  (ref) => EndDayNotifier(),
);

class AdminPage extends StatefulWidget {
  final DatabaseReference dbRef;
  final WidgetRef ref;
  final String userId;
  const AdminPage({
    super.key,
    required this.dbRef,
    required this.ref,
    required this.userId,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("You are an admin!")],
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(constraints.maxWidth * 0.07),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateStuffPage(
                          dbRef: widget.dbRef,
                          ref: widget.ref,
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                  backgroundColor: const Color.fromRGBO(0, 87, 184, 1),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class CreateStuffPage extends StatefulWidget {
  final DatabaseReference dbRef;
  final WidgetRef ref;
  final String userId;
  const CreateStuffPage({
    super.key,
    required this.dbRef,
    required this.ref,
    required this.userId,
  });

  @override
  State<CreateStuffPage> createState() => _CreateStuffPageState();
}

class _CreateStuffPageState extends State<CreateStuffPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController infoController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();

  DateTime? selectedDateStart;
  DateTime? selectedDateEnd;
  TimeOfDay? selectedTimeStart;
  TimeOfDay? selectedTimeEnd;
  late DateSelectorFormField dayTimeStartFormField;
  late DateSelectorFormField dayTimeEndFormField;
  late TimePickerFormField startTimeFormField;
  late TimePickerFormField endTimeFormField;

  @override
  void initState() {
    super.initState();

    dayTimeStartFormField = DateSelectorFormField(
      onDateSelected: (date) {
        widget.ref.read(startDayProvider.notifier).setTime(date!);
      },
      hint: 'Start Date',
      ref: widget.ref,
      startDay: true,
    );
    dayTimeEndFormField = DateSelectorFormField(
      onDateSelected: (date) {
        widget.ref.read(endDayProvider.notifier).setTime(date!);
      },
      hint: 'End Date',
      ref: widget.ref,
      startDay: false,
    );
    startTimeFormField = TimePickerFormField(
      onTimeSelected: (time) {
        widget.ref.read(startTimeProvider.notifier).setTime(time!);
      },
      hint: 'Start Time',
      ref: widget.ref,
      startTime: true,
    );
    endTimeFormField = TimePickerFormField(
      onTimeSelected: (time) {
        widget.ref.read(endTimeProvider.notifier).setTime(time!);
      },
      hint: 'End Time',
      ref: widget.ref,
      startTime: false,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    infoController.dispose();
    locationController.dispose();
    startController.dispose();
    endController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Adding Events to Database"),
        backgroundColor: const Color.fromRGBO(0, 87, 184, 1),
        centerTitle: true,
      ),
      body: Consumer(
        builder: (context, ref, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                (MediaQuery.of(context).viewInsets.bottom + 20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      hintText: "eg. Hackathon",
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "eg. Headliner",
                    ),
                  ),
                  TextField(
                    controller: infoController,
                    decoration: const InputDecoration(
                      labelText: "Info",
                      hintText:
                          "eg. Longer Description (can span multiple lines but only 3 show)",
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: "Location",
                      hintText: "eg. TNRB W328",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: dayTimeStartFormField,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: dayTimeEndFormField,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: startTimeFormField,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: endTimeFormField,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      selectedDateStart = widget.ref.watch(startDayProvider);
                      selectedDateEnd = widget.ref.watch(endDayProvider);
                      selectedTimeStart = widget.ref.watch(startTimeProvider);
                      selectedTimeEnd = widget.ref.watch(endTimeProvider);

                      debugPrint("dayTimeFormField: $selectedDateStart\n"
                          "dayTimeFormField: $selectedDateEnd\n"
                          "startTimeFormField: $selectedTimeStart\n"
                          "endTimeFormField: $selectedTimeEnd\n");

                      DateTime combinedDateStartTime = DateTime(
                        selectedDateStart?.year ?? DateTime.now().year,
                        selectedDateStart?.month ?? DateTime.now().month,
                        selectedDateStart?.day ?? DateTime.now().day,
                        selectedTimeStart?.hour ?? DateTime.now().hour,
                        selectedTimeStart?.minute ?? DateTime.now().minute,
                      );
                      DateTime combinedDateEndTime = DateTime(
                        selectedDateEnd?.year ?? DateTime.now().year,
                        selectedDateEnd?.month ?? DateTime.now().month,
                        selectedDateEnd?.day ?? DateTime.now().day,
                        selectedTimeEnd?.hour ?? DateTime.now().hour,
                        selectedTimeEnd?.minute ?? DateTime.now().minute,
                      );

                      debugPrint("Start DateTime: $combinedDateStartTime");
                      debugPrint("End DateTime: $combinedDateEndTime");

                      final id = DateTime.now().microsecond.toString();
                      widget.dbRef.child('events').child(id).set({
                        'eventTitle': titleController.text.toString(),
                        'eventDescription':
                            descriptionController.text.toString(),
                        'eventInfo': infoController.text.toString(),
                        'eventLocation': locationController.text.toString(),
                        'eventStartTime': combinedDateStartTime.toString(),
                        'eventEndTime': combinedDateEndTime.toString()
                      });

                      Navigator.pop(context);
                    },
                    child: const Text("add"),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TimePickerFormField extends StatefulWidget {
  final Function(TimeOfDay? selectedTime) onTimeSelected;
  final String hint;
  final WidgetRef ref;
  final bool startTime;
  const TimePickerFormField({
    super.key,
    required this.onTimeSelected,
    required this.hint,
    required this.ref,
    required this.startTime,
  });

  @override
  TimePickerFormFieldState createState() => TimePickerFormFieldState();
}

class TimePickerFormFieldState extends State<TimePickerFormField> {
  TimeOfDay? _selectedTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }

    widget.onTimeSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.hint,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          onTap: () {
            _selectTime(context);
          },
          decoration: InputDecoration(
            hintText: _selectedTime != null
                ? _selectedTime!.format(context)
                : widget.hint,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.access_time),
          ),
        ),
      ],
    );
  }
}

class DateSelectorFormField extends StatefulWidget {
  final Function(DateTime? selectedDate) onDateSelected;
  final String hint;
  final WidgetRef ref;
  final bool startDay;
  const DateSelectorFormField({
    super.key,
    required this.onDateSelected,
    required this.hint,
    required this.ref,
    required this.startDay,
  });

  @override
  DateSelectorFormFieldState createState() => DateSelectorFormFieldState();
}

class DateSelectorFormFieldState extends State<DateSelectorFormField> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 4)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 50)),
    );
    debugPrint("Same day? -> ${!isSameDay(picked, _selectedDate)}");
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        debugPrint("Setting state");
      });
    }

    widget.onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      onTap: () {
        _selectDate(context);
      },
      decoration: InputDecoration(
        hintText: _selectedDate != null
            ? DateFormat("MM/dd/yyyy").format(_selectedDate!)
            : widget.hint,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }
}

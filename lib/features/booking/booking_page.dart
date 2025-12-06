import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _reason = TextEditingController();
  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Extra Lecture')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
                title: const Text('Date'),
                subtitle: Text(_date?.toIso8601String() ?? 'Not set'),
                onTap: () async {
                  final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (d != null) setState(() => _date = d);
                }),
            Row(children: [
              Expanded(
                  child: ListTile(
                      title: const Text('Start'),
                      subtitle: Text(_start?.format(context) ?? 'Not set'),
                      onTap: () async {
                        final t = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (t != null) setState(() => _start = t);
                      })),
              Expanded(
                  child: ListTile(
                      title: const Text('End'),
                      subtitle: Text(_end?.format(context) ?? 'Not set'),
                      onTap: () async {
                        final t = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (t != null) setState(() => _end = t);
                      }))
            ]),
            TextField(
                controller: _reason,
                decoration: const InputDecoration(labelText: 'Reason')),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request sent (mock)')));
                },
                child: const Text('Request Booking'))
          ],
        ),
      ),
    );
  }
}

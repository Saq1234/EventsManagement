import 'package:eventmanagement/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'model/event_model.dart';
import 'screens/event_detail_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EventCalendarScreen(),
    );
  }
}

class EventCalendarScreen extends StatefulWidget {
  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  late Future<List<Event>> futureEvents;
  late Map<DateTime, List<Event>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    futureEvents = fetchEvents();
    _events = {};
    futureEvents.then((events) {
      setState(() {
        for (var event in events) {
          final eventDate = DateTime(
              event.startAt.year, event.startAt.month, event.startAt.day);
          if (_events[eventDate] == null) {
            _events[eventDate] = [];
          }
          _events[eventDate]!.add(event);
        }
      });
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    final eventDay = DateTime(day.year, day.month, day.day);
    return _events[eventDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print(
        'Selected day: ${DateFormat('yyyy-MM-dd').format(selectedDay)}'); // Print the selected day
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _updateEvents() {
    futureEvents = fetchEvents();
    futureEvents.then((events) {
      setState(() {
        _events.clear();
        for (var event in events) {
          final eventDate = DateTime(
              event.startAt.year, event.startAt.month, event.startAt.day);
          if (_events[eventDate] == null) {
            _events[eventDate] = [];
          }
          _events[eventDate]!.add(event);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Schedule",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal, // Change this to your desired color
        elevation: 0.0, // Optional: remove shadow if not needed
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            focusedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            calendarBuilders: CalendarBuilders(
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
              todayBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return null;
              },
            ),
            eventLoader: (day) {
              return _getEventsForDay(day);
            },
          ),
          const SizedBox(height: 8.0),
          Text(
            DateFormat('EEE dd MMM').format(_focusedDay).toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
              child: _getEventsForDay(_selectedDay).isEmpty
                  ? Center(child: Image.asset('assets/events.png'))
                  : ListView.builder(
                      itemCount: _getEventsForDay(_selectedDay).length,
                      itemBuilder: (context, index) {
                        final event = _getEventsForDay(_selectedDay)[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          elevation:
                              8.0, // Increased elevation for a more prominent shadow
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12.0), // Rounded corners
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                            leading: Icon(
                              Icons.event,
                              color: event.status == 'Confirmed'
                                  ? Colors.green
                                  : Colors.red,
                              size:
                                  32.0, // Larger icon size for better visibility
                            ),
                            title: Text(
                              '${event.title[0].toUpperCase()}${event.title.substring(1)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0, // Increased font size for title
                              ),
                            ),
                            subtitle: Text(
                              DateFormat.yMMMd().add_jm().format(event.startAt),
                              style: TextStyle(
                                color: Colors
                                    .grey[600], // Lighter color for subtitle
                                fontSize: 16.0,
                              ),
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: event.status == 'Confirmed'
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                event.status,
                                style: TextStyle(
                                  color: event.status == 'Confirmed'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailScreen(
                                    event: event,
                                    onUpdate: _updateEvents,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )),
        ],
      ),
    );
  }
}

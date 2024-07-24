import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/event_model.dart';

Future<List<Event>> fetchEvents() async {
  final response = await http.get(
    Uri.parse('https://mock.apidog.com/m1/561191-524377-default/Event'),
    headers: {
      'Authorization': 'Bearer 2f68dbbf-519d-4f01-9636-e2421b68f379',
    },
  );

  if (response.statusCode == 200) {
    print('Response body: ${response.body}');
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Event.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load events');
  }
}

Future<void> deleteEvent(Event event) async {
  final response = await http.delete(
    Uri.parse(
        'https://mock.apidog.com/m1/561191-524377-default/Event/${event.title}'),
    headers: {
      'Authorization': 'Bearer 2f68dbbf-519d-4f01-9636-e2421b68f379',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete event');
  }
}

Future<void> updateEvent(Event event) async {
  final response = await http.put(
    Uri.parse(
        'https://mock.apidog.com/m1/561191-524377-default/Event/${event.title}'),
    headers: {
      'Authorization': 'Bearer 2f68dbbf-519d-4f01-9636-e2421b68f379',
      'Content-Type': 'application/json',
    },
    body: json.encode(event.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update event');
  }
}

import 'package:eventmanagement/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/event_model.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;
  final VoidCallback onUpdate;

  EventDetailScreen({required this.event, required this.onUpdate});

  Future<void> _deleteEvent(BuildContext context) async {
    try {
      await deleteEvent(event);
      onUpdate();
      Navigator.pop(context); // Close the detail screen after deletion
    } catch (e) {
      // Handle error
      print('Failed to delete event: $e');
    }
  }

  Future<void> _updateEvent(BuildContext context) async {
    // Show a dialog to edit the event details
    final updatedTitle = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController titleController =
            TextEditingController(text: event.title);
        return AlertDialog(
          title: Text('Edit Event'),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.pop(context, titleController.text);
              },
            ),
          ],
        );
      },
    );

    if (updatedTitle != null && updatedTitle.isNotEmpty) {
      try {
        final updatedEvent = Event(
          title: updatedTitle,
          startAt: event.startAt,
          status: event.status,
        );
        await updateEvent(updatedEvent);
        onUpdate();
        Navigator.pop(context); // Close the detail screen after update
      } catch (e) {
        // Handle error
        print('Failed to update event: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Start at: ${DateFormat.yMMMd().add_jm().format(event.startAt)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Status: ${event.status}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _updateEvent(context),
                  child: Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: () => _deleteEvent(context),
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

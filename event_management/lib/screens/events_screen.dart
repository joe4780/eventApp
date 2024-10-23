// events_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'event_details_screen.dart';

class Event {
  final String pic;
  final String title;
  final String text;
  final bool isRead;

  Event({
    required this.pic,
    required this.title,
    required this.text,
    required this.isRead,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      pic: json['pic'],
      title: json['title'],
      text: json['text'],
      isRead: json['isRead'],
    );
  }
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    final String response =
        await rootBundle.loadString('assets/events_data.json');
    final List<dynamic> data = jsonDecode(response);

    setState(() {
      _events = data.map((json) => Event.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'EVENTS LIST',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterButton('ALL'),
                _filterButton('UNREAD'),
                _filterButton('READ'),
              ],
            ),
            Expanded(
              child: _events.isNotEmpty
                  ? ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        return _EventListItem(event: _events[index]);
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String text) {
    return TextButton(
      onPressed: () {
        // Filter logic can be added later
      },
      child: Text(text),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final Event event;

  const _EventListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(event.pic),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(event.text),
                  const SizedBox(height: 8),
                  Text(event.isRead ? 'READ' : 'UNREAD'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

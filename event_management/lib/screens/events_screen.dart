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
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  String _currentFilter = 'ALL';

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
      _allEvents = data.map((json) => Event.fromJson(json)).toList();
      _applyFilter(_currentFilter);
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      switch (filter) {
        case 'READ':
          _filteredEvents = _allEvents.where((event) => event.isRead).toList();
          break;
        case 'UNREAD':
          _filteredEvents = _allEvents.where((event) => !event.isRead).toList();
          break;
        case 'ALL':
        default:
          _filteredEvents = List.from(_allEvents);
          break;
      }
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
              child: _allEvents.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        return _EventListItem(event: _filteredEvents[index]);
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
      onPressed: () => _applyFilter(text),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return _currentFilter == text
                ? Colors.blue.withOpacity(0.2)
                : Colors.transparent;
          },
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _currentFilter == text ? Colors.blue : Colors.black,
          fontWeight:
              _currentFilter == text ? FontWeight.bold : FontWeight.normal,
        ),
      ),
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

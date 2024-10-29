import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_details_screen.dart';

class Event {
  final String pic;
  final String title;
  final String text;
  bool isRead; // Changed to non-final to allow updates
  final String id; // Added to uniquely identify events

  Event({
    required this.pic,
    required this.title,
    required this.text,
    required this.isRead,
    required this.id,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      pic: json['pic'],
      title: json['title'],
      text: json['text'],
      isRead: json['isRead'],
      id: json['id'] ?? UniqueKey().toString(), // Generate ID if not provided
    );
  }

  Map<String, dynamic> toJson() => {
        'pic': pic,
        'title': title,
        'text': text,
        'isRead': isRead,
        'id': id,
      };
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
  final String _prefsKey = 'event_read_status';

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    // Load events data
    final String response =
        await rootBundle.loadString('assets/events_data.json');
    final List<dynamic> data = jsonDecode(response);
    _allEvents = data.map((json) => Event.fromJson(json)).toList();

    // Load saved read status
    final prefs = await SharedPreferences.getInstance();
    final savedStatuses = prefs.getStringList(_prefsKey) ?? [];

    // Apply saved read status to events
    for (var event in _allEvents) {
      if (savedStatuses.contains(event.id)) {
        event.isRead = true;
      }
    }

    setState(() {
      _applyFilter(_currentFilter);
    });
  }

  Future<void> _saveReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final readEventIds = _allEvents
        .where((event) => event.isRead)
        .map((event) => event.id)
        .toList();
    await prefs.setStringList(_prefsKey, readEventIds);
  }

  void _markAsRead(Event event) async {
    setState(() {
      event.isRead = true;
      _applyFilter(_currentFilter);
    });
    await _saveReadStatus();
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
                        return _EventListItem(
                          event: _filteredEvents[index],
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailsScreen(
                                    event: _filteredEvents[index]),
                              ),
                            );
                            _markAsRead(_filteredEvents[index]);
                          },
                        );
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
  final VoidCallback onTap;

  const _EventListItem({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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

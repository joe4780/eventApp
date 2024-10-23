import 'package:flutter/material.dart';
import 'screens/events_screen.dart';
import 'screens/tickets_screen.dart';
import 'screens/records_screen.dart';

void main() {
  runApp(const EventApp());
}

class EventApp extends StatelessWidget {
  const EventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const EventsScreen(),
    const TicketsScreen(),
    const RecordsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Text(
                'EVENTS',
                style: TextStyle(
                  color: _selectedIndex == 0 ? Colors.red : Colors.black,
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Text(
                'TICKETS',
                style: TextStyle(
                  color: _selectedIndex == 1 ? Colors.red : Colors.black,
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Text(
                'RECORDS',
                style: TextStyle(
                  color: _selectedIndex == 2 ? Colors.red : Colors.black,
                ),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}

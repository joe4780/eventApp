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
      debugShowCheckedModeBanner: false, // Optional: Removes the debug banner
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_selectedIndex].currentState!.maybePop();

        if (isFirstRouteInCurrentTab) {
          if (_selectedIndex != 0) {
            // Select 'Home' tab when back button is pressed
            setState(() {
              _selectedIndex = 0;
            });
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
          ],
        ),
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
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.black,
            items: const [
              BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: 'EVENTS',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: 'TICKETS',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: 'RECORDS',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[index],
        tabItem: _getTabItem(index),
      ),
    );
  }

  TabItem _getTabItem(int index) {
    switch (index) {
      case 0:
        return TabItem.events;
      case 1:
        return TabItem.tickets;
      case 2:
        return TabItem.records;
      default:
        return TabItem.events;
    }
  }
}

enum TabItem { events, tickets, records }

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  const TabNavigator({
    super.key,
    required this.navigatorKey,
    required this.tabItem,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    switch (tabItem) {
      case TabItem.events:
        return {
          TabNavigatorRoutes.root: (context) => const EventsScreen(),
        };
      case TabItem.tickets:
        return {
          TabNavigatorRoutes.root: (context) => const TicketsScreen(),
        };
      case TabItem.records:
        return {
          TabNavigatorRoutes.root: (context) => const RecordsScreen(),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        final routeBuilders = _routeBuilders(context);
        return MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name]!(context),
        );
      },
    );
  }
}

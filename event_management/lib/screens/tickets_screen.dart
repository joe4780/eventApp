import 'package:event_management/screens/create_ticket_screen.dart';
import 'package:flutter/material.dart';
import 'ticket_details_screen.dart';
import 'ticket_data.dart' as ticketData;

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  @override
  void initState() {
    super.initState();
    // Load ticket data from shared preferences
    ticketData.TicketData.loadData().then((_) {
      setState(() {}); // Refresh the UI after loading data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          // Center the entire content
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center content horizontally
              children: [
                const Text(
                  'TICKET LIST',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Push the CreateTicketScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateTicketScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[100],
                  ),
                  child: const Text(
                    'CREATE A NEW TICKET',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _buildTicketList(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketList(BuildContext context) {
    final openingCeremonyTickets = ticketData.TicketData.ticketList
        .where((ticket) => ticket['type'] == 'OPENING CEREMONY')
        .cast<Map<String, dynamic>>() // Cast to List<Map<String, dynamic>>
        .toList();
    final closingCeremonyTickets = ticketData.TicketData.ticketList
        .where((ticket) => ticket['type'] == 'CLOSING CEREMONY')
        .cast<Map<String, dynamic>>() // Cast to List<Map<String, dynamic>>
        .toList();

    return ListView(
      children: [
        _buildSection('OPENING CEREMONY', openingCeremonyTickets, context),
        _buildSection('CLOSING CEREMONY', closingCeremonyTickets, context),
      ],
    );
  }

  Widget _buildSection(
      String title, List<Map<String, dynamic>> tickets, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center title and tickets
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: tickets.map((ticket) {
            final key = ValueKey(ticket['name']);
            return Dismissible(
              key: key,
              direction: DismissDirection.horizontal,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ),
              onDismissed: (direction) {
                ticketData.TicketData.removeTicket(ticket['name']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${ticket['name']} deleted'),
                  ),
                );
                setState(() {}); // Refresh the UI
              },
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketDetailsScreen(
                        ticketData: {
                          'name': ticket['name'],
                          'seat': ticket['seat'],
                          'type': ticket['type'],
                          'time': ticket['time'],
                          'image': ticket['image'],
                        },
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 8.0), // Adjust horizontal margin
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ticket['seat'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex--;
            final ticket = tickets.removeAt(oldIndex);
            tickets.insert(newIndex, ticket);
            // Save the new order to shared preferences
            ticketData.TicketData.saveData();
          },
        ),
      ],
    );
  }
}

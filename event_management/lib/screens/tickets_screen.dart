import 'dart:convert';
import 'package:event_management/screens/create_ticket_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ticket_details_screen.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  Future<List<dynamic>> loadEventsData() async {
    // Load and decode JSON file
    final String jsonString =
        await rootBundle.loadString('assets/events_data.json');
    return json.decode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              // Display tickets for each category
              _buildTicketSection('OPENING CEREMONY TICKETS'),
              _buildTicketInfo(context, 'JACK', 'A1 ROW7 COLUMN10',
                  'Opening Ceremony', '10:00 AM'),
              const SizedBox(height: 16),
              _buildTicketInfo(context, 'ROSE', 'B7 ROW8 COLUMN3',
                  'Opening Ceremony', '11:00 AM'),
              const SizedBox(height: 24),

              _buildTicketSection('CLOSING CEREMONY TICKETS'),
              _buildTicketInfo(context, 'JACK', 'A5 ROW7 COLUMN3',
                  'Closing Ceremony', '5:00 PM'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Method to build ticket info and navigate to details screen
  Widget _buildTicketInfo(BuildContext context, String name, String seat,
      String type, String time) {
    return GestureDetector(
      onTap: () async {
        // Load event data from JSON
        final eventsData = await loadEventsData();

        // Find the event with a matching title for the type
        final event = eventsData.firstWhere((event) => event['title'] == type,
            orElse: () => null);

        // Use default image if event or image path not found
        String imagePath =
            event != null ? event['pic'] : 'assets/event_pic1.png';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailsScreen(
              ticketData: {
                'name': name,
                'seat': seat,
                'type': type,
                'time': time,
                'image': imagePath, // Pass dynamic image path
              },
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(seat),
        ],
      ),
    );
  }
}

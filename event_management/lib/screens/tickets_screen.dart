import 'package:event_management/screens/create_ticket_screen.dart';
import 'package:flutter/material.dart';
import 'ticket_details_screen.dart'; // Import for the ticket details screen

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

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

              // Tapping a ticket will navigate to the details screen
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

  // Widget for ticket section headers
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

  // Widget to build ticket info and add tap navigation
  Widget _buildTicketInfo(BuildContext context, String name, String seat,
      String type, String time) {
    return GestureDetector(
      onTap: () {
        // Navigate to the TicketDetailsScreen when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailsScreen(
              ticketData: {
                'name': name,
                'seat': seat,
                'type': type,
                'time': time,
                'image': 'event_pic1.png',
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

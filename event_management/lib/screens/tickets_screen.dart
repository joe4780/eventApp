import 'package:flutter/material.dart';
import 'create_ticket_screen.dart'; // Import for the new screen

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
              _buildTicketSection('OPENING CEREMONY TICKETS'),
              _buildTicketInfo('JACK', 'A1 ROW7 COLUMN10'),
              const SizedBox(height: 16),
              _buildTicketInfo('ROSE', 'B7 ROW8 COLUMN3'),
              const SizedBox(height: 24),
              _buildTicketSection('CLOSING CEREMONY TICKETS'),
              _buildTicketInfo('JACK', 'A5 ROW7 COLUMN3'),
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

  Widget _buildTicketInfo(String name, String location) {
    return Column(
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
        Text(location),
      ],
    );
  }
}

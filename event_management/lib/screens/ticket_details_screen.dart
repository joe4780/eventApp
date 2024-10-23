import 'package:flutter/material.dart';
import 'dart:io';

class TicketDetailsScreen extends StatelessWidget {
  final Map<String, String> ticketData;

  const TicketDetailsScreen({
    super.key,
    required this.ticketData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'TICKET DETAILS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Image preview
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: ticketData['image'] != null
                          ? Image.file(
                              File(ticketData['image']!),
                              fit: BoxFit.cover,
                            )
                          : const Center(child: Text('No Image Available')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TYPE: ${ticketData['type'] ?? 'N/A'}'),
                          const SizedBox(height: 8),
                          Text('NAME: ${ticketData['name'] ?? 'N/A'}'),
                          const SizedBox(height: 8),
                          Text('TIME: ${ticketData['time'] ?? 'N/A'}'),
                          const SizedBox(height: 8),
                          Text('SEAT: ${ticketData['seat'] ?? 'N/A'}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Button to download or save the ticket (implement functionality as needed)
              ElevatedButton(
                onPressed: () {
                  // Implement download functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[100],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'DOWNLOAD TICKET',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

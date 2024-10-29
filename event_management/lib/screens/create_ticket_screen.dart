import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'ticket_details_screen.dart';
import 'ticket_data.dart' as ticketData; // Import the global ticket data

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  String? selectedCeremony;
  String? selectedImageUrl;
  String? userName;
  final ceremonies = ['OPENING CEREMONY', 'CLOSING CEREMONY'];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        setState(() {
          selectedImageUrl = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Widget _buildImagePreview() {
    if (selectedImageUrl == null) {
      return const Center(child: Text('Preview Image'));
    } else {
      return Image.file(
        File(selectedImageUrl!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text('Error loading image'));
        },
      );
    }
  }

  void _createTicket() {
    if (selectedCeremony != null &&
        selectedImageUrl != null &&
        userName != null &&
        userName!.isNotEmpty) {
      final ticketDataMap = {
        'type': selectedCeremony!,
        'name': userName!,
        'time': DateTime.now().toString(),
        'seat': 'A5 ROW7 COLUMN3',
        'image': selectedImageUrl!,
      };

      // Add the ticket data to the global list
      ticketData.TicketData.ticketList.add(ticketDataMap);
      ticketData.TicketData
          .saveData(); // Save the updated list to shared preferences

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketDetailsScreen(ticketData: ticketDataMap),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
    }
  }

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
                'CREATE TICKET',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: DropdownButton<String>(
                  value: selectedCeremony,
                  isExpanded: true,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Select Ceremony'),
                  ),
                  underline: const SizedBox(),
                  items: ceremonies.map((String ceremony) {
                    return DropdownMenuItem<String>(
                      value: ceremony,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(ceremony),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCeremony = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    userName = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(12),
                ),
                child: const Text('Choose an Image'),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImagePreview(),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _createTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[100],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'CREATE TICKET',
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

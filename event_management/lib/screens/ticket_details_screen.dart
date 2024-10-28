import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart'; // Import for path_provider

class TicketDetailsScreen extends StatelessWidget {
  final Map<String, String> ticketData;

  // GlobalKey to capture the ticket details
  final GlobalKey globalKey = GlobalKey();

  TicketDetailsScreen({
    super.key,
    required this.ticketData,
  });

  Future<void> _downloadTicket(BuildContext context) async {
    if (globalKey.currentContext == null) {
      _showDialog(context, "Error: Unable to access the ticket details.");
      return;
    }

    try {
      // Capture the image from the RepaintBoundary
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get the temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/ticket.png';

      // Write the image bytes to a file
      File imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);

      // Save the image to the gallery
      final result = await GallerySaver.saveImage(filePath);
      if (result != null && result) {
        _showDialog(context, "Ticket saved successfully to gallery");
      } else {
        _showDialog(context, "Failed to save ticket to gallery");
      }
    } catch (e) {
      _showDialog(context, "An error occurred: $e");
    }
  }

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notification'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
                'TICKET DETAILS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Image preview
              RepaintBoundary(
                key: globalKey, // Use the class member key here
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Set a background color
                    border: Border.all(color: Colors.black),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: ticketData['image'] != null &&
                                ticketData['image']!.isNotEmpty
                            ? (ticketData['image']!.startsWith('assets/')
                                ? Image.asset(
                                    ticketData['image']!, // Load from assets
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(ticketData[
                                        'image']!), // Load from device file
                                    fit: BoxFit.cover,
                                  ))
                            : const Center(child: Text('No Image Available')),
                      ),
                      const SizedBox(height: 16),
                      // Ensure all ticket details are included
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
              ),
              const SizedBox(height: 32),

              // Button to download or save the ticket
              ElevatedButton(
                onPressed: () => _downloadTicket(context),
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

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketData {
  static List<dynamic> ticketList = [];

  // Save data to shared preferences
  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('ticketList', json.encode(ticketList));
  }

  // Load data from shared preferences
  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('ticketList');
    if (data != null) {
      ticketList = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Remove ticket by name
  static void removeTicket(String name) {
    ticketList.removeWhere((ticket) => ticket['name'] == name);
    saveData(); // Save the updated list
  }
}

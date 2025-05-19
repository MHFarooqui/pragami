// FILE: lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pragami/Screens/CreateBooking.dart';

void main() => runApp(BookingApp());

class BookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Booking',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BookingListPage(),
    );
  }
}

class BookingListPage extends StatefulWidget {
  @override
  _BookingListPageState createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  List bookings = [];

  Future<void> fetchBookings() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.20:3000/bookings'));
      if (response.statusCode == 200) {
        setState(() {
          bookings = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching bookings: $e');
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.20:3000/bookings/$bookingId'),
      );
      if (response.statusCode == 200) {
        print('Booking deleted');
        fetchBookings(); // Refresh list
      } else {
        print('Failed to delete booking: ${response.body}');
      }
    } catch (e) {
      print('Error deleting booking: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookings List')),
      body: bookings.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.indigo),
                  title: Text('User: ${booking['userId']}'),
                  subtitle:
                      Text('${booking['startTime']} to ${booking['endTime']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, booking['id']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CreateBookingPage()),
        ).then((_) => fetchBookings()),
        child: Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Booking'),
        content: Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              deleteBooking(bookingId);
            },
          ),
        ],
      ),
    );
  }
}

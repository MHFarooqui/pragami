import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateBookingPage extends StatefulWidget {
  @override
  _CreateBookingPageState createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  String _response = '';

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      setState(() => _response = 'Please select both start and end date/time.');
      return;
    }

    final start = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final end = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.20:3000/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userIdController.text,
          'startTime': start.toUtc().toIso8601String(),
          'endTime': end.toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        setState(() => _response = '');
        _showSuccessDialog();
        _resetForm();
      } else if (response.statusCode == 403) {
        setState(() => _response = 'Booking conflict detected');
      } else {
        setState(() => _response = 'Failed to create booking');
      }
    } catch (e) {
      setState(() => _response = 'Error: $e');
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          if (isStart) {
            _startDate = pickedDate;
            _startTime = pickedTime;
          } else {
            _endDate = pickedDate;
            _endTime = pickedTime;
          }
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Success'),
        content: Text('Booking created successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _userIdController.clear();
    setState(() {
      _startDate = null;
      _startTime = null;
      _endDate = null;
      _endTime = null;
    });
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return 'Not set';
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final timeStr = time.format(context);
    return "$dateStr $timeStr";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Booking')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _userIdController,
                decoration: InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'User ID is required' : null,
              ),
              SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Start Time: ${_formatDateTime(_startDate, _startTime)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDateTime(isStart: true),
              ),
              Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('End Time: ${_formatDateTime(_endDate, _endTime)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDateTime(isStart: false),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.send),
                label: Text('Create Booking'),
                onPressed: _createBooking,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
              if (_response.isNotEmpty) ...[
                SizedBox(height: 20),
                Text(
                  _response,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

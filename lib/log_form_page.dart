import 'package:flutter/material.dart';

class LogFormPage extends StatefulWidget {
  final Map<String, dynamic>? log; // Optional: for editing existing logs
  final bool isViewOnly; // New parameter

  const LogFormPage({super.key, this.log, this.isViewOnly = false}); // Default to false

  @override
  State<LogFormPage> createState() => _LogFormPageState();
}

class _LogFormPageState extends State<LogFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _atmIdController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _technicianController;
  late String _selectedStatus;
  late String _selectedType;

  final List<String> _statuses = ['Completed', 'In Progress'];
  final List<String> _types = ['Routine Check', 'Cash Replenishment', 'Hardware Repair', 'Software Update'];

  @override
  void initState() {
    super.initState();
    _atmIdController = TextEditingController(text: widget.log?['atmId'] ?? '');
    _locationController = TextEditingController(text: widget.log?['location'] ?? '');
    _dateController = TextEditingController(text: widget.log?['date'] ?? '');
    _timeController = TextEditingController(text: widget.log?['time'] ?? '');
    _technicianController = TextEditingController(text: widget.log?['technician'] ?? '');
    _selectedStatus = widget.log?['status'] ?? _statuses.first;
    _selectedType = widget.log?['type'] ?? _types.first;
  }

  @override
  void dispose() {
    _atmIdController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _technicianController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newLog = {
        'atmId': _atmIdController.text,
        'location': _locationController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'technician': _technicianController.text,
        'status': _selectedStatus,
        'type': _selectedType,
      };
      Navigator.pop(context, newLog); // Pass the new/edited log back
    }
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T').first; // Format as YYYY-MM-DD
      });
    }
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    if (timeString.isEmpty) {
      return TimeOfDay.now();
    }
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return TimeOfDay.now();
  }

  void _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTimeOfDay(_timeController.text),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context); // Format as HH:MM
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        backgroundColor: Colors.white, // Consistent with logs_page.dart
        elevation: 0, // Consistent with logs_page.dart
        iconTheme: const IconThemeData(color: Colors.black87), // Consistent with logs_page.dart
        title: Text(
          widget.isViewOnly
              ? 'Log Details'
              : (widget.log == null ? 'Create Log' : 'Edit Log'),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: widget.isViewOnly
            ? [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black87),
                  onPressed: () async {
                    Navigator.pop(context); // Dismiss current view-only form
                    final updatedLog = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogFormPage(log: widget.log), // Navigate to edit mode
                      ),
                    );
                    if (updatedLog != null) {
                      Navigator.pop(context, updatedLog); // Pass updated log back to previous screen
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Implement delete confirmation and action here
                    // For now, just pop with a signal to delete
                    Navigator.pop(context, {'action': 'delete'});
                  },
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField(
                controller: _atmIdController,
                labelText: 'ATM ID',
                validatorMessage: 'Please enter an ATM ID',
                readOnly: widget.isViewOnly,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _locationController,
                labelText: 'Location',
                validatorMessage: 'Please enter a location',
                readOnly: widget.isViewOnly,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _dateController,
                labelText: 'Date (YYYY-MM-DD)',
                validatorMessage: 'Please enter a date',
                onTap: widget.isViewOnly ? null : _selectDate,
                readOnly: widget.isViewOnly,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _timeController,
                labelText: 'Time (HH:MM)',
                validatorMessage: 'Please enter a time',
                onTap: widget.isViewOnly ? null : _selectTime,
                readOnly: widget.isViewOnly,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _technicianController,
                labelText: 'Technician',
                validatorMessage: 'Please enter a technician name',
                readOnly: widget.isViewOnly,
              ),
              const SizedBox(height: 16),
              _buildDropdownFormField(
                value: _selectedStatus,
                labelText: 'Status',
                items: _statuses,
                onChanged: widget.isViewOnly ? null : (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
                readOnly: widget.isViewOnly,
              ),
              const SizedBox(height: 16),
              _buildDropdownFormField(
                value: _selectedType,
                labelText: 'Type',
                items: _types,
                onChanged: widget.isViewOnly ? null : (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
                readOnly: widget.isViewOnly,
              ),
              if (!widget.isViewOnly) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Log',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String validatorMessage,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Increased height
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        return null;
      },
      onTap: onTap,
      readOnly: readOnly,
    );
  }

  Widget _buildDropdownFormField({
    required String value,
    required String labelText,
    required List<String> items,
    ValueChanged<String?>? onChanged, // Made nullable
    bool readOnly = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Increased height
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: readOnly ? null : onChanged,
    );
  }
}

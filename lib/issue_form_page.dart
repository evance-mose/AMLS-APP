import 'package:flutter/material.dart';

class IssueFormPage extends StatefulWidget {
  final Map<String, dynamic>? issue; // Optional: for editing existing issues
  final bool isViewOnly; // New parameter

  const IssueFormPage({super.key, this.issue, this.isViewOnly = false});

  @override
  State<IssueFormPage> createState() => _IssueFormPageState();
}

class _IssueFormPageState extends State<IssueFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _atmIdController;
  late TextEditingController _locationController;
  late TextEditingController _issueController;
  late String _selectedPriority;
  late TextEditingController _reportedDateController;
  late String _selectedStatus;

  final List<String> _priorities = ['Critical', 'High', 'Medium', 'Low'];
  final List<String> _statuses = ['Open', 'Assigned', 'Resolved'];

  @override
  void initState() {
    super.initState();
    _atmIdController = TextEditingController(text: widget.issue?['atmId'] ?? '');
    _locationController = TextEditingController(text: widget.issue?['location'] ?? '');
    _issueController = TextEditingController(text: widget.issue?['issue'] ?? '');
    _selectedPriority = widget.issue?['priority'] ?? _priorities.first;
    _reportedDateController = TextEditingController(text: widget.issue?['reportedDate'] ?? '');
    _selectedStatus = widget.issue?['status'] ?? _statuses.first;
  }

  @override
  void dispose() {
    _atmIdController.dispose();
    _locationController.dispose();
    _issueController.dispose();
    _reportedDateController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_reportedDateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _reportedDateController.text = picked.toIso8601String().split('T').first; // Format as YYYY-MM-DD
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newIssue = {
        'atmId': _atmIdController.text,
        'location': _locationController.text,
        'issue': _issueController.text,
        'priority': _selectedPriority,
        'reportedDate': _reportedDateController.text,
        'status': _selectedStatus,
      };
      Navigator.pop(context, newIssue); // Pass the new/edited issue back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.isViewOnly
              ? 'Issue Details'
              : (widget.issue == null ? 'Create Issue' : 'Edit Issue'),
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
                    final updatedIssue = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IssueFormPage(issue: widget.issue), // Navigate to edit mode
                      ),
                    );
                    if (updatedIssue != null) {
                      Navigator.pop(context, updatedIssue); // Pass updated issue back to previous screen
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Navigator.pop(context, {'action': 'delete'}); // Signal to delete
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
                controller: _issueController,
                labelText: 'Issue Description',
                validatorMessage: 'Please enter an issue description',
                readOnly: widget.isViewOnly,
              ),
              const SizedBox(height: 16),
              _buildDropdownFormField(
                value: _selectedPriority,
                labelText: 'Priority',
                items: _priorities,
                onChanged: widget.isViewOnly ? null : (String? newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
                readOnly: widget.isViewOnly,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _reportedDateController,
                labelText: 'Reported Date (YYYY-MM-DD)',
                validatorMessage: 'Please enter a reported date',
                onTap: widget.isViewOnly ? null : _selectDate,
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
                      'Save Issue',
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
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
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
    );
  }

  Widget _buildDropdownFormField({
    required String value,
    required String labelText,
    required List<String> items,
    ValueChanged<String?>? onChanged,
    bool readOnly = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
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

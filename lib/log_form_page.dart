import 'package:flutter/material.dart';
import 'package:amls/models/log_model.dart'; // Import the Log model

extension StringExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}

class LogFormPage extends StatefulWidget {
  final Log? log; // Change type to Log
  final bool isViewOnly;

  const LogFormPage({super.key, this.log, this.isViewOnly = false});

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
  late TextEditingController _actionTakenController;
  late String _selectedStatus;
  late String _selectedCategory;
  late String _selectedPriority; // New field for priority

  final List<String> _statuses = LogStatus.values.map((e) => e.toString().split('.').last.replaceAll('_', ' ').toCapitalized()).toList();
  final List<String> _priorities = LogPriority.values.map((e) => e.toString().split('.').last.toCapitalized()).toList();
  final List<String> _categories = LogCategory.values.map((e) => e.toString().split('.').last.replaceAll('_', ' ').toCapitalized()).toList();

  @override
  void initState() {
    super.initState();
    _atmIdController = TextEditingController(text: widget.log?.issue?.atmId ?? '');
    _locationController = TextEditingController(text: widget.log?.issue?.location ?? '');
    _dateController = TextEditingController(text: widget.log?.createdAt.toIso8601String().split('T').first ?? '');
    _timeController = TextEditingController(text: '${widget.log?.createdAt.hour.toString().padLeft(2, '0')}:${widget.log?.createdAt.minute.toString().padLeft(2, '0')}' ?? '');
    _technicianController = TextEditingController(text: widget.log?.user?.name ?? ''); // Use user name
    _actionTakenController = TextEditingController(text: widget.log?.actionTaken ?? ''); // Use text controller for actionTaken
    _selectedStatus = widget.log?.status.toString().split('.').last.replaceAll('_', ' ').toCapitalized() ?? _statuses.first;
    _selectedCategory = widget.log?.category.toString().split('.').last.replaceAll('_', ' ').toCapitalized() ?? _categories.first;
    _selectedPriority = widget.log?.priority.toString().split('.').last.toCapitalized() ?? _priorities.first;
  }

  @override
  void dispose() {
    _atmIdController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _technicianController.dispose();
    _actionTakenController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Parse the date and time from form fields
      final dateTime = _parseDateTimeFromForm();
      
      final newLog = Log(
        id: widget.log?.id ?? 0, // ID generation is handled by Cubit
        userId: widget.log?.userId ?? 1, // Use existing userId or default
        issueId: widget.log?.issueId,
        actionTaken: _actionTakenController.text.isEmpty ? null : _actionTakenController.text, // Use text controller
        category: LogCategory.values.firstWhere((e) => e.toString().split('.').last.replaceAll('_', ' ').toCapitalized() == _selectedCategory),
        status: LogStatus.values.firstWhere((e) => e.toString().split('.').last.replaceAll('_', ' ').toCapitalized() == _selectedStatus),
        priority: LogPriority.values.firstWhere((e) => e.toString().split('.').last.toCapitalized() == _selectedPriority),
        createdAt: dateTime,
        updatedAt: DateTime.now(),
        user: widget.log?.user,
        issue: widget.log?.issue,
      );
      if (mounted) Navigator.pop(context, newLog);
    }
  }

  DateTime _parseDateTimeFromForm() {
    try {
      final dateStr = _dateController.text;
      final timeStr = _timeController.text;
      
      if (dateStr.isNotEmpty && timeStr.isNotEmpty) {
        final date = DateTime.parse(dateStr);
        final timeParts = timeStr.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        
        return DateTime(date.year, date.month, date.day, hour, minute);
      } else if (dateStr.isNotEmpty) {
        return DateTime.parse(dateStr);
      } else {
        return widget.log?.createdAt ?? DateTime.now();
      }
    } catch (e) {
      print('Error parsing date/time: $e');
      return widget.log?.createdAt ?? DateTime.now();
    }
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T').first;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _confirmDelete() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_outline, color: colorScheme.error, size: 28),
          ),
          title: Text(
            'Delete Log',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this maintenance log? This action cannot be undone.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Cancel',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (mounted) Navigator.pop(context, {'action': 'delete'});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: 20),
          ),
          onPressed: () {
            if (mounted) Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isViewOnly
                  ? 'Log Details'
                  : (widget.log == null ? 'Create Log' : 'Edit Log'),
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: widget.isViewOnly
            ? [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
                  ),
                  onPressed: () async {
                    if (mounted) Navigator.pop(context);
                    final updatedLog = await Navigator.push<Log?>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogFormPage(log: widget.log),
                      ),
                    );
                    if (updatedLog != null && mounted) {
                      Navigator.pop(context, updatedLog);
                    }
                  },
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                  ),
                  onPressed: _confirmDelete,
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _atmIdController,
                      labelText: 'ATM ID',
                      hintText: 'e.g., ATM-001',
                      icon: Icons.tag,
                      validatorMessage: 'Please enter an ATM ID',
                      readOnly: widget.isViewOnly,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _locationController,
                      labelText: 'Location',
                      hintText: 'e.g., City Mall, Ground Floor',
                      icon: Icons.location_on_outlined,
                      validatorMessage: 'Please enter a location',
                      readOnly: widget.isViewOnly,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    _buildTextFormField(
                      controller: _dateController,
                      labelText: 'Date',
                      hintText: 'YYYY-MM-DD',
                      icon: Icons.calendar_today_outlined,
                      validatorMessage: 'Please enter a date',
                      onTap: widget.isViewOnly ? null : _selectDate,
                      readOnly: true,
                    ),
                    const SizedBox(width: 12),
                    _buildTextFormField(
                      controller: _timeController,
                      labelText: 'Time',
                      hintText: 'HH:MM',
                      icon: Icons.access_time_outlined,
                      validatorMessage: 'Please enter a time',
                      onTap: widget.isViewOnly ? null : _selectTime,
                      readOnly: true,
                    ),
                    
                    const SizedBox(height: 32),
                
                    _buildTextFormField(
                      controller: _technicianController,
                      labelText: 'Technician',
                      hintText: 'e.g., John Smith',
                      icon: Icons.person_outline,
                      validatorMessage: 'Please enter a technician name',
                      readOnly: widget.isViewOnly,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _actionTakenController,
                      labelText: 'Action Taken',
                      hintText: 'e.g., Replaced card reader, Updated software',
                      icon: Icons.construction_outlined,
                      validatorMessage: 'Please enter the action taken',
                      readOnly: widget.isViewOnly,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownFormField(
                      value: _selectedCategory,
                      labelText: 'Category',
                      icon: Icons.category_outlined,
                      items: _categories,
                      onChanged: widget.isViewOnly
                          ? null
                          : (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                      readOnly: widget.isViewOnly,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownFormField(
                      value: _selectedStatus,
                      labelText: 'Status',
                      icon: Icons.flag_outlined,
                      items: _statuses,
                      onChanged: widget.isViewOnly
                          ? null
                          : (String? newValue) {
                              setState(() {
                                _selectedStatus = newValue!;
                              });
                            },
                      readOnly: widget.isViewOnly,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownFormField(
                      value: _selectedPriority,
                      labelText: 'Priority',
                      icon: Icons.priority_high,
                      items: _priorities,
                      onChanged: widget.isViewOnly
                          ? null
                          : (String? newValue) {
                              setState(() {
                                _selectedPriority = newValue!;
                              });
                            },
                      readOnly: widget.isViewOnly,
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Save Button (only shown when not view-only)
            if (!widget.isViewOnly)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.log == null ? Icons.add_circle_outline : Icons.save_outlined,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.log == null ? 'Create Log' : 'Save Changes',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String validatorMessage,
    required IconData icon,
    String? hintText,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: readOnly ? colorScheme.surfaceVariant.withOpacity(0.3) : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: readOnly
            ? []
            : [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: Colors.black,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.error, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorMessage;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required String labelText,
    required List<String> items,
    required IconData icon,
    ValueChanged<String?>? onChanged,
    bool readOnly = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: readOnly ? colorScheme.surfaceVariant.withOpacity(0.3) : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: readOnly
            ? []
            : [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
        items: [
          // Add placeholder item for null values
          if (value == null)
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Select ${labelText.toLowerCase()}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ...items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            );
          }),
        ],
        onChanged: readOnly ? null : onChanged,
        dropdownColor: colorScheme.surface,
        icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
      ),
    );
  }

}
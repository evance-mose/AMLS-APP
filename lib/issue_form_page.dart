import 'package:flutter/material.dart';
import 'package:amls/models/issue_model.dart'; // Import the Issue model
import 'package:amls/models/user_model.dart';
import 'package:amls/services/api_service.dart';
import 'package:amls/services/auth_service.dart';

extension StringExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}

class IssueFormPage extends StatefulWidget {
  final Issue? issue; // Change type to Issue
  final bool isViewOnly;

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
  late String _selectedCategory;
  late int? _selectedAssignedUserId;
  List<User> _availableUsers = [];
  bool _isLoadingUsers = true;
  bool _canAssignIssue = false;

  final List<String> _priorities = IssuePriority.values.map((e) => e.toString().split('.').last.toCapitalized()).toList();
  final List<String> _statuses = IssueStatus.values.map((e) => e.toString().split('.').last.toCapitalized()).toList();
  final List<String> _categories = IssueCategory.values.map((e) => e.toString().split('.').last.replaceAll('_', ' ').toCapitalized()).toList();

  @override
  void initState() {
    super.initState();
    _atmIdController = TextEditingController(text: widget.issue?.atmId ?? '');
    _locationController = TextEditingController(text: widget.issue?.location ?? '');
    _issueController = TextEditingController(text: widget.issue?.description ?? ''); // Use description as issue
    _selectedPriority = widget.issue?.priority.toString().split('.').last.toCapitalized() ?? _priorities.first;
    _reportedDateController = TextEditingController(text: widget.issue?.reportedDate.toIso8601String().split('T').first ?? '');
    _selectedStatus = widget.issue?.status.toString().split('.').last.toCapitalized() ?? _statuses.first;
    _selectedCategory = widget.issue?.category.toString().split('.').last.replaceAll('_', ' ').toCapitalized() ?? _categories.first;
    _selectedAssignedUserId = widget.issue?.assignedTo; // Initialize selected user ID
    
    _fetchUsers();
    _loadCurrentUserPermissions();
  }

  void _loadCurrentUserPermissions() async {
    try {
      final user = await AuthService.getUser();
      if (mounted) {
        setState(() {
          _canAssignIssue = user?.role == UserRole.admin;
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
      if (mounted) {
        setState(() {
          _canAssignIssue = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _atmIdController.dispose();
    _locationController.dispose();
    _issueController.dispose();
    _reportedDateController.dispose();
    super.dispose();
  }

  void _fetchUsers() async {
    try {
      final users = await ApiService.fetchUsers();
      // Filter users to only show admin and technician roles
      final filteredUsers = users.where((user) => 
        user.role == UserRole.admin || user.role == UserRole.technician
      ).toList();
      
      if (mounted) {
        setState(() {
          _availableUsers = filteredUsers;
          _isLoadingUsers = false;
          
          // If we have an assigned user from the issue but they're not in the filtered list,
          // add them to the list so the dropdown can display them
          if (widget.issue?.assignedUser != null && 
              !filteredUsers.any((user) => user.id == widget.issue!.assignedUser!.id)) {
            _availableUsers = [...filteredUsers, widget.issue!.assignedUser!];
          }
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load users: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_reportedDateController.text) ?? DateTime.now(),
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
    if (picked != null && mounted) {
      setState(() {
        _reportedDateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newIssue = _buildIssueFromState();
      print('Issue to be saved - assignedTo: ${newIssue.assignedTo}, userId: ${newIssue.userId}');
      
      // Check if the widget is still mounted before popping
      if (mounted) {
        Navigator.of(context).pop(newIssue);
      }
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
            'Delete Issue',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this issue? This action cannot be undone.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
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
                if (mounted) {
                  Navigator.of(context).pop({'action': 'delete'});
                }
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

  void _showAssignIssueSheet() {
    if (!_canAssignIssue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You do not have permission to assign issues.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_isLoadingUsers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please wait while users are loading...'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }

    int? tempSelectedUserId = _selectedAssignedUserId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final padding = MediaQuery.of(sheetContext).viewInsets.bottom;
        final colorScheme = Theme.of(sheetContext).colorScheme;
        final textTheme = Theme.of(sheetContext).textTheme;

        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: padding + 20),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assign Issue',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a technician or admin to assign this issue to.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildUserDropdownFormField(
                    value: tempSelectedUserId,
                    labelText: 'Assigned To',
                    icon: Icons.person_outline,
                    users: _availableUsers,
                    isLoading: false,
                    onChanged: (int? newValue) {
                      setModalState(() {
                        tempSelectedUserId = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              _selectedAssignedUserId = tempSelectedUserId;
                            });
                          }
                          Navigator.of(sheetContext).pop();
                          if (mounted && widget.isViewOnly) {
                            final updatedIssue = _buildIssueFromState();
                            Navigator.of(context).pop(updatedIssue);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
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
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
       
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
         
          children: [
            Text(
              widget.isViewOnly
                  ? 'Issue Details'
                  : (widget.issue == null ? 'Create Issue' : 'Edit Issue'),
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: widget.isViewOnly
            ? [
                if (widget.issue != null && _canAssignIssue)
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.assignment_ind_outlined, color: colorScheme.primary, size: 20),
                    ),
                    onPressed: _showAssignIssueSheet,
                    tooltip: 'Assign Issue',
                  ),
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
                    final updatedIssue = await Navigator.of(context).push<Issue?>(
                      MaterialPageRoute(
                        builder: (context) => IssueFormPage(issue: widget.issue, isViewOnly: false),
                      ),
                    );
                    if (updatedIssue != null && mounted) {
                      Navigator.of(context).pop(updatedIssue);
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
            : [],
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
                    _buildTextFormField(
                      controller: _issueController,
                      labelText: 'Issue Description',
                      hintText: 'e.g., Card reader not working',
                      icon: Icons.bug_report_outlined,
                      validatorMessage: 'Please enter an issue description',
                      readOnly: widget.isViewOnly,
                    ),
                    const SizedBox(height: 32),
                    
                    _buildTextFormField(
                      controller: _reportedDateController,
                      labelText: 'Reported Date',
                      hintText: 'YYYY-MM-DD',
                      icon: Icons.calendar_today_outlined,
                      validatorMessage: 'Please enter a reported date',
                      onTap: widget.isViewOnly ? null : _selectDate,
                      readOnly: true,
                    ),
                    
                    const SizedBox(height: 32),
                    
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
                            widget.issue == null ? Icons.add_circle_outline : Icons.save_outlined,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.issue == null ? 'Create Issue' : 'Save Changes',
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
    required String value,
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
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
        onChanged: readOnly ? null : onChanged,
        dropdownColor: colorScheme.surface,
        icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildUserDropdownFormField({
    required int? value,
    required String labelText,
    required List<User> users,
    required bool isLoading,
    required IconData icon,
    ValueChanged<int?>? onChanged,
    bool readOnly = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Create a list of all possible values to check if the current value is valid
    final validValues = <int?>[null, ...users.map((user) => user.id)];
    
    // Preserve the value even if users haven't loaded yet (for edit mode)
    // Only set to null if users have loaded and the value is not in the list
    final currentValue = (isLoading && value != null) 
        ? value  // Keep the value while loading
        : (validValues.contains(value) ? value : null);

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
      child: DropdownButtonFormField<int>(
        value: currentValue,
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
          // Add "None" option
          DropdownMenuItem<int>(
            value: null,
            child: Text(
              'None',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          // Add user options - ensure no duplicate IDs
          ...users.map((User user) {
            return DropdownMenuItem<int>(
              value: user.id,
              child: Text(
                '${user.name} (${user.role.toString().split('.').last.toCapitalized()})',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        ],
        onChanged: readOnly ? null : onChanged,
        dropdownColor: colorScheme.surface,
        icon: isLoading 
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            )
          : Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  Issue _buildIssueFromState() {
    // Find the assigned user safely
    User? assignedUser;
    if (_selectedAssignedUserId != null && _availableUsers.isNotEmpty) {
      try {
        assignedUser = _availableUsers.firstWhere(
          (user) => user.id == _selectedAssignedUserId,
        );
      } catch (e) {
        print('Warning: Assigned user not found in available users: $e');
        assignedUser = null;
      }
    }

    // Debug logging
    print('Building issue with assignedTo: $_selectedAssignedUserId');
    print('Available users: ${_availableUsers.map((u) => '${u.id}: ${u.name}').join(', ')}');
    if (assignedUser != null) {
      print('Assigned user found: ${assignedUser.name} (ID: ${assignedUser.id})');
    }

    return Issue(
      id: widget.issue?.id ?? 0,
      atmId: _atmIdController.text,
      location: _locationController.text,
      category: IssueCategory.values.firstWhere((e) => e.toString().split('.').last.replaceAll('_', ' ').toCapitalized() == _selectedCategory),
      description: _issueController.text,
      priority: IssuePriority.values.firstWhere((e) => e.toString().split('.').last.toCapitalized() == _selectedPriority),
      reportedDate: DateTime.tryParse(_reportedDateController.text) ?? DateTime.now(),
      status: IssueStatus.values.firstWhere((e) => e.toString().split('.').last.toCapitalized() == _selectedStatus),
      assignedTo: _selectedAssignedUserId,
      createdAt: widget.issue?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      userId: widget.issue?.userId,
      user: widget.issue?.user,
      assignedUser: assignedUser,
    );
  }
}
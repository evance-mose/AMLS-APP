import 'package:flutter/material.dart';
import 'package:amls/models/user_model.dart';
import 'package:amls/services/api_service.dart';

String _toCapitalized(String str) => str.length > 0 ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '';

class UserFormPage extends StatefulWidget {
  final User? user;
  final bool isViewOnly;

  const UserFormPage({super.key, this.user, this.isViewOnly = false});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late String _selectedRole;
  late String _selectedStatus;

  final List<String> _roles = UserRole.values.map((e) => _toCapitalized(e.toString().split('.').last)).toList();
  final List<String> _statuses = UserStatus.values.map((e) => _toCapitalized(e.toString().split('.').last)).toList();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController(text: '');
    _selectedRole = widget.user != null ? _toCapitalized(widget.user!.role.toString().split('.').last) : _roles.first;
    _selectedStatus = widget.user != null ? _toCapitalized(widget.user!.status.toString().split('.').last) : _statuses.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newUser = User(
        id: widget.user?.id ?? 0,
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text.isEmpty ? (widget.user?.password ?? '') : _passwordController.text,
        role: UserRole.values.firstWhere((e) => _toCapitalized(e.toString().split('.').last) == _selectedRole),
        status: UserStatus.values.firstWhere((e) => _toCapitalized(e.toString().split('.').last) == _selectedStatus),
        createdAt: widget.user?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        emailVerifiedAt: widget.user?.emailVerifiedAt,
        rememberToken: widget.user?.rememberToken,
      );
      
      if (mounted) {
        Navigator.of(context).pop(newUser);
      }
    }
  }

  void _confirmDelete() {
    if (widget.user == null) return;
    
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
            'Delete User',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${widget.user!.name}? This action cannot be undone.',
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
                  Navigator.of(context).pop({'action': 'delete', 'user': widget.user});
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
                  ? 'User Details'
                  : (widget.user == null ? 'Create User' : 'Edit User'),
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
                    // Navigate to edit mode
                    final updatedUser = await Navigator.of(context).push<User?>(
                      MaterialPageRoute(
                        builder: (context) => UserFormPage(user: widget.user, isViewOnly: false),
                      ),
                    );
                    
                    // If we got an updated user, pop this view page and return the updated user
                    if (updatedUser != null && mounted) {
                      Navigator.of(context).pop(updatedUser);
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
                      controller: _nameController,
                      labelText: 'Name',
                      hintText: 'e.g., John Doe',
                      icon: Icons.person_outline,
                      validatorMessage: 'Please enter a name',
                      readOnly: widget.isViewOnly,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'e.g., john.doe@example.com',
                      icon: Icons.email_outlined,
                      validatorMessage: 'Please enter an email',
                      keyboardType: TextInputType.emailAddress,
                      readOnly: widget.isViewOnly,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _passwordController,
                      labelText: widget.user == null ? 'Password' : 'New Password (leave empty to keep current)',
                      hintText: 'Enter password',
                      icon: Icons.lock_outline,
                      validatorMessage: widget.user == null ? 'Please enter a password' : null,
                      obscureText: true,
                      readOnly: widget.isViewOnly,
                    ),
                    const SizedBox(height: 32),
                    _buildDropdownFormField(
                      value: _selectedRole,
                      labelText: 'Role',
                      icon: Icons.badge_outlined,
                      items: _roles,
                      onChanged: widget.isViewOnly
                          ? null
                          : (String? newValue) {
                              setState(() {
                                _selectedRole = newValue!;
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
                            widget.user == null ? Icons.add_circle_outline : Icons.save_outlined,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.user == null ? 'Create User' : 'Save Changes',
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
    required String? validatorMessage,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
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
        obscureText: obscureText,
        keyboardType: keyboardType,
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
        validator: validatorMessage != null ? (value) {
          if (value == null || value.isEmpty) {
            return validatorMessage;
          }
          if (keyboardType == TextInputType.emailAddress && !value.contains('@')) {
            return 'Please enter a valid email address';
          }
          return null;
        } : null,
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
}


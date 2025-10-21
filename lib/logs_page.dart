import 'package:flutter/material.dart';
import 'package:amls/log_form_page.dart';

class MaintenanceLogsScreen extends StatefulWidget {
  const MaintenanceLogsScreen({super.key});

  @override
  State<MaintenanceLogsScreen> createState() => _MaintenanceLogsScreenState();
}

class _MaintenanceLogsScreenState extends State<MaintenanceLogsScreen> {
  // Sample data - replace with actual data from your backend
  final List<Map<String, dynamic>> maintenanceLogs = [
    {
      'atmId': 'ATM-001',
      'location': 'Main Branch - Downtown',
      'date': '2024-10-20',
      'time': '14:30',
      'technician': 'Mike Johnson',
      'status': 'Completed',
      'type': 'Routine Check',
    },
    {
      'atmId': 'ATM-005',
      'location': 'Shopping Mall - East',
      'date': '2024-10-20',
      'time': '11:15',
      'technician': 'Sarah Williams',
      'status': 'In Progress',
      'type': 'Cash Replenishment',
    },
    {
      'atmId': 'ATM-012',
      'location': 'Airport Terminal 2',
      'date': '2024-10-19',
      'time': '09:00',
      'technician': 'David Brown',
      'status': 'Completed',
      'type': 'Hardware Repair',
    },
    {
      'atmId': 'ATM-008',
      'location': 'Central Market',
      'date': '2024-10-18',
      'time': '16:45',
      'technician': 'Mike Johnson',
      'status': 'Completed',
      'type': 'Software Update',
    },
    {
      'atmId': 'ATM-015',
      'location': 'Train Station',
      'date': '2024-10-18',
      'time': '10:20',
      'technician': 'Sarah Williams',
      'status': 'Completed',
      'type': 'Routine Check',
    },
  ];

  String selectedFilter = 'All';

  final List<String> _filterOptions = ['All', 'Completed', 'In Progress'];

  List<Map<String, dynamic>> get filteredLogs {
    if (selectedFilter == 'All') {
      return maintenanceLogs;
    }
    return maintenanceLogs.where((log) => log['status'] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Maintenance Logs',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              _showMoreOptions(); // New function for more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<String>(
                  value: selectedFilter,
                  icon: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.onSurface),
                  underline: Container(), // Remove the underline
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                  },
                  items: _filterOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Logs List
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          'No logs found',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _buildMaintenanceLogCard(log);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newLog = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(builder: (context) => const LogFormPage()),
          );

          if (newLog != null) {
            setState(() {
              maintenanceLogs.add(newLog);
            });
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildMaintenanceLogCard(Map<String, dynamic> log) {
    final isCompleted = log['status'] == 'Completed';
    final logIndex = maintenanceLogs.indexOf(log); // Get the index of the log
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder: (context) => LogFormPage(log: log, isViewOnly: true), // View-only mode
              ),
            );

            if (result != null) {
              if (result.containsKey('action') && result['action'] == 'delete') {
                // Handle delete action from the view-only form
                _confirmDeleteLog(log);
              } else {
                // Handle update from the edit mode initiated from view-only form
                setState(() {
                  final logIndex = maintenanceLogs.indexOf(log);
                  if (logIndex != -1) {
                    maintenanceLogs[logIndex] = result; // Update with the edited log
                  }
                });
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log['atmId'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompleted ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCompleted ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        log['status'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  log['location'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      '${log['date']} at ${log['time']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      log['technician'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.build, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      log['type'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteLog(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Log', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          content: Text('Are you sure you want to delete this log?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  maintenanceLogs.remove(log);
                });
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: Text('Delete', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );
  }

  void _showMoreOptions() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 60, // X position (right corner)
        AppBar().preferredSize.height + MediaQuery.of(context).padding.top, // Y position (below AppBar)
        0,
        0,
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuEntry<String> _buildPopupMenuItem(String value, String text) {
          return PopupMenuItem<String>(
            value: value,
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          );
        }

        return [
          _buildPopupMenuItem('settings', 'Settings'),
          _buildPopupMenuItem('help', 'Help'),
          _buildPopupMenuItem('about', 'About'),
        ];
      },
    ).then((value) {
      if (value != null) {
        // Handle selected option
        _handleMoreOptionSelected(value);
      }
    });
  }

  void _handleMoreOptionSelected(String value) {
    switch (value) {
      case 'settings':
        // Navigate to settings or perform action
        debugPrint('Settings selected');
        break;
      case 'help':
        // Navigate to help or perform action
        debugPrint('Help selected');
        break;
      case 'about':
        // Navigate to about or perform action
        debugPrint('About selected');
        break;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
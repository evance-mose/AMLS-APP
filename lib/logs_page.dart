import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Maintenance Logs',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // Implement search functionality
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
                  icon: const Icon(Icons.filter_list, color: Colors.black87),
                  underline: Container(), // Remove the underline
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                  },
                  items: _filterOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
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
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No logs found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
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
        onPressed: () {
          // Navigate to add new log screen
        },
        backgroundColor: Colors.black87,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMaintenanceLogCard(Map<String, dynamic> log) {
    final isCompleted = log['status'] == 'Completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            // Navigate to log details screen
            _showLogDetails(log);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log['atmId'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCompleted ? Colors.green.shade300 : Colors.orange.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        log['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  log['location'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '${log['date']} at ${log['time']}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      log['technician'],
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.build, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      log['type'],
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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

  void _showLogDetails(Map<String, dynamic> log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Log Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('ATM ID', log['atmId']),
                    _buildDetailRow('Location', log['location']),
                    _buildDetailRow('Date', log['date']),
                    _buildDetailRow('Time', log['time']),
                    _buildDetailRow('Technician', log['technician']),
                    _buildDetailRow('Type', log['type']),
                    _buildDetailRow('Status', log['status']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
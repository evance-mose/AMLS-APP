import 'package:flutter/material.dart';
import 'package:amls/issue_form_page.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  // Sample data - replace with actual data from your backend
  final List<Map<String, dynamic>> issues = [
    {
      'atmId': 'ATM-003',
      'location': 'City Center Branch',
      'issue': 'Card reader malfunction',
      'priority': 'High',
      'reportedDate': '2024-10-21',
      'status': 'Open',
    },
    {
      'atmId': 'ATM-007',
      'location': 'University Campus',
      'issue': 'Cash dispenser error',
      'priority': 'Critical',
      'reportedDate': '2024-10-21',
      'status': 'Assigned',
    },
    {
      'atmId': 'ATM-009',
      'location': 'Hospital Branch',
      'issue': 'Screen display issue',
      'priority': 'Medium',
      'reportedDate': '2024-10-20',
      'status': 'Open',
    },
    {
      'atmId': 'ATM-015',
      'location': 'Train Station',
      'issue': 'Receipt printer jam',
      'priority': 'Low',
      'reportedDate': '2024-10-20',
      'status': 'Resolved',
    },
    {
      'atmId': 'ATM-011',
      'location': 'Shopping Plaza',
      'issue': 'Network connectivity issue',
      'priority': 'High',
      'reportedDate': '2024-10-19',
      'status': 'Assigned',
    },
  ];

  String selectedFilter = 'All';

  final List<String> _filterOptions = ['All', 'Critical', 'High', 'Medium', 'Low'];

  List<Map<String, dynamic>> get filteredIssues {
    if (selectedFilter == 'All') {
      return issues;
    }
    return issues.where((issue) => issue['priority'] == selectedFilter).toList();
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
          'Issues & Reports',
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
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
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
          // Issues List
          Expanded(
            child: filteredIssues.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No issues found',
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
                    itemCount: filteredIssues.length,
                    itemBuilder: (context, index) {
                      final issue = filteredIssues[index];
                      return _buildIssueCard(issue);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newIssue = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(builder: (context) => const IssueFormPage()),
          );

          if (newIssue != null) {
            setState(() {
              issues.add(newIssue);
            });
          }
        },
        backgroundColor: Colors.black87,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDeleteIssue(Map<String, dynamic> issue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Issue'),
          content: const Text('Are you sure you want to delete this issue?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  issues.remove(issue);
                });
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        const PopupMenuItem<String>(
          value: 'settings',
          child: Text('Settings'),
        ),
        const PopupMenuItem<String>(
          value: 'help',
          child: Text('Help'),
        ),
        const PopupMenuItem<String>(
          value: 'about',
          child: Text('About'),
        ),
      ],
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

  Widget _buildIssueCard(Map<String, dynamic> issue) {
    Color priorityColor;
    switch (issue['priority']) {
      case 'Critical':
        priorityColor = Colors.red;
        break;
      case 'High':
        priorityColor = Colors.orange;
        break;
      case 'Medium':
        priorityColor = Colors.blue;
        break;
      default:
        priorityColor = Colors.green;
    }

    final isResolved = issue['status'] == 'Resolved';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder: (context) => IssueFormPage(issue: issue, isViewOnly: true), // View-only mode
              ),
            );

            if (result != null) {
              if (result.containsKey('action') && result['action'] == 'delete') {
                // Handle delete action from the view-only form
                _confirmDeleteIssue(issue);
              } else {
                // Handle update from the edit mode initiated from view-only form
                setState(() {
                  final issueIndex = issues.indexOf(issue);
                  if (issueIndex != -1) {
                    issues[issueIndex] = result; // Update with the edited issue
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
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      issue['atmId'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: priorityColor.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        issue['priority'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: priorityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  issue['location'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  issue['issue'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'Reported: ${issue['reportedDate']}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isResolved ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isResolved ? Colors.green.shade300 : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        issue['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isResolved ? Colors.green.shade700 : Colors.grey.shade700,
                        ),
                      ),
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
}
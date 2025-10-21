import 'package:amls/cubits/issues/issue_cubit.dart';
import 'package:flutter/material.dart';
import 'package:amls/issue_form_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  // Sample data - replace with actual data from your backend
  // final List<Map<String, dynamic>> issues = [
  //   {
  //     'atmId': 'ATM-003',
  //     'location': 'City Center Branch',
  //     'issue': 'Card reader malfunction',
  //     'priority': 'High',
  //     'reportedDate': '2024-10-21',
  //     'status': 'Open',
  //   },
  //   {
  //     'atmId': 'ATM-007',
  //     'location': 'University Campus',
  //     'issue': 'Cash dispenser error',
  //     'priority': 'Critical',
  //     'reportedDate': '2024-10-21',
  //     'status': 'Assigned',
  //   },
  //   {
  //     'atmId': 'ATM-009',
  //     'location': 'Hospital Branch',
  //     'issue': 'Screen display issue',
  //     'priority': 'Medium',
  //     'reportedDate': '2024-10-20',
  //     'status': 'Open',
  //   },
  //   {
  //     'atmId': 'ATM-015',
  //     'location': 'Train Station',
  //     'issue': 'Receipt printer jam',
  //     'priority': 'Low',
  //     'reportedDate': '2024-10-20',
  //     'status': 'Resolved',
  //   },
  //   {
  //     'atmId': 'ATM-011',
  //     'location': 'Shopping Plaza',
  //     'issue': 'Network connectivity issue',
  //     'priority': 'High',
  //     'reportedDate': '2024-10-19',
  //     'status': 'Assigned',
  //   },
  // ];

  String selectedFilter = 'All';

  final List<String> _filterOptions = ['All', 'Critical', 'High', 'Medium', 'Low'];

  List<Map<String, dynamic>> get filteredIssues {
    final currentIssues = (context.read<IssueCubit>().state as IssueLoaded).issues;
    if (selectedFilter == 'All') {
      return currentIssues;
    }
    return currentIssues.where((issue) => issue['priority'] == selectedFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    context.read<IssueCubit>().fetchIssues();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IssueCubit, IssueState>(
      listener: (context, state) {
        if (state is IssueError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        List<Map<String, dynamic>> displayIssues = [];
        bool isLoading = false;

        if (state is IssueLoaded) {
          displayIssues = state.issues;
        } else if (state is IssueLoading) {
          isLoading = true;
          displayIssues = (context.read<IssueCubit>().state is IssueLoaded)
              ? (context.read<IssueCubit>().state as IssueLoaded).issues
              : [];
        }

        final filteredDisplayIssues = displayIssues.where((issue) {
          if (selectedFilter == 'All') return true;
          return issue['priority'] == selectedFilter;
        }).toList();

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
              'Issues & Reports',
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
              // Issues List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredDisplayIssues.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.warning_amber_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                                const SizedBox(height: 16),
                                Text(
                                  'No issues found',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: filteredDisplayIssues.length,
                            itemBuilder: (context, index) {
                              final issue = filteredDisplayIssues[index];
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
                context.read<IssueCubit>().addIssue(newIssue);
              }
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
          ),
        );
      },
    );
  }

  void _confirmDeleteIssue(Map<String, dynamic> issue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Issue', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          content: Text('Are you sure you want to delete this issue?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
            ),
            TextButton(
              onPressed: () {
                context.read<IssueCubit>().deleteIssue(issue);
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
        priorityColor = Theme.of(context).colorScheme.error;
        break;
      case 'High':
        priorityColor = Theme.of(context).colorScheme.errorContainer;
        break;
      case 'Medium':
        priorityColor = Theme.of(context).colorScheme.tertiary;
        break;
      default:
        priorityColor = Theme.of(context).colorScheme.primary;
    }

    final isResolved = issue['status'] == 'Resolved';

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
                builder: (context) => IssueFormPage(issue: issue, isViewOnly: true), // View-only mode
              ),
            );

            if (result != null) {
              if (result.containsKey('action') && result['action'] == 'delete') {
                // Handle delete action from the view-only form
                _confirmDeleteIssue(issue);
              } else {
                // Handle update from the edit mode initiated from view-only form
                context.read<IssueCubit>().updateIssue(issue, result);
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
                      issue['atmId'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  issue['issue'],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Reported: ${issue['reportedDate']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isResolved ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isResolved ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        issue['status'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isResolved ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
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
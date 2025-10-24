import 'package:amls/cubits/issues/issue_cubit.dart';
import 'package:flutter/material.dart';
import 'package:amls/issue_form_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amls/models/issue_model.dart'; // Import the Issue model

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  String selectedFilter = 'All';

  final List<String> _filterOptions = ['All', 'Critical', 'High', 'Medium', 'Low'];

  // This getter should now work directly with Issue objects from the cubit state
  List<Issue> get filteredIssues {
    final currentIssues = (context.read<IssueCubit>().state as IssueLoaded).issues;
    if (selectedFilter == 'All') {
      return currentIssues;
    }
    return currentIssues.where((issue) => issue.priority.toString().split('.').last.toCapitalized() == selectedFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    context.read<IssueCubit>().fetchIssues();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<IssueCubit, IssueState>(
      listener: (context, state) {
        if (state is IssueError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        List<Issue> displayIssues = [];
        bool isLoading = false;

        if (state is IssueLoaded) {
          displayIssues = state.issues;
        } else if (state is IssueLoading) {
          isLoading = true;
          displayIssues = [];
        } else if (state is IssueInitial) {
          isLoading = true;
          displayIssues = [];
        } else if (state is IssueError) {
          displayIssues = [];
        }

        final filteredDisplayIssues = displayIssues.where((issue) {
          if (selectedFilter == 'All') return true;
          return issue.priority.toString().split('.').last.toCapitalized() == selectedFilter;
        }).toList();

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
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
              'Issues & Reports',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${filteredDisplayIssues.length} ${filteredDisplayIssues.length == 1 ? 'issue' : 'issues'}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
           
          ),
          body: Column(
            children: [
              // Filter Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Filter:',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filterOptions.map((option) {
                            final isSelected = selectedFilter == option;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(option),
                                selected: isSelected,
                                onSelected: (selected) {
                        setState(() {
                                    selectedFilter = option;
                        });
                      },
                                backgroundColor: colorScheme.surfaceVariant,
                                selectedColor: colorScheme.primaryContainer,
                                labelStyle: textTheme.bodySmall?.copyWith(
                                  color: isSelected 
                                      ? colorScheme.onPrimaryContainer 
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isSelected 
                                        ? colorScheme.primary 
                                        : Colors.transparent,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                        );
                      }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Issues List
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading issues...',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredDisplayIssues.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    state is IssueError ? Icons.error_outline : Icons.warning_amber_outlined,
                                    size: 64,
                                    color: state is IssueError ? colorScheme.error : colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  state is IssueError ? 'Failed to load issues' : 'No issues found',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state is IssueError 
                                    ? 'Check your connection and try again'
                                    : 'Start by creating a new issue',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (state is IssueError) ...[
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      context.read<IssueCubit>().fetchIssues();
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context.read<IssueCubit>().fetchIssues();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                            itemCount: filteredDisplayIssues.length,
                            itemBuilder: (context, index) {
                              final issue = filteredDisplayIssues[index];
                              return _buildIssueCard(issue);
                            },
                            ),
                          ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final newIssue = await Navigator.push<Issue?>(
                context,
                MaterialPageRoute(builder: (context) => const IssueFormPage()),
              );

              if (newIssue != null) {
                context.read<IssueCubit>().addIssue(newIssue);
              }
            },
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: const Icon(Icons.add),
            label: const Text('Report Issue'),
            elevation: 4,
          ),
        );
      },
    );
  }

  Widget _buildIssueCard(Issue issue) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color priorityColor;
    Color startColor;
    Color endColor;
    switch (issue.priority) {
      case IssuePriority.critical:
        priorityColor = Colors.red.shade600;
        startColor = Colors.red.shade400;
        endColor = Colors.red.shade600;
        break;
      case IssuePriority.high:
        priorityColor = Colors.deepOrange.shade600;
        startColor = Colors.deepOrange.shade400;
        endColor = Colors.deepOrange.shade600;
        break;
      case IssuePriority.medium:
        priorityColor = Colors.amber.shade600;
        startColor = Colors.amber.shade400;
        endColor = Colors.amber.shade600;
        break;
      default:
        priorityColor = Colors.green.shade600; // Low priority or other
        startColor = Colors.green.shade400;
        endColor = Colors.green.shade600;
    }

    final isOpen = issue.status == IssueStatus.open || issue.status == IssueStatus.assigned;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push<dynamic>(
              context,
              MaterialPageRoute(
                builder: (context) => IssueFormPage(issue: issue, isViewOnly: true),
              ),
            );

            if (result != null) {
              if (result is Map<String, dynamic> && result.containsKey('action') && result['action'] == 'delete') {
                _confirmDeleteIssue(issue);
              } else if (result is Issue) {
                // Result is an Issue object from editing
                context.read<IssueCubit>().updateIssue(issue, result);
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  issue.atmId,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                    Text(
                                  issue.location,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isOpen
                              ? [startColor, endColor]
                              : [Colors.grey.shade400, Colors.grey.shade600],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: priorityColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOpen ? Icons.priority_high : Icons.check_circle,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            issue.priority.toString().split('.').last.toCapitalized(),
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Divider
                Container(
                  height: 1,
                  color: colorScheme.outline.withOpacity(0.2),
                ),
                
                const SizedBox(height: 16),
                
                // Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.bug_report_outlined,
                        'Issue',
                        issue.description ?? 'N/A',
                        colorScheme,
                        textTheme,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colorScheme.outline.withOpacity(0.2),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today_outlined,
                        'Reported Date',
                        issue.reportedDate.toIso8601String().split('T').first,
                        colorScheme,
                        textTheme,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.assignment_ind_outlined,
                        'Status',
                        issue.status.toString().split('.').last.toCapitalized(),
                        colorScheme,
                        textTheme,
                      ),
                    ),
                    Container(
                          width: 1,
                      height: 40,
                      color: colorScheme.outline.withOpacity(0.2),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.person_outline,
                        'Assigned To',
                        issue.assignedUser?.name ?? 'N/A',
                        colorScheme,
                        textTheme,
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

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: colorScheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDeleteIssue(Issue issue) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              onPressed: () => Navigator.of(context).pop(),
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
                context.read<IssueCubit>().deleteIssue(issue);
                Navigator.of(context).pop();
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

  void _showMoreOptions() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 60,
        AppBar().preferredSize.height + MediaQuery.of(context).padding.top,
        0,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: <PopupMenuEntry<String>>[
        _buildPopupMenuItem('settings', 'Settings', Icons.settings_outlined),
        _buildPopupMenuItem('help', 'Help', Icons.help_outline),
        _buildPopupMenuItem('about', 'About', Icons.info_outline),
      ],
    ).then((value) {
      if (value != null) {
        _handleMoreOptionSelected(value);
      }
    });
  }

  PopupMenuEntry<String> _buildPopupMenuItem(String value, String text, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurface),
          const SizedBox(width: 12),
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  void _handleMoreOptionSelected(String value) {
    switch (value) {
      case 'settings':
        debugPrint('Settings selected');
        break;
      case 'help':
        debugPrint('Help selected');
        break;
      case 'about':
        debugPrint('About selected');
        break;
    }
  }
}

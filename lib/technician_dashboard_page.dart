
import 'package:amls/cubits/auth/auth_cubit.dart';
import 'package:amls/cubits/issues/issue_cubit.dart';
import 'package:amls/cubits/logs/log_cubit.dart';
import 'package:amls/database/sync_queue.dart';
import 'package:amls/models/issue_model.dart';
import 'package:amls/models/log_model.dart';
import 'package:amls/models/user_model.dart';
import 'package:amls/widgets/app_bar_settings_menu.dart';
import 'package:amls/widgets/dashboard_connectivity_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechnicianDashboardPage extends StatefulWidget {
  const TechnicianDashboardPage({super.key});

  @override
  State<TechnicianDashboardPage> createState() => _TechnicianDashboardPageState();
}

class _TechnicianDashboardPageState extends State<TechnicianDashboardPage> {
  int _pendingSyncCount = 0;

  Future<void> _reloadPendingCount() async {
    final n = await SyncQueue.pendingCount();
    if (mounted) setState(() => _pendingSyncCount = n);
  }

  Future<void> _syncNow() async {
    await Future.wait([
      context.read<IssueCubit>().fetchIssues(),
      context.read<LogCubit>().fetchLogs(),
    ]);
    if (!mounted) return;
    await _reloadPendingCount();
    if (!mounted) return;
    final msg = _pendingSyncCount > 0
        ? '$_pendingSyncCount change${_pendingSyncCount == 1 ? '' : 's'} waiting to sync when online.'
        : 'Data refreshed.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    super.initState();
    context.read<IssueCubit>().fetchIssues();
    context.read<LogCubit>().fetchLogs();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadPendingCount());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = context.watch<AuthCubit>().state;

    // Ensure user is technician
    if (authState is! AuthAuthenticated || authState.user?.role != UserRole.technician) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('You do not have permission to access this page.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AMLS',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          AppBarSettingsMenu(
            onSelected: (value) async {
              switch (value) {
                case 'connection':
                  showDashboardConnectionDialog(context);
                  break;
                case 'sync':
                  await _syncNow();
                  break;
                case 'logout':
                  await showSignOutConfirmDialog(context);
                  break;
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'connection',
                child: Row(
                  children: [
                    Icon(Icons.wifi, size: 20, color: colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text('Connection status', style: textTheme.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.sync, size: 20, color: colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text('Sync data', style: textTheme.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Text('Sign out', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<IssueCubit, IssueState>(
        builder: (context, issueState) {
          return BlocBuilder<LogCubit, LogState>(
            builder: (context, logState) {
              if (issueState is IssueError && logState is LogError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_outlined, size: 56, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load dashboard',
                          style: textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${issueState.message}\n${logState.message}',
                          style: textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () {
                            context.read<IssueCubit>().fetchIssues();
                            context.read<LogCubit>().fetchLogs();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final List<Issue> issues =
                  issueState is IssueLoaded ? issueState.issues : <Issue>[];
              final List<Log> logs = logState is LogLoaded ? logState.logs : <Log>[];

              final issuesWaiting =
                  issueState is IssueLoading || issueState is IssueInitial;
              final logsWaiting = logState is LogLoading || logState is LogInitial;
              final showGlobalLoader =
                  issues.isEmpty && logs.isEmpty && issuesWaiting && logsWaiting;

              if (showGlobalLoader) {
                return const Center(child: CircularProgressIndicator());
              }

              final showOfflineBanner = (issueState is IssueLoaded && issueState.fromCache) ||
                  (logState is LogLoaded && logState.fromCache);

              final user = (authState as AuthAuthenticated).user;

              // Get assigned issues
              final assignedIssues = issues.where((issue) {
                try {
                  return issue.assignedUser?.id == user?.id;
                } catch (e) {
                  return false;
                }
              }).toList();

              // Get my logs
              final myLogs = logs.where((log) {
                try {
                  return log.user?.id == user?.id;
                } catch (e) {
                  return false;
                }
              }).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    context.read<IssueCubit>().fetchIssues(),
                    context.read<LogCubit>().fetchLogs(),
                  ]);
                  await _reloadPendingCount();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showOfflineBanner || _pendingSyncCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showOfflineBanner)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.storage_outlined,
                                              color: colorScheme.onSecondaryContainer, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Showing saved data on this device. Use Sync or pull down to refresh when the network is available.',
                                              style: textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSecondaryContainer,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (_pendingSyncCount > 0) ...[
                                      if (showOfflineBanner) const SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.cloud_upload_outlined,
                                              color: colorScheme.onSecondaryContainer, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              '$_pendingSyncCount update${_pendingSyncCount == 1 ? '' : 's'} queued — open Settings → Sync data when you are online.',
                                              style: textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSecondaryContainer,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        _buildWelcomeCard(context, user),
                        const SizedBox(height: 24),
                        _buildStatsCards(context, assignedIssues, myLogs),
                        const SizedBox(height: 32),
                        Text(
                          'Quick Check',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTechnicianActionCards(context),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/ai-assistant');
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.psychology_outlined),
        label: const Text('AI Assistant'),
        elevation: 4,
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, User? user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.person_outline, color: colorScheme.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.name ?? 'Technician'}!',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Resolve tasks and update maintenance logs',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, List<dynamic> assignedIssues, List<dynamic> myLogs) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final pendingIssues = assignedIssues.where((issue) {
      try {
        return issue.status.toString().contains('open') || issue.status.toString().contains('acknowledged');
      } catch (e) {
        return false;
      }
    }).length;

    final completedLogs = myLogs.where((log) {
      try {
        return log.status.toString().contains('completed');
      } catch (e) {
        return false;
      }
    }).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Assigned Tasks',
                assignedIssues.length.toString(),
                Icons.assignment,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Pending',
                pendingIssues.toString(),
                Icons.pending,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Completed',
                completedLogs.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Logs',
                myLogs.length.toString(),
                Icons.list_alt,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(
          //   padding: const EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //     color: color.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   child: Icon(icon, color: color, size: 24),
          // ),
          // const SizedBox(height: 16),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianActionCards(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _buildModernActionCard(
          context,
          'View Assigned Issues',
          'See all issues assigned to you',
          Icons.assignment,
          [Colors.blue.shade600, Colors.blue.shade400],
          () => Navigator.pushNamed(context, '/issues'),
        ),
        const SizedBox(height: 16),
        _buildModernActionCard(
          context,
          'Maintenance Logs',
          'Create and update maintenance logs',
          Icons.build_circle_outlined,
          [Colors.teal.shade600, Colors.teal.shade400],
          () => Navigator.pushNamed(context, '/logs'),
        ),
        const SizedBox(height: 16),
        // _buildModernActionCard(
        //   context,
        //   'AI Assistant',
        //   'Get technical support and guidance',
        //   Icons.psychology_outlined,
        //   [Colors.purple.shade600, Colors.purple.shade400],
        //   () => Navigator.pushNamed(context, '/ai-assistant'),
        // ),
      ],
    );
  }

  Widget _buildModernActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


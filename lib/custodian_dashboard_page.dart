import 'package:amls/cubits/auth/auth_cubit.dart';
import 'package:amls/cubits/issues/issue_cubit.dart';
import 'package:amls/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustodianDashboardPage extends StatefulWidget {
  const CustodianDashboardPage({super.key});

  @override
  State<CustodianDashboardPage> createState() => _CustodianDashboardPageState();
}

class _CustodianDashboardPageState extends State<CustodianDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<IssueCubit>().fetchIssues();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = context.watch<AuthCubit>().state;

    // Ensure user is custodian
    if (authState is! AuthAuthenticated || authState.user?.role != UserRole.custodian) {
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.assignment_outlined, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AMLS',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  // Text(
                  //   'Fault Logging',
                  //   style: textTheme.bodySmall?.copyWith(
                  //     color: colorScheme.onSurfaceVariant,
                  //   ),
                  //   overflow: TextOverflow.ellipsis,
                  //   maxLines: 1,
                  // ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: () {
              context.read<IssueCubit>().fetchIssues();
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onSelected: (value) {
              if (value == 'logout') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthCubit>().logout();
                        },
                        child: Text('Logout', style: TextStyle(color: colorScheme.error)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text('Logout', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<IssueCubit, IssueState>(
        listener: (context, state) {
          if (state is IssueError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is IssueLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IssueError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Failed to load issues', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(state.message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<IssueCubit>().fetchIssues();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<dynamic> issues = [];
          if (state is IssueLoaded) {
            issues = state.issues;
          }

          // Get user's reported issues
          final user = (authState as AuthAuthenticated).user;
          final myIssues = issues.where((issue) {
            // Filter issues reported by this custodian (you may need to adjust this based on your data model)
            return true; // For now, show all issues
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<IssueCubit>().fetchIssues();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(context, user),
                    const SizedBox(height: 24),
                    _buildStatsCards(context, issues),
                    const SizedBox(height: 32),
                    Text(
                      'Quick Actions',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCustodianActionCards(context),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
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
                  'Welcome, ${user?.name ?? 'Custodian'}!',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Log faults and report issues quickly',
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

  Widget _buildStatsCards(BuildContext context, List<dynamic> issues) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final totalIssues = issues.length;
    final openIssues = issues.where((issue) {
      try {
        return issue.status.toString().contains('open');
      } catch (e) {
        return false;
      }
    }).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Issues',
            totalIssues.toString(),
            Icons.warning_outlined,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Open Issues',
            openIssues.toString(),
            Icons.info_outlined,
            Colors.red,
          ),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
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

  Widget _buildCustodianActionCards(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _buildModernActionCard(
          context,
          'Log New Fault',
          'Report a new issue or fault',
          Icons.add_alert,
          [Colors.red.shade600, Colors.red.shade400],
          () async {
            final result = await Navigator.pushNamed(context, '/issues');
            if (result != null) {
              context.read<IssueCubit>().fetchIssues();
            }
          },
        ),
        const SizedBox(height: 16),
        _buildModernActionCard(
          context,
          'View My Reports',
          'View all faults you have reported',
          Icons.list_alt,
          [Colors.blue.shade600, Colors.blue.shade400],
          () => Navigator.pushNamed(context, '/issues'),
        ),
        // const SizedBox(height: 16),
        // _buildModernActionCard(
        //   context,
        //   'AI Assistant',
        //   'Get help with fault diagnosis',
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


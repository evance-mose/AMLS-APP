import 'package:amls/cubits/auth/auth_cubit.dart';
import 'package:amls/cubits/home/home_cubit.dart';
import 'package:amls/models/user_model.dart';
import 'package:amls/widgets/app_bar_settings_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().fetchHomeSummary(month: _selectedMonth, year: _selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthAuthenticated || authState.user?.role != UserRole.admin) {
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
              child: Icon(Icons.dashboard_outlined, color: colorScheme.primary, size: 24),
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
                  Text(
                    'Admin Dashboard',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppBarSettingsMenu(
            onSelected: (value) {
              if (value == 'refresh') {
                context.read<HomeCubit>().fetchHomeSummary(month: _selectedMonth, year: _selectedYear);
              } else if (value == 'logout') {
                showSignOutConfirmDialog(context);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20, color: colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text('Refresh dashboard', style: textTheme.bodyMedium),
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
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<HomeCubit>().fetchHomeSummary(month: _selectedMonth, year: _selectedYear);
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Failed to load dashboard data', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(state.message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<HomeCubit>().fetchHomeSummary(month: _selectedMonth, year: _selectedYear);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeCubit>().fetchHomeSummary(month: _selectedMonth, year: _selectedYear);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthYearSelectors(context),
                      const SizedBox(height: 24),
                      if (state.monthlyReport != null) ...[
                        _buildMonthlyReportHeader(context, state.monthlyReport!),
                        const SizedBox(height: 24),
                      ],
                      _buildKPIGrid(context, state),
                      const SizedBox(height: 32),
                      Text(
                        'Admin Actions',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAdminActionCards(context),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
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

  Widget _buildMonthYearSelectors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - 2 + i);

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedMonth,
            decoration: InputDecoration(
              labelText: 'Month',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: List.generate(12, (i) => i + 1).map((m) {
              return DropdownMenuItem(value: m, child: Text(months[m - 1]));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedMonth = value);
                context.read<HomeCubit>().fetchHomeSummary(month: value, year: _selectedYear);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedYear,
            decoration: InputDecoration(
              labelText: 'Year',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedYear = value);
                context.read<HomeCubit>().fetchHomeSummary(month: _selectedMonth, year: value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyReportHeader(BuildContext context, dynamic monthlyReport) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reportInfo = monthlyReport.reportInfo;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.summarize, color: colorScheme.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Report',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${reportInfo.date} • ${reportInfo.generatedBy}',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(BuildContext context, dynamic state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Logs',
                '${state.totalLogs}',
                Icons.list_alt,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Issues',
                '${state.totalIssues}',
                Icons.warning_amber_outlined,
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
                'Open Issues',
                '${state.openIssues}',
                Icons.info_outlined,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Critical',
                '${state.criticalIssues}',
                Icons.priority_high,
                Colors.deepOrange,
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
                'Resolution Rate',
                '${state.resolutionRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Avg Resolution (hrs)',
                state.avgResolutionTime.toStringAsFixed(1),
                Icons.schedule,
                Colors.teal,
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
      padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionCards(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _buildModernActionCard(
          context,
          'User Management',
          'Manage users and roles',
          Icons.people,
          [Colors.blue.shade600, Colors.blue.shade400],
          () => Navigator.pushNamed(context, '/users'),
        ),
        const SizedBox(height: 16),
        _buildModernActionCard(
          context,
          'View Issues',
          'View and manage all issues',
          Icons.assignment,
          [Colors.orange.shade600, Colors.orange.shade400],
          () => Navigator.pushNamed(context, '/issues'),
        ),
        const SizedBox(height: 16),
        _buildModernActionCard(
          context,
          'Maintenance Logs',
          'View maintenance logs',
          Icons.build_circle_outlined,
          [Colors.teal.shade600, Colors.teal.shade400],
          () => Navigator.pushNamed(context, '/logs'),
        ),
        // const SizedBox(height: 16),
        // _buildModernActionCard(
        //   context,
        //   'AI Assistant',
        //   'Get insights and support',
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

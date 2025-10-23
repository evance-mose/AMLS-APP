import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:amls/services/api_instances.dart';
import 'package:amls/services/api_service.dart';
import 'package:amls/models/log_model.dart';
import 'package:amls/models/issue_model.dart';
import 'package:amls/models/monthly_report_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  void fetchHomeSummary() async {
    emit(HomeLoading());
    
    try {
      // Fetch monthly report data from API
      final monthlyReport = await ApiService.fetchMonthlyReport();
      
      // Fetch logs and issues data from API for additional metrics
      final logs = await ApiInstances.logApi.fetchAll();
      final issues = await ApiInstances.issueApi.fetchAll();
      
      // Calculate metrics from real data
      final totalLogs = logs.length;
      final totalIssues = issues.length;
      
      // Count logs by status
      final completedLogs = logs.where((log) => log.status == LogStatus.completed).length;
      final pendingLogs = logs.where((log) => log.status == LogStatus.pending).length;
      final inProgressLogs = logs.where((log) => log.status == LogStatus.in_progress).length;
      
      // Count issues by status
      final openIssues = issues.where((issue) => issue.status == IssueStatus.open).length;
      final acknowledgedIssues = issues.where((issue) => issue.status == IssueStatus.acknowledged).length;
      final criticalIssues = issues.where((issue) => issue.priority == IssuePriority.critical).length;
      
      // Use monthly report data for resolution metrics
      final resolutionRate = monthlyReport.issueStats.resolutionRate;
      final avgResolutionTime = monthlyReport.issueStats.avgResolutionTimeInHours;

      emit(HomeLoaded(
        totalLogs: totalLogs,
        totalIssues: totalIssues,
        completedLogs: completedLogs,
        pendingLogs: pendingLogs,
        inProgressLogs: inProgressLogs,
        openIssues: openIssues,
        acknowledgedIssues: acknowledgedIssues,
        criticalIssues: criticalIssues,
        resolutionRate: resolutionRate,
        avgResolutionTime: avgResolutionTime,
        recentLogs: logs.take(5).toList(),
        recentIssues: issues.take(5).toList(),
        monthlyReport: monthlyReport,
      ));
    } catch (e) {
      emit(HomeError('Failed to fetch dashboard data: $e'));
    }
  }
}

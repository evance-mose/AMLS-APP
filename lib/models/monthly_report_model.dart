class MonthlyReport {
  final ReportInfo reportInfo;
  final IssueStats issueStats;

  MonthlyReport({
    required this.reportInfo,
    required this.issueStats,
  });

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    return MonthlyReport(
      reportInfo: ReportInfo.fromJson(json['reportInfo']),
      issueStats: IssueStats.fromJson(json['issueStats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportInfo': reportInfo.toJson(),
      'issueStats': issueStats.toJson(),
    };
  }
}

class ReportInfo {
  final String id;
  final String date;
  final String generatedBy;

  ReportInfo({
    required this.id,
    required this.date,
    required this.generatedBy,
  });

  factory ReportInfo.fromJson(Map<String, dynamic> json) {
    return ReportInfo(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      generatedBy: json['generatedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'generatedBy': generatedBy,
    };
  }
}

class IssueStats {
  final int total;
  final int resolved;
  final int pending;
  final String avgResolutionTime;

  IssueStats({
    required this.total,
    required this.resolved,
    required this.pending,
    required this.avgResolutionTime,
  });

  factory IssueStats.fromJson(Map<String, dynamic> json) {
    return IssueStats(
      total: json['total'] ?? 0,
      resolved: json['resolved'] ?? 0,
      pending: json['pending'] ?? 0,
      avgResolutionTime: json['avgResolutionTime'] ?? '0h',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'resolved': resolved,
      'pending': pending,
      'avgResolutionTime': avgResolutionTime,
    };
  }

  // Helper method to parse resolution time to hours
  double get avgResolutionTimeInHours {
    final timeStr = avgResolutionTime.replaceAll('h', '');
    return double.tryParse(timeStr) ?? 0.0;
  }

  // Calculate resolution rate percentage
  double get resolutionRate {
    if (total == 0) return 0.0;
    return (resolved / total) * 100;
  }
}

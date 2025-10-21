import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'issue_state.dart';

class IssueCubit extends Cubit<IssueState> {
  IssueCubit() : super(IssueInitial());

  final List<Map<String, dynamic>> _issues = [
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

  void fetchIssues() async {
    emit(IssueLoading());
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    emit(IssueLoaded(List.from(_issues)));
  }

  void addIssue(Map<String, dynamic> issue) async {
    emit(IssueLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    _issues.add(issue);
    emit(IssueLoaded(List.from(_issues)));
  }

  void updateIssue(Map<String, dynamic> oldIssue, Map<String, dynamic> newIssue) async {
    emit(IssueLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _issues.indexOf(oldIssue);
    if (index != -1) {
      _issues[index] = newIssue;
    }
    emit(IssueLoaded(List.from(_issues)));
  }

  void deleteIssue(Map<String, dynamic> issue) async {
    emit(IssueLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    _issues.remove(issue);
    emit(IssueLoaded(List.from(_issues)));
  }
}

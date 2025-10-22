import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:amls/models/issue_model.dart'; // Import the Issue model

part 'issue_state.dart';

class IssueCubit extends Cubit<IssueState> {
  IssueCubit() : super(IssueInitial());

  final List<Issue> _issues = [
    Issue(
      id: 1,
      atmId: 'ATM-003',
      location: 'City Center Branch',
      category: IssueCategory.card_reader_errors,
      description: 'Card reader malfunction, not accepting cards.',
      priority: IssuePriority.high,
      reportedDate: DateTime.parse('2024-10-21T10:00:00Z'),
      status: IssueStatus.open,
      createdAt: DateTime.parse('2024-10-21T10:00:00Z'),
      updatedAt: DateTime.parse('2024-10-21T10:00:00Z'),
      userId: 1,
    ),
    Issue(
      id: 2,
      atmId: 'ATM-007',
      location: 'University Campus',
      category: IssueCategory.dispenser_errors,
      description: 'Cash dispenser not working, no money dispensed.',
      priority: IssuePriority.critical,
      reportedDate: DateTime.parse('2024-10-21T14:00:00Z'),
      status: IssueStatus.assigned,
      assignedTo: 2,
      createdAt: DateTime.parse('2024-10-21T14:00:00Z'),
      updatedAt: DateTime.parse('2024-10-21T14:00:00Z'),
      userId: 1,
    ),
    Issue(
      id: 3,
      atmId: 'ATM-009',
      location: 'Hospital Branch',
      category: IssueCategory.epp_errors,
      description: 'Screen display is flickering and unreadable.',
      priority: IssuePriority.medium,
      reportedDate: DateTime.parse('2024-10-20T09:30:00Z'),
      status: IssueStatus.open,
      createdAt: DateTime.parse('2024-10-20T09:30:00Z'),
      updatedAt: DateTime.parse('2024-10-20T09:30:00Z'),
      userId: 1,
    ),
    Issue(
      id: 4,
      atmId: 'ATM-015',
      location: 'Train Station',
      category: IssueCategory.receipt_printer_errors,
      description: 'Receipt printer jammed, unable to print.',
      priority: IssuePriority.low,
      reportedDate: DateTime.parse('2024-10-20T11:00:00Z'),
      status: IssueStatus.resolved,
      createdAt: DateTime.parse('2024-10-20T11:00:00Z'),
      updatedAt: DateTime.parse('2024-10-20T11:00:00Z'),
      userId: 1,
    ),
    Issue(
      id: 5,
      atmId: 'ATM-011',
      location: 'Shopping Plaza',
      category: IssueCategory.pc_core_errors,
      description: 'ATM network connectivity intermittent.',
      priority: IssuePriority.high,
      reportedDate: DateTime.parse('2024-10-19T16:00:00Z'),
      status: IssueStatus.assigned,
      assignedTo: 2,
      createdAt: DateTime.parse('2024-10-19T16:00:00Z'),
      updatedAt: DateTime.parse('2024-10-19T16:00:00Z'),
      userId: 1,
    ),
  ];

  void fetchIssues() async {
    emit(IssueLoading());
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    emit(IssueLoaded(List.from(_issues)));
  }

  void addIssue(Issue issue) async {
    emit(IssueLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    _issues.add(issue);
    emit(IssueLoaded(List.from(_issues)));
  }

  void updateIssue(Issue oldIssue, Issue newIssue) async {
    emit(IssueLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _issues.indexWhere((issue) => issue.id == oldIssue.id);
    if (index != -1) {
      _issues[index] = newIssue;
    }
    emit(IssueLoaded(List.from(_issues)));
  }

  void deleteIssue(Issue issue) async {
    emit(IssueLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    _issues.removeWhere((i) => i.id == issue.id);
    emit(IssueLoaded(List.from(_issues)));
  }
}

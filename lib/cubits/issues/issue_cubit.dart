import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:amls/models/issue_model.dart';
import 'package:amls/services/api_instances.dart';
import 'package:amls/services/api_service.dart';

part 'issue_state.dart';

class IssueCubit extends Cubit<IssueState> {
  IssueCubit() : super(IssueInitial());


  void fetchIssues() async {
    emit(IssueLoading());
    
    try {
      final issues = await ApiInstances.issueApi.fetchAll();
      emit(IssueLoaded(issues));
    } catch (e) {
      emit(IssueError('Error fetching issues: $e'));
    }
  }

 void addLog(Issue log, {String? actionTaken}) async {
    emit(IssueLoading());
    
    try {
      await ApiService.createLog(log, actionTaken: actionTaken);
      // Refresh the logs list after successful creation
      fetchIssues();
    } catch (e) {
     
      emit(IssueError('Error Assigning issue: $e'));
    }
  }
  void addIssue(Issue issue) async {
    emit(IssueLoading());
    
    try {
      await ApiInstances.issueApi.create(issue);
      // Refresh the issues list after successful creation
      fetchIssues();
    } catch (e) {
      emit(IssueError('Error adding issue: $e'));
    }
  }

  void updateIssue(Issue oldIssue, Issue newIssue) async {
    emit(IssueLoading());
    
    try {
      await ApiInstances.issueApi.update(oldIssue.id, newIssue);
      // Refresh the issues list after successful update
      fetchIssues();
    } catch (e) {
      emit(IssueError('Error updating issue: $e'));
    }
  }

  void deleteIssue(Issue issue) async {
    emit(IssueLoading());
    
    try {
      await ApiInstances.issueApi.delete(issue.id);
      // Refresh the issues list after successful deletion
      fetchIssues();
    } catch (e) {
      emit(IssueError('Error deleting issue: $e'));
    }
  }
}

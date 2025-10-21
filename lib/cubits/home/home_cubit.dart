import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  void fetchHomeSummary() async {
    emit(HomeLoading());
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    // Dummy data
    final int totalLogs = 3;
    final int activeIssues = 3;
    final int inProgressLogs = 1;
    final int criticalIssues = 1;

    emit(HomeLoaded(
      totalLogs: totalLogs,
      activeIssues: activeIssues,
      inProgressLogs: inProgressLogs,
      criticalIssues: criticalIssues,
    ));
  }
}

import 'package:amls/services/generic_api_service.dart';
import 'package:amls/models/log_model.dart';
import 'package:amls/models/issue_model.dart';

class ApiInstances {
  static final GenericApiService<Log> logApi = GenericApiService<Log>(
    endpoint: 'logs',
    fromJson: (json) => Log.fromJson(json),
  );

  static final GenericApiService<Issue> issueApi = GenericApiService<Issue>(
    endpoint: 'issues',
    fromJson: (json) => Issue.fromJson(json),
  );
}



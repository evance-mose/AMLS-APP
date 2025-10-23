# Generic API Service

This directory contains a generic API service implementation that reduces code duplication and makes it easy to add new API endpoints.

## Architecture

### 1. GenericApiService<T>

A generic class that handles all CRUD operations for any model that implements `ApiModel`.

### 2. ApiModel Interface

All models must implement this interface:

```dart
abstract class ApiModel {
  int get id;
  Map<String, dynamic> toJson();
}
```

### 3. ApiInstances

Centralized instances of the generic API service for different models.

## Usage

### Adding a New Model

1. **Implement ApiModel interface:**

```dart
class MyModel implements ApiModel {
  final int id;
  // ... other fields

  @override
  Map<String, dynamic> toJson() {
    // ... implementation
  }
}
```

2. **Add to ApiInstances:**

```dart
class ApiInstances {
  // ... existing instances

  static final GenericApiService<MyModel> myModelApi = GenericApiService<MyModel>(
    endpoint: 'my-models',
    fromJson: (json) => MyModel.fromJson(json),
  );
}
```

3. **Use in Cubit:**

```dart
class MyModelCubit extends Cubit<MyModelState> {
  void fetchMyModels() async {
    emit(MyModelLoading());
    try {
      final models = await ApiInstances.myModelApi.fetchAll();
      emit(MyModelLoaded(models));
    } catch (e) {
      emit(MyModelError('Error: $e'));
    }
  }
}
```

## Available Methods

- `fetchAll()` - GET /api/{endpoint}
- `create(T item)` - POST /api/{endpoint}
- `update(int id, T item)` - PUT /api/{endpoint}/{id}
- `delete(int id)` - DELETE /api/{endpoint}/{id}
- `getById(int id)` - GET /api/{endpoint}/{id}

## Benefits

1. **Code Reuse**: No need to duplicate API logic for each model
2. **Type Safety**: Generic types ensure compile-time safety
3. **Consistency**: All API calls follow the same pattern
4. **Maintainability**: Changes to API logic only need to be made in one place
5. **Extensibility**: Easy to add new endpoints without writing boilerplate code

## Example

```dart
// Before (duplicated code)
class LogApiService {
  Future<List<Log>> fetchLogs() async { /* ... */ }
  Future<Log> createLog(Log log) async { /* ... */ }
  // ... more methods
}

class IssueApiService {
  Future<List<Issue>> fetchIssues() async { /* ... */ }
  Future<Issue> createIssue(Issue issue) async { /* ... */ }
  // ... more methods
}

// After (generic, reusable)
class GenericApiService<T extends ApiModel> {
  Future<List<T>> fetchAll() async { /* ... */ }
  Future<T> create(T item) async { /* ... */ }
  // ... more methods
}
```


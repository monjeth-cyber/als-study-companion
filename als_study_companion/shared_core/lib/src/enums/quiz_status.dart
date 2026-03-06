/// Status of a quiz attempt.
enum QuizStatus {
  notStarted,
  inProgress,
  completed,
  passed,
  failed;

  String get displayName {
    switch (this) {
      case QuizStatus.notStarted:
        return 'Not Started';
      case QuizStatus.inProgress:
        return 'In Progress';
      case QuizStatus.completed:
        return 'Completed';
      case QuizStatus.passed:
        return 'Passed';
      case QuizStatus.failed:
        return 'Failed';
    }
  }

  static QuizStatus fromString(String value) {
    return QuizStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => QuizStatus.notStarted,
    );
  }
}

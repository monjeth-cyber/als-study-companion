/// Status of a lesson for a student.
enum LessonStatus {
  notStarted,
  inProgress,
  completed,
  downloaded;

  String get displayName {
    switch (this) {
      case LessonStatus.notStarted:
        return 'Not Started';
      case LessonStatus.inProgress:
        return 'In Progress';
      case LessonStatus.completed:
        return 'Completed';
      case LessonStatus.downloaded:
        return 'Downloaded';
    }
  }

  static LessonStatus fromString(String value) {
    return LessonStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => LessonStatus.notStarted,
    );
  }
}

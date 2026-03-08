/// Input validation utilities.
class Validators {
  Validators._();

  /// Validates an email address.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  /// Validates a password (minimum 8 characters).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? validatePhoneRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.trim())) return 'Enter a valid phone number';
    return null;
  }

  /// Validates a required field is not empty.
  static String? validateRequired(
    String? value, [
    String fieldName = 'This field',
  ]) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  /// Validates a full name (at least 2 characters).
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  /// Validates a phone number.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null; // Optional
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  /// Validates a Philippine national ID / LRN (Learner Reference Number).
  /// LRN is a 12-digit number assigned by DepEd.
  static String? validateLearnerReferenceNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'LRN is required';
    final lrnRegex = RegExp(r'^\d{12}$');
    if (!lrnRegex.hasMatch(value.trim())) {
      return 'LRN must be exactly 12 digits';
    }
    return null;
  }

  /// Validates a student ID number (alphanumeric, min 4 chars).
  static String? validateStudentIdNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    if (value.trim().length < 4) {
      return 'Student ID must be at least 4 characters';
    }
    final idRegex = RegExp(r'^[A-Za-z0-9\-]+$');
    if (!idRegex.hasMatch(value.trim())) {
      return 'Student ID can only contain letters, numbers, and hyphens';
    }
    return null;
  }

  /// Validates guardian name (at least 2 characters, optional).
  static String? validateGuardianName(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    if (value.trim().length < 2) {
      return 'Guardian name must be at least 2 characters';
    }
    return null;
  }

  /// Validates guardian contact (phone number, required when guardian name is provided).
  static String? validateGuardianContact(
    String? value, {
    String? guardianName,
  }) {
    if (guardianName != null && guardianName.trim().isNotEmpty) {
      if (value == null || value.trim().isEmpty) {
        return 'Guardian contact is required when guardian name is provided';
      }
    }
    if (value == null || value.isEmpty) return null;
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.trim())) return 'Enter a valid phone number';
    return null;
  }

  /// Validates a date of birth (must be in the past, age 5–80).
  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) return 'Date of birth is required';
    final now = DateTime.now();
    final age =
        now.year -
        value.year -
        (now.isBefore(DateTime(now.year, value.month, value.day)) ? 1 : 0);
    if (age < 5) return 'Must be at least 5 years old';
    if (age > 80) return 'Please check the date of birth';
    return null;
  }

  /// Validates grade level (must be a recognized ALS level).
  static String? validateGradeLevel(String? value) {
    if (value == null || value.trim().isEmpty) return 'Grade level is required';
    final validLevels = [
      'BLP',
      'ALS-EST Elementary',
      'ALS-EST JHS',
      'Elementary',
      'Junior High School',
      'Senior High School',
    ];
    if (!validLevels.contains(value.trim())) {
      return 'Must be one of: ${validLevels.join(", ")}';
    }
    return null;
  }
}

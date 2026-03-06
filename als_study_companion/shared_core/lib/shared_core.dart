/// Shared Core Library for ALS Study Companion
///
/// Contains shared models, utilities, constants, and enums
/// used across mobile_app, admin_web, and backend_services.
library;

// Models
export 'src/models/user_model.dart';
export 'src/models/student_model.dart';
export 'src/models/teacher_model.dart';
export 'src/models/lesson_model.dart';
export 'src/models/quiz_model.dart';
export 'src/models/question_model.dart';
export 'src/models/progress_model.dart';
export 'src/models/session_model.dart';
export 'src/models/announcement_model.dart';
export 'src/models/als_center_model.dart';
export 'src/models/download_model.dart';

// Enums
export 'src/enums/user_role.dart';
export 'src/enums/lesson_status.dart';
export 'src/enums/quiz_status.dart';
export 'src/enums/sync_status.dart';
export 'src/enums/download_status.dart';

// Constants
export 'src/constants/app_constants.dart';
export 'src/constants/db_constants.dart';
export 'src/constants/firestore_constants.dart';

// Utils
export 'src/utils/date_utils.dart';
export 'src/utils/validators.dart';
export 'src/utils/string_extensions.dart';

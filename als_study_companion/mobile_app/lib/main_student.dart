import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/services/connectivity_service.dart';
import 'core/database/database_helper.dart';
import 'core/local/local_database.dart';
import 'core/services/supabase_auth_service.dart';
import 'shared/viewmodels/auth_viewmodel.dart';
import 'shared/viewmodels/sync_viewmodel.dart';
import 'student/viewmodels/lesson_viewmodel.dart';
import 'student/viewmodels/quiz_viewmodel.dart';
import 'student/viewmodels/progress_viewmodel.dart';
import 'student/viewmodels/download_viewmodel.dart';
import 'student/views/student_dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://igaukxfswcpwvgdwcjuh.supabase.co',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    debug: false,
  );

  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(),
          dispose: (_, s) => s.dispose(),
        ),
        Provider<LocalDatabase>(
          create: (_) => LocalDatabase(),
          dispose: (_, db) => db.close(),
        ),
        Provider<SupabaseAuthService>(create: (_) => SupabaseAuthService()),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            authService: context.read<SupabaseAuthService>(),
            localDb: context.read<LocalDatabase>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SyncViewModel()),
        ChangeNotifierProvider(create: (_) => LessonViewModel()),
        ChangeNotifierProvider(create: (_) => QuizViewModel()),
        ChangeNotifierProvider(create: (_) => ProgressViewModel()),
        ChangeNotifierProvider(create: (_) => DownloadViewModel()),
      ],
      child: MaterialApp(
        title: 'ALS Student',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        home: const StudentDashboardView(),
      ),
    );
  }
}

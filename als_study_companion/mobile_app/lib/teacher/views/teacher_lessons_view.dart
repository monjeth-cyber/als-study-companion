import 'package:flutter/material.dart';

/// View for teachers to manage their lessons.
class TeacherLessonsView extends StatelessWidget {
  const TeacherLessonsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Lessons')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to lesson creation form
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No lessons created yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first lesson',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

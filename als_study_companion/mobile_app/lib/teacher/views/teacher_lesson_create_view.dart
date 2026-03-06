import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_core/shared_core.dart';
import 'package:uuid/uuid.dart';
import '../viewmodels/teacher_lesson_viewmodel.dart';
import '../viewmodels/video_upload_viewmodel.dart';

/// View for creating a lesson and uploading video + materials.
class TeacherLessonCreateView extends StatefulWidget {
  const TeacherLessonCreateView({super.key});

  @override
  State<TeacherLessonCreateView> createState() =>
      _TeacherLessonCreateViewState();
}

class _TeacherLessonCreateViewState extends State<TeacherLessonCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _gradeLevelController = TextEditingController();
  final _durationController = TextEditingController();

  String? _selectedVideoName;
  PlatformFile? _selectedVideo;
  String? _selectedMaterialName;
  PlatformFile? _selectedMaterial;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _gradeLevelController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedVideo = result.files.first;
        _selectedVideoName = result.files.first.name;
      });
    }
  }

  Future<void> _pickMaterial() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedMaterial = result.files.first;
        _selectedMaterialName = result.files.first.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uploadVm = context.read<VideoUploadViewModel>();
    final lessonVm = context.read<TeacherLessonViewModel>();
    final lessonId = const Uuid().v4();
    final now = DateTime.now();

    String? videoUrl;
    String? materialUrl;

    // Upload video if selected
    if (_selectedVideo?.bytes != null) {
      videoUrl = await uploadVm.uploadLessonVideo(
        lessonId: lessonId,
        videoBytes: _selectedVideo!.bytes!,
        fileName: _selectedVideoName!,
      );
      if (videoUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(uploadVm.errorMessage ?? 'Video upload failed'),
            ),
          );
        }
        return;
      }
    }

    // Upload material if selected
    if (_selectedMaterial?.bytes != null) {
      materialUrl = await uploadVm.uploadLessonMaterial(
        lessonId: lessonId,
        fileBytes: _selectedMaterial!.bytes!,
        fileName: _selectedMaterialName!,
      );
    }

    final lesson = LessonModel(
      id: lessonId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      subject: _subjectController.text.trim(),
      gradeLevel: _gradeLevelController.text.trim(),
      videoUrl: videoUrl,
      studyGuideUrl: materialUrl,
      teacherId: '', // Will be set by repository from auth context
      durationMinutes: int.tryParse(_durationController.text) ?? 0,
      isPublished: false,
      createdAt: now,
      updatedAt: now,
    );

    final success = await lessonVm.createLesson(lesson);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson created successfully')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lessonVm.errorMessage ?? 'Failed to create lesson'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Lesson')),
      body: Consumer<VideoUploadViewModel>(
        builder: (context, uploadVm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Lesson Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => Validators.validateRequired(v, 'Title'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        Validators.validateRequired(v, 'Description'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              Validators.validateRequired(v, 'Subject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _gradeLevelController,
                          decoration: const InputDecoration(
                            labelText: 'Grade Level',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              Validators.validateRequired(v, 'Grade level'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Video picker
                  _FilePickerTile(
                    icon: Icons.videocam,
                    label: 'Lesson Video',
                    fileName: _selectedVideoName,
                    onPick: _pickVideo,
                    onClear: () => setState(() {
                      _selectedVideo = null;
                      _selectedVideoName = null;
                    }),
                  ),
                  const SizedBox(height: 12),

                  // Material picker
                  _FilePickerTile(
                    icon: Icons.description,
                    label: 'Study Guide / Material',
                    fileName: _selectedMaterialName,
                    onPick: _pickMaterial,
                    onClear: () => setState(() {
                      _selectedMaterial = null;
                      _selectedMaterialName = null;
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Upload progress
                  if (uploadVm.isUploading) ...[
                    LinearProgressIndicator(value: uploadVm.uploadProgress),
                    const SizedBox(height: 8),
                    Text(
                      'Uploading... ${(uploadVm.uploadProgress * 100).toStringAsFixed(0)}%',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (uploadVm.errorMessage != null) ...[
                    Text(
                      uploadVm.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                  ],

                  ElevatedButton.icon(
                    onPressed: uploadVm.isUploading ? null : _submit,
                    icon: const Icon(Icons.save),
                    label: Text(
                      uploadVm.isUploading ? 'Uploading...' : 'Create Lesson',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilePickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _FilePickerTile({
    required this.icon,
    required this.label,
    this.fileName,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(fileName ?? label),
        subtitle: fileName != null
            ? Text('Tap to change')
            : Text('Tap to select'),
        trailing: fileName != null
            ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
            : const Icon(Icons.attach_file),
        onTap: onPick,
      ),
    );
  }
}

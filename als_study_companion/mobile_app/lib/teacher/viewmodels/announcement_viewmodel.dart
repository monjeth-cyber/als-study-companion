import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../repositories/announcement_repository.dart';

/// ViewModel for creating and managing announcements.
class AnnouncementViewModel extends ChangeNotifier {
  final AnnouncementRepository _repository = AnnouncementRepository();

  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAnnouncements({String? authorId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (authorId != null) {
        _announcements = await _repository.getAnnouncementsByAuthor(authorId);
      } else {
        _announcements = await _repository.getAnnouncements();
      }
    } catch (e) {
      _errorMessage = 'Failed to load announcements: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createAnnouncement(AnnouncementModel announcement) async {
    try {
      await _repository.createAnnouncement(announcement);
      _announcements.insert(0, announcement);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create announcement: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAnnouncement(String id) async {
    try {
      await _repository.deleteAnnouncement(id);
      _announcements.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete announcement: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}

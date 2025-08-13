import 'package:flutter/foundation.dart';

import '../core/utils/result.dart';
import '../models/enhanced_user_profile.dart';
import '../models/quiz_room.dart';
import '../repositories/repository_interfaces.dart';
import '../use_cases/quiz_room_use_cases.dart';

/// State management for quiz rooms
class QuizRoomProvider extends ChangeNotifier {
  final QuizRoomRepository _roomRepository;
  final UserRepository _userRepository;
  late final CreateQuizRoomUseCase _createRoomUseCase;
  late final JoinQuizRoomUseCase _joinRoomUseCase;
  late final ManageQuizRoomUseCase _manageRoomUseCase;

  QuizRoomProvider(this._roomRepository, this._userRepository) {
    _createRoomUseCase = CreateQuizRoomUseCase(_roomRepository, _userRepository);
    _joinRoomUseCase = JoinQuizRoomUseCase(_roomRepository, _userRepository);
    _manageRoomUseCase = ManageQuizRoomUseCase(_roomRepository, _userRepository);
  }

  // State
  List<QuizRoom> _rooms = [];
  QuizRoom? _selectedRoom;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<QuizRoom> get rooms => _rooms;
  QuizRoom? get selectedRoom => _selectedRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Actions

  /// Load rooms for a user
  Future<void> loadRoomsForUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _roomRepository.getRoomsForUser(userId);
      
      if (result.isSuccess) {
        _rooms = result.data!;
      } else {
        _setError(result.exception!.toString());
      }
    } catch (e) {
      _setError('Failed to load rooms: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new room
  Future<bool> createRoom({
    required String name,
    required String description,
    required String createdBy,
    required String institutionId,
    String? subject,
    String? grade,
    int maxStudents = 100,
    Map<String, dynamic> settings = const {},
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _createRoomUseCase.execute(
        name: name,
        description: description,
        createdBy: createdBy,
        institutionId: institutionId,
        subject: subject,
        grade: grade,
        maxStudents: maxStudents,
        settings: settings,
      );

      if (result.isSuccess) {
        _rooms.add(result.data!);
        notifyListeners();
        return true;
      } else {
        _setError(result.exception!.toString());
        return false;
      }
    } catch (e) {
      _setError('Failed to create room: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Join a room with invite code
  Future<bool> joinRoom({
    required String inviteCode,
    required String userId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _joinRoomUseCase.execute(
        inviteCode: inviteCode,
        userId: userId,
      );

      if (result.isSuccess) {
        final room = result.data!;
        final existingIndex = _rooms.indexWhere((r) => r.id == room.id);
        
        if (existingIndex >= 0) {
          _rooms[existingIndex] = room;
        } else {
          _rooms.add(room);
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(result.exception!.toString());
        return false;
      }
    } catch (e) {
      _setError('Failed to join room: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update a room
  Future<bool> updateRoom({
    required String roomId,
    required String userId,
    String? name,
    String? description,
    String? subject,
    String? grade,
    int? maxStudents,
    Map<String, dynamic>? settings,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _manageRoomUseCase.updateRoom(
        roomId: roomId,
        userId: userId,
        name: name,
        description: description,
        subject: subject,
        grade: grade,
        maxStudents: maxStudents,
        settings: settings,
      );

      if (result.isSuccess) {
        // Reload room data
        final roomResult = await _roomRepository.getRoom(roomId);
        if (roomResult.isSuccess && roomResult.data != null) {
          final updatedRoom = roomResult.data!;
          final index = _rooms.indexWhere((r) => r.id == roomId);
          if (index >= 0) {
            _rooms[index] = updatedRoom;
            if (_selectedRoom?.id == roomId) {
              _selectedRoom = updatedRoom;
            }
            notifyListeners();
          }
        }
        return true;
      } else {
        _setError(result.exception!.toString());
        return false;
      }
    } catch (e) {
      _setError('Failed to update room: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove a student from a room
  Future<bool> removeStudent({
    required String roomId,
    required String userId,
    required String studentId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _manageRoomUseCase.removeStudent(
        roomId: roomId,
        userId: userId,
        studentId: studentId,
      );

      if (result.isSuccess) {
        // Update local state
        final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
        if (roomIndex >= 0) {
          final room = _rooms[roomIndex];
          final updatedStudentIds = room.studentIds.where((id) => id != studentId).toList();
          _rooms[roomIndex] = room.copyWith(studentIds: updatedStudentIds);
          
          if (_selectedRoom?.id == roomId) {
            _selectedRoom = _rooms[roomIndex];
          }
          
          notifyListeners();
        }
        return true;
      } else {
        _setError(result.exception!.toString());
        return false;
      }
    } catch (e) {
      _setError('Failed to remove student: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Generate new invite code
  Future<String?> generateNewInviteCode({
    required String roomId,
    required String userId,
    Duration? validity,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _manageRoomUseCase.generateNewInviteCode(
        roomId: roomId,
        userId: userId,
        validity: validity,
      );

      if (result.isSuccess) {
        // Update local state
        final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
        if (roomIndex >= 0) {
          final roomResult = await _roomRepository.getRoom(roomId);
          if (roomResult.isSuccess && roomResult.data != null) {
            _rooms[roomIndex] = roomResult.data!;
            if (_selectedRoom?.id == roomId) {
              _selectedRoom = roomResult.data!;
            }
            notifyListeners();
          }
        }
        return result.data!;
      } else {
        _setError(result.exception!.toString());
        return null;
      }
    } catch (e) {
      _setError('Failed to generate invite code: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Select a room
  void selectRoom(QuizRoom? room) {
    _selectedRoom = room;
    notifyListeners();
  }

  /// Clear selected room
  void clearSelectedRoom() {
    _selectedRoom = null;
    notifyListeners();
  }

  /// Check if user can manage a room
  Future<bool> canManageRoom(String userId, String roomId) async {
    try {
      final result = await _roomRepository.canManageRoom(userId, roomId);
      return result.data ?? false;
    } catch (e) {
      return false;
    }
  }

  // Private methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

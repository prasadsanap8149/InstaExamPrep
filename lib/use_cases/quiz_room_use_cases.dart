import '../core/exceptions/app_exceptions.dart';
import '../core/utils/result.dart';
import '../models/enhanced_user_profile.dart';
import '../models/quiz_room.dart';
import '../repositories/repository_interfaces.dart';

/// Use case for creating a quiz room
class CreateQuizRoomUseCase {
  final QuizRoomRepository _roomRepository;
  final UserRepository _userRepository;

  CreateQuizRoomUseCase(this._roomRepository, this._userRepository);

  Future<Result<QuizRoom>> execute({
    required String name,
    required String description,
    required String createdBy,
    required String institutionId,
    String? subject,
    String? grade,
    int maxStudents = 100,
    Map<String, dynamic> settings = const {},
  }) async {
    try {
      // Validate input
      if (name.trim().isEmpty) {
        throw const ValidationException('Room name cannot be empty');
      }

      if (description.trim().isEmpty) {
        throw const ValidationException('Room description cannot be empty');
      }

      // Check if user exists and has permission to create rooms
      final userResult = await _userRepository.getUserProfile(createdBy);
      if (userResult.isFailure) {
        return Failure(userResult.exception!);
      }

      final user = userResult.data;
      if (user == null) {
        throw const AuthException('User not found');
      }

      if (!user.canManageClassrooms) {
        throw const PermissionException('User does not have permission to create rooms');
      }

      // Generate invite code
      final inviteCode = _generateInviteCode();
      final inviteCodeExpiry = DateTime.now().add(const Duration(days: 30));

      // Create room
      final room = QuizRoom(
        id: '', // Will be set by repository
        name: name.trim(),
        description: description.trim(),
        createdBy: createdBy,
        institutionId: institutionId,
        studentIds: [],
        teacherIds: [createdBy],
        createdOn: DateTime.now(),
        subject: subject?.trim(),
        grade: grade?.trim(),
        settings: settings,
        inviteCode: inviteCode,
        inviteCodeExpiry: inviteCodeExpiry,
        maxStudents: maxStudents,
      );

      return await _roomRepository.createRoom(room);
    } catch (e) {
      if (e is AppException) {
        return Failure(e);
      }
      return Failure(QuizException('Failed to create room: $e'));
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';
    
    for (int i = 0; i < 6; i++) {
      result += chars[(random + i) % chars.length];
    }
    
    return result;
  }
}

/// Use case for joining a quiz room
class JoinQuizRoomUseCase {
  final QuizRoomRepository _roomRepository;
  final UserRepository _userRepository;

  JoinQuizRoomUseCase(this._roomRepository, this._userRepository);

  Future<Result<QuizRoom>> execute({
    required String inviteCode,
    required String userId,
  }) async {
    try {
      // Validate input
      if (inviteCode.trim().isEmpty) {
        throw const ValidationException('Invite code cannot be empty');
      }

      // Check if user exists
      final userResult = await _userRepository.getUserProfile(userId);
      if (userResult.isFailure) {
        return Failure(userResult.exception!);
      }

      final user = userResult.data;
      if (user == null) {
        throw const AuthException('User not found');
      }

      // Join room
      final result = await _roomRepository.joinRoomWithInviteCode(
        inviteCode.trim().toUpperCase(), 
        userId,
      );

      if (result.isSuccess) {
        // Update user's student classrooms
        final room = result.data!;
        final updatedClassrooms = [...user.studentClassrooms];
        if (!updatedClassrooms.contains(room.id)) {
          updatedClassrooms.add(room.id);
          final updatedUser = user.copyWith(studentClassrooms: updatedClassrooms);
          await _userRepository.updateUserProfile(updatedUser);
        }
      }

      return result;
    } catch (e) {
      if (e is AppException) {
        return Failure(e);
      }
      return Failure(QuizException('Failed to join room: $e'));
    }
  }
}

/// Use case for managing quiz room
class ManageQuizRoomUseCase {
  final QuizRoomRepository _roomRepository;
  final UserRepository _userRepository;

  ManageQuizRoomUseCase(this._roomRepository, this._userRepository);

  Future<Result<void>> updateRoom({
    required String roomId,
    required String userId,
    String? name,
    String? description,
    String? subject,
    String? grade,
    int? maxStudents,
    Map<String, dynamic>? settings,
  }) async {
    try {
      // Check permission
      final permissionResult = await _roomRepository.canManageRoom(userId, roomId);
      if (permissionResult.isFailure) {
        return Failure(permissionResult.exception!);
      }

      if (!permissionResult.data!) {
        throw const PermissionException('User does not have permission to manage this room');
      }

      // Get current room
      final roomResult = await _roomRepository.getRoom(roomId);
      if (roomResult.isFailure) {
        return Failure(roomResult.exception!);
      }

      final room = roomResult.data;
      if (room == null) {
        throw const QuizException('Room not found');
      }

      // Update room
      final updatedRoom = room.copyWith(
        name: name?.trim() ?? room.name,
        description: description?.trim() ?? room.description,
        subject: subject?.trim() ?? room.subject,
        grade: grade?.trim() ?? room.grade,
        maxStudents: maxStudents ?? room.maxStudents,
        settings: settings ?? room.settings,
      );

      return await _roomRepository.updateRoom(updatedRoom);
    } catch (e) {
      if (e is AppException) {
        return Failure(e);
      }
      return Failure(QuizException('Failed to update room: $e'));
    }
  }

  Future<Result<void>> removeStudent({
    required String roomId,
    required String userId,
    required String studentId,
  }) async {
    try {
      // Check permission
      final permissionResult = await _roomRepository.canManageRoom(userId, roomId);
      if (permissionResult.isFailure) {
        return Failure(permissionResult.exception!);
      }

      if (!permissionResult.data!) {
        throw const PermissionException('User does not have permission to manage this room');
      }

      // Get current room
      final roomResult = await _roomRepository.getRoom(roomId);
      if (roomResult.isFailure) {
        return Failure(roomResult.exception!);
      }

      final room = roomResult.data;
      if (room == null) {
        throw const QuizException('Room not found');
      }

      // Remove student
      final updatedStudentIds = room.studentIds.where((id) => id != studentId).toList();
      final updatedRoom = room.copyWith(studentIds: updatedStudentIds);

      final updateResult = await _roomRepository.updateRoom(updatedRoom);
      if (updateResult.isFailure) {
        return updateResult;
      }

      // Update user's student classrooms
      final userResult = await _userRepository.getUserProfile(studentId);
      if (userResult.isSuccess && userResult.data != null) {
        final user = userResult.data!;
        final updatedClassrooms = user.studentClassrooms.where((id) => id != roomId).toList();
        final updatedUser = user.copyWith(studentClassrooms: updatedClassrooms);
        await _userRepository.updateUserProfile(updatedUser);
      }

      return const Success(null);
    } catch (e) {
      if (e is AppException) {
        return Failure(e);
      }
      return Failure(QuizException('Failed to remove student: $e'));
    }
  }

  Future<Result<String>> generateNewInviteCode({
    required String roomId,
    required String userId,
    Duration? validity,
  }) async {
    try {
      // Check permission
      final permissionResult = await _roomRepository.canManageRoom(userId, roomId);
      if (permissionResult.isFailure) {
        return Failure(permissionResult.exception!);
      }

      if (!permissionResult.data!) {
        throw const PermissionException('User does not have permission to manage this room');
      }

      // Get current room
      final roomResult = await _roomRepository.getRoom(roomId);
      if (roomResult.isFailure) {
        return Failure(roomResult.exception!);
      }

      final room = roomResult.data;
      if (room == null) {
        throw const QuizException('Room not found');
      }

      // Generate new invite code
      final newInviteCode = _generateInviteCode();
      final expiry = validity != null 
          ? DateTime.now().add(validity) 
          : DateTime.now().add(const Duration(days: 30));

      final updatedRoom = room.copyWith(
        inviteCode: newInviteCode,
        inviteCodeExpiry: expiry,
      );

      final updateResult = await _roomRepository.updateRoom(updatedRoom);
      if (updateResult.isFailure) {
        return Failure(updateResult.exception!);
      }

      return Success(newInviteCode);
    } catch (e) {
      if (e is AppException) {
        return Failure(e);
      }
      return Failure(QuizException('Failed to generate invite code: $e'));
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';
    
    for (int i = 0; i < 6; i++) {
      result += chars[(random + i) % chars.length];
    }
    
    return result;
  }
}

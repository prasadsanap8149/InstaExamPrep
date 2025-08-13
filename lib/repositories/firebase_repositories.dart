import '../core/utils/result.dart';
import '../models/enhanced_quiz.dart';
import '../models/enhanced_user_profile.dart';
import '../models/quiz_room.dart';
import '../services/enhanced_firebase_service.dart';
import 'repository_interfaces.dart';

/// Firebase implementation of QuizRoomRepository
class FirebaseQuizRoomRepository implements QuizRoomRepository {
  final EnhancedFirebaseService _firebaseService;

  FirebaseQuizRoomRepository(this._firebaseService);

  @override
  Future<Result<QuizRoom>> createRoom(QuizRoom room) async {
    return await _firebaseService.createQuizRoom(room);
  }

  @override
  Future<Result<QuizRoom?>> getRoom(String roomId) async {
    return await _firebaseService.getQuizRoom(roomId);
  }

  @override
  Future<Result<List<QuizRoom>>> getRoomsForUser(String userId) async {
    return await _firebaseService.getRoomsForUser(userId);
  }

  @override
  Future<Result<QuizRoom>> joinRoomWithInviteCode(String inviteCode, String userId) async {
    return await _firebaseService.joinRoomWithInviteCode(inviteCode, userId);
  }

  @override
  Future<Result<void>> updateRoom(QuizRoom room) async {
    return await _firebaseService.updateQuizRoom(room);
  }

  @override
  Future<Result<void>> deleteRoom(String roomId) async {
    try {
      final roomResult = await getRoom(roomId);
      if (roomResult.isFailure) {
        return Failure(roomResult.exception!);
      }

      final room = roomResult.data;
      if (room == null) {
        return const Success(null);
      }

      final updatedRoom = room.copyWith(status: RoomStatus.archived);
      return await updateRoom(updatedRoom);
    } catch (e) {
      return Failure(Exception('Failed to delete room: $e'));
    }
  }

  @override
  Future<Result<bool>> hasRoomPermission(String userId, String roomId) async {
    return await _firebaseService.hasRoomPermission(userId, roomId);
  }

  @override
  Future<Result<bool>> canManageRoom(String userId, String roomId) async {
    return await _firebaseService.canManageRoom(userId, roomId);
  }

  @override
  Stream<List<QuizRoom>> streamRoomsForUser(String userId) {
    return _firebaseService.streamRoomsForUser(userId);
  }

  @override
  Stream<QuizRoom?> streamRoom(String roomId) {
    return _firebaseService.streamUserProfile(roomId).map((profile) => null);
    // TODO: Implement proper room streaming
  }
}

/// Firebase implementation of QuizRepository
class FirebaseQuizRepository implements QuizRepository {
  final EnhancedFirebaseService _firebaseService;

  FirebaseQuizRepository(this._firebaseService);

  @override
  Future<Result<EnhancedQuiz>> createQuiz(EnhancedQuiz quiz) async {
    return await _firebaseService.createQuiz(quiz);
  }

  @override
  Future<Result<EnhancedQuiz?>> getQuiz(String quizId) async {
    return await _firebaseService.getQuiz(quizId);
  }

  @override
  Future<Result<List<EnhancedQuiz>>> getQuizzesForRoom(String roomId) async {
    return await _firebaseService.getQuizzesForRoom(roomId);
  }

  @override
  Future<Result<List<EnhancedQuiz>>> getQuizzesForUser(String userId) async {
    // TODO: Implement getting quizzes for user
    return const Success([]);
  }

  @override
  Future<Result<void>> updateQuiz(EnhancedQuiz quiz) async {
    return await _firebaseService.updateQuiz(quiz);
  }

  @override
  Future<Result<void>> deleteQuiz(String quizId) async {
    try {
      final quizResult = await getQuiz(quizId);
      if (quizResult.isFailure) {
        return Failure(quizResult.exception!);
      }

      final quiz = quizResult.data;
      if (quiz == null) {
        return const Success(null);
      }

      final updatedQuiz = quiz.copyWith(status: QuizStatus.archived);
      return await updateQuiz(updatedQuiz);
    } catch (e) {
      return Failure(Exception('Failed to delete quiz: $e'));
    }
  }

  @override
  Stream<List<EnhancedQuiz>> streamQuizzesForRoom(String roomId) {
    return _firebaseService.streamQuizzesForRoom(roomId);
  }

  @override
  Stream<EnhancedQuiz?> streamQuiz(String quizId) {
    // TODO: Implement proper quiz streaming
    return Stream.value(null);
  }
}

/// Firebase implementation of UserRepository
class FirebaseUserRepository implements UserRepository {
  final EnhancedFirebaseService _firebaseService;

  FirebaseUserRepository(this._firebaseService);

  @override
  Future<Result<void>> createUserProfile(UserProfile profile) async {
    return await _firebaseService.createUserProfile(profile);
  }

  @override
  Future<Result<UserProfile?>> getUserProfile(String userId) async {
    return await _firebaseService.getUserProfile(userId);
  }

  @override
  Future<Result<void>> updateUserProfile(UserProfile profile) async {
    return await _firebaseService.updateUserProfile(profile);
  }

  @override
  Future<Result<List<UserProfile>>> getUsersInRoom(String roomId) async {
    // TODO: Implement getting users in room
    return const Success([]);
  }

  @override
  Stream<UserProfile?> streamUserProfile(String userId) {
    return _firebaseService.streamUserProfile(userId);
  }
}

/// Firebase implementation of AuthRepository
class FirebaseAuthRepository implements AuthRepository {
  final EnhancedFirebaseService _firebaseService;

  FirebaseAuthRepository(this._firebaseService);

  @override
  Future<Result<String>> signUp(String email, String password) async {
    final result = await _firebaseService.signUpWithEmailAndPassword(email, password);
    
    if (result.isSuccess) {
      final userId = result.data!.user?.uid;
      if (userId != null) {
        return Success(userId);
      } else {
        return Failure(Exception('Failed to get user ID after signup'));
      }
    } else {
      return Failure(result.exception!);
    }
  }

  @override
  Future<Result<String>> signIn(String email, String password) async {
    final result = await _firebaseService.signInWithEmailAndPassword(email, password);
    
    if (result.isSuccess) {
      final userId = result.data!.user?.uid;
      if (userId != null) {
        return Success(userId);
      } else {
        return Failure(Exception('Failed to get user ID after signin'));
      }
    } else {
      return Failure(result.exception!);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    return await _firebaseService.signOut();
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    return await _firebaseService.resetPassword(email);
  }

  @override
  Future<Result<String?>> getCurrentUserId() async {
    try {
      final userId = _firebaseService.currentUser?.uid;
      return Success(userId);
    } catch (e) {
      return Failure(Exception('Failed to get current user ID: $e'));
    }
  }

  @override
  Stream<String?> streamAuthState() {
    return _firebaseService._auth.authStateChanges().map((user) => user?.uid);
  }
}

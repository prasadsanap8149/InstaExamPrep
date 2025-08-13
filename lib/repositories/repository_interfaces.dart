import '../core/utils/result.dart';
import '../models/enhanced_quiz.dart';
import '../models/enhanced_user_profile.dart';
import '../models/quiz_room.dart';

/// Abstract repository interface for quiz rooms
abstract class QuizRoomRepository {
  Future<Result<QuizRoom>> createRoom(QuizRoom room);
  Future<Result<QuizRoom?>> getRoom(String roomId);
  Future<Result<List<QuizRoom>>> getRoomsForUser(String userId);
  Future<Result<QuizRoom>> joinRoomWithInviteCode(String inviteCode, String userId);
  Future<Result<void>> updateRoom(QuizRoom room);
  Future<Result<void>> deleteRoom(String roomId);
  Future<Result<bool>> hasRoomPermission(String userId, String roomId);
  Future<Result<bool>> canManageRoom(String userId, String roomId);
  Stream<List<QuizRoom>> streamRoomsForUser(String userId);
  Stream<QuizRoom?> streamRoom(String roomId);
}

/// Abstract repository interface for quizzes
abstract class QuizRepository {
  Future<Result<EnhancedQuiz>> createQuiz(EnhancedQuiz quiz);
  Future<Result<EnhancedQuiz?>> getQuiz(String quizId);
  Future<Result<List<EnhancedQuiz>>> getQuizzesForRoom(String roomId);
  Future<Result<List<EnhancedQuiz>>> getQuizzesForUser(String userId);
  Future<Result<void>> updateQuiz(EnhancedQuiz quiz);
  Future<Result<void>> deleteQuiz(String quizId);
  Stream<List<EnhancedQuiz>> streamQuizzesForRoom(String roomId);
  Stream<EnhancedQuiz?> streamQuiz(String quizId);
}

/// Abstract repository interface for users
abstract class UserRepository {
  Future<Result<void>> createUserProfile(UserProfile profile);
  Future<Result<UserProfile?>> getUserProfile(String userId);
  Future<Result<void>> updateUserProfile(UserProfile profile);
  Future<Result<List<UserProfile>>> getUsersInRoom(String roomId);
  Stream<UserProfile?> streamUserProfile(String userId);
}

/// Abstract repository interface for authentication
abstract class AuthRepository {
  Future<Result<String>> signUp(String email, String password);
  Future<Result<String>> signIn(String email, String password);
  Future<Result<void>> signOut();
  Future<Result<void>> resetPassword(String email);
  Future<Result<String?>> getCurrentUserId();
  Stream<String?> streamAuthState();
}

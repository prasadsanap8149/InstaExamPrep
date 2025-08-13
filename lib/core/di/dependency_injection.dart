import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/quiz_room_provider.dart';
import '../repositories/firebase_repositories.dart';
import '../repositories/repository_interfaces.dart';
import '../services/enhanced_firebase_service.dart';

/// Dependency injection setup for the application
class DependencyInjection {
  static final EnhancedFirebaseService _firebaseService = EnhancedFirebaseService();

  // Repositories
  static final QuizRoomRepository _quizRoomRepository = 
      FirebaseQuizRoomRepository(_firebaseService);
  static final QuizRepository _quizRepository = 
      FirebaseQuizRepository(_firebaseService);
  static final UserRepository _userRepository = 
      FirebaseUserRepository(_firebaseService);
  static final AuthRepository _authRepository = 
      FirebaseAuthRepository(_firebaseService);

  /// Get all providers for the application
  static List<SingleChildWidget> getProviders() {
    return [
      // Services
      Provider<EnhancedFirebaseService>.value(value: _firebaseService),

      // Repositories
      Provider<QuizRoomRepository>.value(value: _quizRoomRepository),
      Provider<QuizRepository>.value(value: _quizRepository),
      Provider<UserRepository>.value(value: _userRepository),
      Provider<AuthRepository>.value(value: _authRepository),

      // Providers/State Management
      ChangeNotifierProvider<QuizRoomProvider>(
        create: (context) => QuizRoomProvider(_quizRoomRepository, _userRepository),
      ),

      // Add more providers as needed
    ];
  }

  /// Get individual repositories (for testing or specific use cases)
  static QuizRoomRepository get quizRoomRepository => _quizRoomRepository;
  static QuizRepository get quizRepository => _quizRepository;
  static UserRepository get userRepository => _userRepository;
  static AuthRepository get authRepository => _authRepository;
  static EnhancedFirebaseService get firebaseService => _firebaseService;
}

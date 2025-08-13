import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/error/error_handler.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/utils/result.dart';
import '../models/enhanced_quiz.dart';
import '../models/enhanced_user_profile.dart';
import '../models/quiz_room.dart';

/// Enhanced Firebase service with comprehensive error handling and room support
class EnhancedFirebaseService {
  static final EnhancedFirebaseService _instance = EnhancedFirebaseService._internal();
  factory EnhancedFirebaseService() => _instance;
  EnhancedFirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _usersCollection = 'users';
  static const String _quizzesCollection = 'quizzes';
  static const String _roomsCollection = 'quiz_rooms';
  static const String _questionsCollection = 'questions';
  static const String _attemptsCollection = 'quiz_attempts';

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Auth Methods
  
  /// Sign up with email and password
  Future<Result<UserCredential>> signUpWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(credential);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'signUpWithEmailAndPassword');
      return Failure(exception);
    }
  }

  /// Sign in with email and password
  Future<Result<UserCredential>> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(credential);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'signInWithEmailAndPassword');
      return Failure(exception);
    }
  }

  /// Sign out
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'signOut');
      return Failure(exception);
    }
  }

  /// Reset password
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Success(null);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'resetPassword');
      return Failure(exception);
    }
  }

  // User Profile Methods

  /// Create user profile
  Future<Result<void>> createUserProfile(UserProfile profile) async {
    try {
      if (profile.id == null) {
        throw const ValidationException('User ID cannot be null');
      }

      await _firestore
          .collection(_usersCollection)
          .doc(profile.id)
          .set(profile.toMap());

      return const Success(null);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'createUserProfile');
      return Failure(exception);
    }
  }

  /// Get user profile
  Future<Result<UserProfile?>> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return const Success(null);
      }

      final profile = UserProfile.fromFirestore(doc);
      return Success(profile);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'getUserProfile');
      return Failure(exception);
    }
  }

  /// Update user profile
  Future<Result<void>> updateUserProfile(UserProfile profile) async {
    try {
      if (profile.id == null) {
        throw const ValidationException('User ID cannot be null');
      }

      final updatedProfile = profile.copyWith(updatedOn: DateTime.now());
      
      await _firestore
          .collection(_usersCollection)
          .doc(profile.id)
          .update(updatedProfile.toMap());

      return const Success(null);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'updateUserProfile');
      return Failure(exception);
    }
  }

  // Quiz Room Methods

  /// Create quiz room
  Future<Result<QuizRoom>> createQuizRoom(QuizRoom room) async {
    try {
      final docRef = await _firestore
          .collection(_roomsCollection)
          .add(room.toMap());

      final createdRoom = room.copyWith(id: docRef.id);
      
      // Update the document with the generated ID
      await docRef.update({'id': docRef.id});

      return Success(createdRoom);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'createQuizRoom');
      return Failure(exception);
    }
  }

  /// Get quiz room
  Future<Result<QuizRoom?>> getQuizRoom(String roomId) async {
    try {
      final doc = await _firestore
          .collection(_roomsCollection)
          .doc(roomId)
          .get();

      if (!doc.exists) {
        return const Success(null);
      }

      final room = QuizRoom.fromFirestore(doc);
      return Success(room);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'getQuizRoom');
      return Failure(exception);
    }
  }

  /// Get rooms for user
  Future<Result<List<QuizRoom>>> getRoomsForUser(String userId) async {
    try {
      final query = await _firestore
          .collection(_roomsCollection)
          .where('status', isEqualTo: RoomStatus.active.name)
          .where('studentIds', arrayContains: userId)
          .get();

      final adminQuery = await _firestore
          .collection(_roomsCollection)
          .where('status', isEqualTo: RoomStatus.active.name)
          .where('createdBy', isEqualTo: userId)
          .get();

      final teacherQuery = await _firestore
          .collection(_roomsCollection)
          .where('status', isEqualTo: RoomStatus.active.name)
          .where('teacherIds', arrayContains: userId)
          .get();

      final allDocs = <QueryDocumentSnapshot>[];
      allDocs.addAll(query.docs);
      allDocs.addAll(adminQuery.docs);
      allDocs.addAll(teacherQuery.docs);

      // Remove duplicates
      final uniqueDocs = <String, QueryDocumentSnapshot>{};
      for (final doc in allDocs) {
        uniqueDocs[doc.id] = doc;
      }

      final rooms = uniqueDocs.values
          .map((doc) => QuizRoom.fromFirestore(doc))
          .toList();

      return Success(rooms);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'getRoomsForUser');
      return Failure(exception);
    }
  }

  /// Join room with invite code
  Future<Result<QuizRoom>> joinRoomWithInviteCode(
    String inviteCode, 
    String userId,
  ) async {
    try {
      final query = await _firestore
          .collection(_roomsCollection)
          .where('inviteCode', isEqualTo: inviteCode)
          .where('status', isEqualTo: RoomStatus.active.name)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw const QuizException('Invalid invite code');
      }

      final roomDoc = query.docs.first;
      final room = QuizRoom.fromFirestore(roomDoc);

      if (!room.hasValidInviteCode) {
        throw const QuizException('Invite code has expired');
      }

      if (!room.hasSpace) {
        throw const QuizException('Room is full');
      }

      if (room.studentIds.contains(userId)) {
        return Success(room); // Already a member
      }

      // Add user to room
      final updatedStudentIds = [...room.studentIds, userId];
      await _firestore
          .collection(_roomsCollection)
          .doc(room.id)
          .update({
        'studentIds': updatedStudentIds,
        'updatedOn': DateTime.now().toIso8601String(),
      });

      final updatedRoom = room.copyWith(
        studentIds: updatedStudentIds,
        updatedOn: DateTime.now(),
      );

      return Success(updatedRoom);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'joinRoomWithInviteCode');
      return Failure(exception);
    }
  }

  /// Update room
  Future<Result<void>> updateQuizRoom(QuizRoom room) async {
    try {
      final updatedRoom = room.copyWith(updatedOn: DateTime.now());
      
      await _firestore
          .collection(_roomsCollection)
          .doc(room.id)
          .update(updatedRoom.toMap());

      return const Success(null);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'updateQuizRoom');
      return Failure(exception);
    }
  }

  // Quiz Methods

  /// Create quiz
  Future<Result<EnhancedQuiz>> createQuiz(EnhancedQuiz quiz) async {
    try {
      final docRef = await _firestore
          .collection(_quizzesCollection)
          .add(quiz.toMap());

      final createdQuiz = quiz.copyWith(id: docRef.id);
      
      // Update the document with the generated ID
      await docRef.update({'id': docRef.id});

      return Success(createdQuiz);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'createQuiz');
      return Failure(exception);
    }
  }

  /// Get quiz
  Future<Result<EnhancedQuiz?>> getQuiz(String quizId) async {
    try {
      final doc = await _firestore
          .collection(_quizzesCollection)
          .doc(quizId)
          .get();

      if (!doc.exists) {
        return const Success(null);
      }

      final quiz = EnhancedQuiz.fromFirestore(doc);
      return Success(quiz);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'getQuiz');
      return Failure(exception);
    }
  }

  /// Get quizzes for room
  Future<Result<List<EnhancedQuiz>>> getQuizzesForRoom(String roomId) async {
    try {
      final query = await _firestore
          .collection(_quizzesCollection)
          .where('roomId', isEqualTo: roomId)
          .where('status', whereIn: [QuizStatus.published.name, QuizStatus.active.name])
          .orderBy('createdOn', descending: true)
          .get();

      final allowedRoomsQuery = await _firestore
          .collection(_quizzesCollection)
          .where('allowedRooms', arrayContains: roomId)
          .where('status', whereIn: [QuizStatus.published.name, QuizStatus.active.name])
          .orderBy('createdOn', descending: true)
          .get();

      final allDocs = <QueryDocumentSnapshot>[];
      allDocs.addAll(query.docs);
      allDocs.addAll(allowedRoomsQuery.docs);

      // Remove duplicates
      final uniqueDocs = <String, QueryDocumentSnapshot>{};
      for (final doc in allDocs) {
        uniqueDocs[doc.id] = doc;
      }

      final quizzes = uniqueDocs.values
          .map((doc) => EnhancedQuiz.fromFirestore(doc))
          .toList();

      return Success(quizzes);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'getQuizzesForRoom');
      return Failure(exception);
    }
  }

  /// Update quiz
  Future<Result<void>> updateQuiz(EnhancedQuiz quiz) async {
    try {
      final updatedQuiz = quiz.copyWith(updatedOn: DateTime.now());
      
      await _firestore
          .collection(_quizzesCollection)
          .doc(quiz.id)
          .update(updatedQuiz.toMap());

      return const Success(null);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'updateQuiz');
      return Failure(exception);
    }
  }

  // Stream Methods for Real-time Updates

  /// Stream user profile
  Stream<UserProfile?> streamUserProfile(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      try {
        if (!snapshot.exists) return null;
        return UserProfile.fromFirestore(snapshot);
      } catch (e) {
        ErrorHandler.logError(e, context: 'streamUserProfile');
        return null;
      }
    });
  }

  /// Stream rooms for user
  Stream<List<QuizRoom>> streamRoomsForUser(String userId) {
    return _firestore
        .collection(_roomsCollection)
        .where('status', isEqualTo: RoomStatus.active.name)
        .snapshots()
        .map((snapshot) {
      try {
        final rooms = <QuizRoom>[];
        
        for (final doc in snapshot.docs) {
          final room = QuizRoom.fromFirestore(doc);
          if (room.studentIds.contains(userId) ||
              room.teacherIds.contains(userId) ||
              room.createdBy == userId) {
            rooms.add(room);
          }
        }
        
        return rooms;
      } catch (e) {
        ErrorHandler.logError(e, context: 'streamRoomsForUser');
        return <QuizRoom>[];
      }
    });
  }

  /// Stream quizzes for room
  Stream<List<EnhancedQuiz>> streamQuizzesForRoom(String roomId) {
    return _firestore
        .collection(_quizzesCollection)
        .where('roomId', isEqualTo: roomId)
        .where('status', whereIn: [QuizStatus.published.name, QuizStatus.active.name])
        .orderBy('createdOn', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => EnhancedQuiz.fromFirestore(doc))
            .toList();
      } catch (e) {
        ErrorHandler.logError(e, context: 'streamQuizzesForRoom');
        return <EnhancedQuiz>[];
      }
    });
  }

  // Utility Methods

  /// Generate unique invite code
  String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';
    
    for (int i = 0; i < 6; i++) {
      result += chars[(random + i) % chars.length];
    }
    
    return result;
  }

  /// Check if user has permission to access room
  Future<Result<bool>> hasRoomPermission(String userId, String roomId) async {
    try {
      final roomResult = await getQuizRoom(roomId);
      
      if (roomResult.isFailure) {
        return Failure(roomResult.exception!);
      }

      final room = roomResult.data;
      if (room == null) {
        return const Success(false);
      }

      final hasPermission = room.studentIds.contains(userId) ||
                           room.teacherIds.contains(userId) ||
                           room.createdBy == userId;

      return Success(hasPermission);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'hasRoomPermission');
      return Failure(exception);
    }
  }

  /// Check if user can manage room
  Future<Result<bool>> canManageRoom(String userId, String roomId) async {
    try {
      final roomResult = await getQuizRoom(roomId);
      
      if (roomResult.isFailure) {
        return Failure(roomResult.exception!);
      }

      final room = roomResult.data;
      if (room == null) {
        return const Success(false);
      }

      final canManage = room.teacherIds.contains(userId) ||
                       room.createdBy == userId;

      return Success(canManage);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(e, context: 'canManageRoom');
      return Failure(exception);
    }
  }
}

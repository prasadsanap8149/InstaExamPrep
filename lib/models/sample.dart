// models.dart
import 'package:flutter/material.dart';

// User Model
class User {
  final String? id;
  final String name;
  final String email;
  final Set<String> selectedTopics;
  final String preferredLanguage;
  final int points;
  final int streak;
  final SubscriptionPlan subscriptionPlan;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.selectedTopics,
    required this.preferredLanguage,
    required this.points,
    required this.streak,
    required this.subscriptionPlan,
  });
}

// Subscription Plan Model
class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final List<String> features;
  final bool isPremium;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    this.isPremium = false,
  });
}

// Quiz Model
class Quiz {
  final String id;
  final String title;
  final List<Question> questions;
  final String categoryId;
  final QuizType type;
  final bool isDownloaded;
  final int difficultyLevel;

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
    required this.categoryId,
    required this.type,
    this.isDownloaded = false,
    this.difficultyLevel = 1,
  });
}

enum QuizType { mockTest, topicWise, timed }

// Question Model
class Question {
  final String id;
  final String content;
  final List<AnswerOption> options;
  final String explanation;
  final String correctOptionId;
  final int difficultyLevel;

  Question({
    required this.id,
    required this.content,
    required this.options,
    required this.explanation,
    required this.correctOptionId,
    this.difficultyLevel = 1,
  });
}

// Answer Option Model
class AnswerOption {
  final String id;
  final String content;
  final bool isCorrect;

  AnswerOption({
    required this.id,
    required this.content,
    this.isCorrect = false,
  });
}

// Category Model
class Category {
  final String id;
  final String name;
  final List<String> subCategories;
  final List<Quiz> quizzes;

  Category({
    required this.id,
    required this.name,
    required this.subCategories,
    required this.quizzes,
  });
}

// Performance Model
class Performance {
  final String quizId;
  final DateTime completedOn;
  final int score;
  final double speed;
  final double accuracy;
  final List<WeakTopic> weakTopics;

  Performance({
    required this.quizId,
    required this.completedOn,
    required this.score,
    required this.speed,
    required this.accuracy,
    required this.weakTopics,
  });
}

class WeakTopic {
  final String topicName;
  final int incorrectAnswers;

  WeakTopic({
    required this.topicName,
    required this.incorrectAnswers,
  });
}

// Gamification Model
class Reward {
  final String id;
  final String type; // points, badge, streak
  final int amount;
  final String description;

  Reward({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
  });
}

// Social and Community Model
class CommunityFeature {
  final String id;
  final String featureName;
  final String description;
  final List<User> users;
  final List<String> leaderboards;

  CommunityFeature({
    required this.id,
    required this.featureName,
    required this.description,
    required this.users,
    required this.leaderboards,
  });
}

// Business Feature Models

// Partnered Content
class PartneredContent {
  final String partnerId;
  final String contentId;
  final String title;
  final String description;
  final List<String> quizzes;

  PartneredContent({
    required this.partnerId,
    required this.contentId,
    required this.title,
    required this.description,
    required this.quizzes,
  });
}

// Push Notification Model
class PushNotification {
  final String id;
  final String title;
  final String body;
  final DateTime sentOn;
  final List<String> targetedUserIds;

  PushNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.sentOn,
    required this.targetedUserIds,
  });
}

// Admin Dashboard Model
class AdminDashboard {
  final List<Category> categories;
  final List<Quiz> quizzes;
  final List<Promotion> promotions;
  final List<User> users;

  AdminDashboard({
    required this.categories,
    required this.quizzes,
    required this.promotions,
    required this.users,
  });
}

// Promotion Model
class Promotion {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final bool isSeasonal;

  Promotion({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.isSeasonal = false,
  });
}

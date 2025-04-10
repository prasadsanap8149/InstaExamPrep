import 'package:smartexamprep/models/subscription_plan.dart';


class UserProfile {
  final String? id;
  final String name;
  final String email;
  final String mobile;
  final Set<String> selectedTopics;
  final String preferredLanguage;
  final DateTime createdOn;
  final DateTime? updatedOn;
  final int? points;
  final int? streak;
  final SubscriptionPlan? subscriptionPlan;
  final String userRole;
  final String? gender;

  UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.selectedTopics,
    required this.preferredLanguage,
    required this.mobile,
    required this.createdOn,
    this.points,
    this.streak,
    this.subscriptionPlan,
    this.updatedOn,
    required this.userRole,
    this.gender,
  });

  // Method to convert UserProfile to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'selectedTopics': selectedTopics.toList(), // Convert Set to List
      'preferredLanguage': preferredLanguage,
      'createdOn': createdOn.toIso8601String(),
      'updatedOn': updatedOn?.toIso8601String(),
      'points': points,
      'streak': streak,
      'userRole': userRole,
      'gender': gender,
      'subscriptionPlan': subscriptionPlan?.toString(), // Convert enum to string if applicable
    };
  }

  // Convert UserProfile to JSON
  Map<String, dynamic> toJson() => toMap();

  // Factory method to create a UserProfile from a map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String?,
      name: map['name'] as String,
      email: map['email'] as String,
      mobile: map['mobile'] as String,
      selectedTopics: (map['selectedTopics'] as List<dynamic>).cast<String>().toSet(),
      preferredLanguage: map['preferredLanguage'] as String,
      createdOn: DateTime.parse(map['createdOn'] as String),
      updatedOn: map['updatedOn'] != null ? DateTime.parse(map['updatedOn'] as String) : null,
      points: map['points'] as int?,
      streak: map['streak'] as int?,
      userRole: map['userRole'] as String,
      subscriptionPlan: map['subscriptionPlan'],
      gender: map['gender'] as String?,
    );
  }

  // Convert JSON to UserProfile
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile.fromMap(json);

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, mobile: $mobile, '
        'selectedTopics: $selectedTopics, preferredLanguage: $preferredLanguage, '
        'createdOn: $createdOn, updatedOn: $updatedOn, points: $points, gender:$gender,'
        'streak: $streak, userRole: $userRole, subscriptionPlan: $subscriptionPlan)';
  }
}


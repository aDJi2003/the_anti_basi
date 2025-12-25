import 'package:cloud_firestore/cloud_firestore.dart';

/// User preferences model
class UserPreferences {
  const UserPreferences({
    this.cookingSkill = 'beginner',
    this.dietaryRestrictions = const [],
    this.notificationEnabled = true,
  });

  final String cookingSkill;
  final List<String> dietaryRestrictions;
  final bool notificationEnabled;

  /// Display name for cooking skill
  String get cookingSkillDisplay {
    return switch (cookingSkill.toLowerCase()) {
      'beginner' => 'Beginner Chef',
      'intermediate' => 'Home Cook',
      'advanced' => 'Expert Chef',
      _ => 'Beginner Chef',
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const UserPreferences();

    return UserPreferences(
      cookingSkill: data['cookingSkill'] as String? ?? 'beginner',
      dietaryRestrictions: (data['dietaryRestrictions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      notificationEnabled: data['notificationEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cookingSkill': cookingSkill,
      'dietaryRestrictions': dietaryRestrictions,
      'notificationEnabled': notificationEnabled,
    };
  }

  UserPreferences copyWith({
    String? cookingSkill,
    List<String>? dietaryRestrictions,
    bool? notificationEnabled,
  }) {
    return UserPreferences(
      cookingSkill: cookingSkill ?? this.cookingSkill,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }
}

/// User profile model - matches Firestore schema
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
    this.createdAt,
    this.preferences = const UserPreferences(),
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;
  final DateTime? createdAt;
  final UserPreferences preferences;

  /// Get first name for greeting
  String get firstName {
    final parts = displayName.split(' ');
    return parts.isNotEmpty ? parts.first : displayName;
  }

  /// Create UserProfile from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile.fromMap(data, doc.id);
  }

  /// Create UserProfile from Map
  factory UserProfile.fromMap(Map<String, dynamic> data, String docId) {
    DateTime? createdAt;
    final createdAtData = data['createdAt'];
    if (createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else if (createdAtData is String) {
      createdAt = DateTime.tryParse(createdAtData);
    }

    return UserProfile(
      uid: data['uid'] as String? ?? docId,
      displayName: data['displayName'] as String? ?? 'User',
      email: data['email'] as String? ?? '',
      photoURL: data['photoURL'] as String?,
      createdAt: createdAt,
      preferences: UserPreferences.fromMap(
        data['preferences'] as Map<String, dynamic>?,
      ),
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'preferences': preferences.toMap(),
    };
  }

  /// Copy with method
  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
    DateTime? createdAt,
    UserPreferences? preferences,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, displayName: $displayName, email: $email)';
  }
}

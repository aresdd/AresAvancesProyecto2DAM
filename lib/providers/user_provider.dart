import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';

/// User profile state (in-memory only).
class UserNotifier extends StateNotifier<UserProfile?> {
  UserNotifier() : super(null);

  bool get isRegistered => state != null;

  void setUser(UserProfile user) {
    state = user;
  }

  void update(UserProfile user) {
    state = user;
  }

  void reset() {
    state = null;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserProfile?>((ref) {
  return UserNotifier();
});


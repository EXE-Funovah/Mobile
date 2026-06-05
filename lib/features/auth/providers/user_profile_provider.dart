import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/api/user_api.dart';

/// Lấy `GET /api/User/me`. Invalidate sau khi update profile.
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  return UserApi.instance.getMe();
});

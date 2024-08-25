import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/m_friendDetail.dart';
import 'ApiResponse.dart';

class FriendDetailAPI {
  static const String baseUrl = 'https://your-api-url.com/api/friend-detail-page/';

  // Fetch friend detail data
  Future<ApiResponse> fetchFriendDetail(int userId, int friendUserId, String season) async {
    final Uri uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'user_id': userId.toString(),
        'friend_user_id': friendUserId.toString(),
        'season': season,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.success(FriendDetailModel.fromJson(data));
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }

  // Create or update friends talk
  Future<ApiResponse> createOrUpdateFriendsTalk(body) async {

    final response = await http.post(
      Uri.parse('$baseUrl/create-or-update-friends-talk/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }

  // Report a friends talk
  Future<ApiResponse> reportFriendsTalk(body) async {

    final response = await http.post(
      Uri.parse('$baseUrl/report-friends-talk/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> blockUser(body) async {

    final response = await http.post(
      Uri.parse('https://snowlive-api-0eab29705c9f.herokuapp.com/api/community/block/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }

  // Fetch friends talk list
  Future<ApiResponse> fetchFriendsTalkList(int userId, int friendUserId) async {
    final Uri uri = Uri.parse('$baseUrl/friends-talk-list/').replace(
      queryParameters: {
        'user_id': userId.toString(),
        'friend_user_id': friendUserId.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }

  // Delete a friends talk
  Future<ApiResponse> deleteFriendsTalk(int userId, int friendsTalkId) async {
    final Uri uri = Uri.parse('$baseUrl/friends-talk-delete/').replace(
      queryParameters: {
        'user_id': userId.toString(),
        'friends_talk_id': friendsTalkId.toString(),
      },
    );

    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }

  // Update user profile
  Future<ApiResponse> updateUser(body) async {

    final response = await http.put(
      Uri.parse('$baseUrl/update-user/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }
}
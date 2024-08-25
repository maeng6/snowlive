import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class FriendAPI {
  static const String baseUrl = 'https://your-api-url.com/api/friend/';

  // Add a friend request
  Future<ApiResponse> addFriend(body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add-friend/'),
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

  // Delete a friend
  Future<ApiResponse> deleteFriend(body) async {

    final response = await http.post(
      Uri.parse('$baseUrl/delete-friend/'),
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

  // Accept a friend request
  Future<ApiResponse> acceptFriend(body) async {

    final response = await http.post(
      Uri.parse('$baseUrl/accept-friend/'),
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

  Future<ApiResponse> checkFriendRelationship(body) async {

    final response = await http.post(
      Uri.parse('$baseUrl/check-friend-relationship/'),
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

  // Toggle best friend status
  Future<ApiResponse> toggleBestFriend(body) async {

    final response = await http.post(
      Uri.parse('$baseUrl/best-friend/'),
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

  // Fetch friend requests
  Future<ApiResponse> fetchFriendRequests({int? sendUserId, int? receiveUserId}) async {
    final Uri uri = Uri.parse('$baseUrl/request-list/').replace(
      queryParameters: {
        if (sendUserId != null) 'send_user_id': sendUserId.toString(),
        if (receiveUserId != null) 'receive_user_id': receiveUserId.toString(),
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

  // Fetch friend list
  Future<ApiResponse> fetchFriendList(int userId,String bestFriend) async {
    final Uri uri = Uri.parse('$baseUrl/friend-list/').replace(
      queryParameters: {
        'user_id': userId,
        'best_friend': bestFriend,
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
}

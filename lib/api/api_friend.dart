import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class FriendAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/friend';

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

  Future<ApiResponse> searchUser(body) async {

    final response = await http.post(
      Uri.parse('https://snowlive-api-0eab29705c9f.herokuapp.com/api/accounts/find-user-by-display-name/'),
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

  Future<ApiResponse> fetchFriendRequests({int? my_user_id, int? friend_user_id}) async {
    final Uri uri = Uri.parse('$baseUrl/request-list/').replace(
      queryParameters: {
        if (my_user_id != null) 'my_user_id': my_user_id.toString(),
        if (friend_user_id != null) 'friend_user_id': friend_user_id.toString(),
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

  Future<ApiResponse> fetchBlcokListRequests({required user_id}) async {
    final Uri uri = Uri.parse('https://snowlive-api-0eab29705c9f.herokuapp.com/api/community/block-list/').replace(
      queryParameters: {
        if (user_id != null) 'user_id': user_id.toString(),
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


  Future<ApiResponse> fetchFriendList({required int userId,required bool bestFriend}) async {
    final Uri uri = Uri.parse('$baseUrl/friend-list/').replace(
      queryParameters: {
        'my_user_id': userId.toString(),
        'best_friend': bestFriend.toString(),
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: $e');
    }
  }

}

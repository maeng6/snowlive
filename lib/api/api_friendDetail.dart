import 'dart:convert';
import 'package:com.snowlive/model/m_friendDetail.dart';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class FriendDetailAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/friend-detail-page';

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

  Future<ApiResponse> reportFriendsTalk(body) async {

    final response = await http.post(
      Uri.parse('$baseUrl/report-friends-talk/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 400) {
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

  Future<ApiResponse> unblockUser(body) async {

    final response = await http.delete(
      Uri.parse('https://snowlive-api-0eab29705c9f.herokuapp.com/api/community/block/'),
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

  Future<ApiResponse> fetchFriendsTalkList(int userId, int friendUserId) async {
    print(userId);
    print(friendUserId);
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
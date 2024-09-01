import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ApiResponse.dart';

class FleamarketAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/fleamarket';

  Future<ApiResponse> uploadFleamarket(Map<String, dynamic> body, List<Map<String, dynamic>> photos) async {
    body['photos'] = photos;

    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> updateFleamarket(int fleamarketId, Map<String, dynamic> body, List<Map<String, dynamic>> photos) async {
    body['photos'] = photos;

    final Uri uri = Uri.parse('$baseUrl/$fleamarketId/');

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> deleteFleamarket({
    required int fleamarketId,
    required int userId,
  }) async {
    final Uri uri = Uri.parse('$baseUrl/$fleamarketId/').replace(
      queryParameters: {
        'user_id': userId.toString(),
      },
    );

    final response = await http.delete(uri);

    if (response.statusCode == 204) {
      return ApiResponse.success({});
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> detailFleamarket({
    required int fleamarketId,
  }) async {
    final Uri uri = Uri.parse('$baseUrl/$fleamarketId/');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> fetchFleamarketList({
    required int userId,
    String? categoryMain,
    String? categorySub,
    String? spot,
    int? favorite_list,
    String? search_query,
    bool? myflea,
    String? url,
  }) async {
    print('api   :    $url');

    if(url != null) {
      final Uri uri = Uri.parse(url);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return ApiResponse.success(data);
      } else {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return ApiResponse.error(data);
      }
    } else {
      final Uri uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'user_id': userId.toString(),
          if (categoryMain != null) 'category_main': categoryMain,
          if (categorySub != null) 'category_sub': categorySub,
          if (spot != null) 'spot': spot,
          if (favorite_list != null) 'favorite_list': favorite_list.toString(),
          if (search_query != null) 'search_query': search_query,
          if (myflea != null) 'myflea': myflea.toString(),
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return ApiResponse.success(data);
      } else {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return ApiResponse.error(data);
      }
    }
  }

  Future<ApiResponse> addFavoriteFleamarket(int fleamarketId, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$fleamarketId/favorite/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> deleteFavoriteFleamarket(int fleamarketId, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$fleamarketId/unfavorite/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }
}

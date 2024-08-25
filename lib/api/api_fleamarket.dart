import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ApiResponse.dart';
import 'api_user.dart';

class FleamarketAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/fleamarket/';

  //TODO: 요청바디와 Photos예시
  // Map<String, dynamic> body = {
  //   "user_id": 57346,
  //   "product_name": "Updated Snowboard",
  //   "category_main": "스노보드22222",
  //   "category_sub": "Gear",
  //   "price": 550,
  //   "negotiable": false,
  //   "method": "택배",
  //   "spot": "Incheon",
  //   "sns_url": "http://example.com/sns-updated",
  //   "title": "Updated Snowboard for Sale",
  //   "description": "This is an updated snowboard in excellent condition."
  // };
  //
  // List<Map<String, dynamic>> photos = [
  //   {
  //     "display_order": 1,
  //     "url_flea_photo": "http://example222.com/photo1-updated.jpg"
  //   },
  //   {
  //     "display_order": 2,
  //     "url_flea_photo": "http://example22332.com/photo1-updated.jpg"
  //   },
  //   {
  //     "display_order": 3,
  //     "url_flea_photo": "http://example2555522.com/photo1-updated.jpg"
  //   }
  // ];

  Future<ApiResponse> uploadFleamarket(Map<String, dynamic> body, List<Map<String, dynamic>> photos) async {
    // 기존 바디에 photos 리스트를 추가
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

  Future<ApiResponse> updateFleamarket(int fleamerket_id, Map<String, dynamic> body, List<Map<String, dynamic>> photos) async {
    // 기존 바디에 photos 리스트를 추가
    body['photos'] = photos;

    final Uri uri = Uri.parse('$baseUrl/$fleamerket_id/');

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
    required int fleamerket_id,
    required int userId,
  }) async {
    final Uri uri = Uri.parse('$baseUrl/$fleamerket_id/').replace(
      queryParameters: {
        'user_id': userId.toString(),
      },
    );

    final response = await http.delete(uri);

    if (response.statusCode == 204) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> detailFleamarket({
    required int fleamerket_id,
  }) async {

    final Uri uri = Uri.parse('$baseUrl/$fleamerket_id/');

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
    int? favoriteUserId,
    String? searchQuery,
  }) async {
    final Uri uri = Uri.parse('$baseUrl').replace(
      queryParameters: {
        'user_id': userId.toString(),
        if (categoryMain != null) 'category_main': categoryMain,
        if (categorySub != null) 'category_sub': categorySub,
        if (spot != null) 'spot': spot,
        if (favoriteUserId != null) 'favorite_user_id': favoriteUserId.toString(),
        if (searchQuery != null) 'search_query': searchQuery,
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

  Future<ApiResponse> addFavoriteFleamarket(int fleamarket_id,Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$fleamarket_id/favorite/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if(response.statusCode==200){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }

  }

  Future<ApiResponse> deleteFavoriteFleamarket(int fleamarket_id,Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$fleamarket_id/unfavorite/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if(response.statusCode==200){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }

  }









}


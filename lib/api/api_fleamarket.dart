import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class FleamarketAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/fleamarket';

  Future<ApiResponse> uploadFleamarket(Map<String, dynamic> body, List<Map<String, dynamic>> photos) async {
    body['photos'] = photos;
    final response = await http.post(
      Uri.parse('$baseUrl/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if(response.statusCode==201){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> updateFleamarket(int fleamarketId, Map<String, dynamic> body, List<Map<String, dynamic>>? photos) async {
    body['photos'] = photos;
    final response = await http.put(
      Uri.parse('$baseUrl/$fleamarketId/'),
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

  Future<ApiResponse> updateStatus(int fleamarketId, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$fleamarketId/'),
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

  Future<ApiResponse> deleteFleamarket({required int fleamarketId, required int userId}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$fleamarketId/').replace(queryParameters: {'user_id': userId.toString()}),
    );
    if(response.statusCode==204){
      final data = '';
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> detailFleamarket({
    required int fleamarketId,
    required int userId,
  }) async {
    // 쿼리 파라미터로 user_id를 추가
    final uri = Uri.parse('$baseUrl/$fleamarketId/')
        .replace(queryParameters: {'user_id': userId.toString()});

    final response = await http.get(uri);

    if(response.statusCode==200){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> fetchFleamarketList({
    required int userId,
    String? categoryMain,
    String? categorySub,
    String? spot,
    bool? favorite_list,
    String? search_query,
    bool? myflea,
    String? url,
  }) async {
    final uri = url != null ? Uri.parse(url) : Uri.parse(baseUrl).replace(
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
    if(response.statusCode==200){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> addFavoriteFleamarket(
      {required int fleamarketId, required Map<String, dynamic> body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$fleamarketId/favorite/'),
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

  Future<ApiResponse> deleteFavoriteFleamarket(
      {required int fleamarketId, required Map<String, dynamic> body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$fleamarketId/unfavorite/'),
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

  Future<ApiResponse> fetchComments({
    required int userId,
    required int fleaId,
    String? url,
  }) async {
    final uri = url != null ? Uri.parse(url) : Uri.parse('$baseUrl/comments/').replace(
        queryParameters: {
          'flea_id': fleaId.toString(),
          'user_id': userId.toString()
        });
    final response = await http.get(uri);
    if(response.statusCode==200){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> createComment(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comments/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if(response.statusCode==201){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> updateComment(
      {required int commentId,required Map<String, dynamic> body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/comments/$commentId/'),
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

  Future<ApiResponse> deleteComment({required int commentId, required int userId}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$commentId/').replace(queryParameters: {'user_id': userId.toString()}),
    );
    if(response.statusCode==204){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> fetchComment({required int commentId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/comments/$commentId/'),
    );
    if(response.statusCode==200){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> fetchReplies({
    required int userId,
    required int commentId,
    String? url,
  }) async {
    final uri = url != null ? Uri.parse(url) : Uri.parse('$baseUrl/replies/').replace(
        queryParameters: {
          'comment_id': commentId.toString(),
          'user_id': userId.toString()
        });
    final response = await http.get(uri);
    if(response.statusCode==200){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> createReply(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/replies/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if(response.statusCode==201){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> updateReply(int replyId, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/replies/$replyId/'),
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

  Future<ApiResponse> deleteReply(int replyId, String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/replies/$replyId/').replace(queryParameters: {'user_id': userId.toString()}),
    );
    if(response.statusCode==204){
      final data = '';
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> reportComment(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comments/report/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if(response.statusCode==201){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> reportReply(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/replies/report/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if(response.statusCode==201){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> reportFleamarket(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if(response.statusCode==201){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

}

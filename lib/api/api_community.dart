import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ApiResponse.dart';

class CommunityAPI {
  // Base URL
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/community';

  // 커뮤니티 게시글 생성
  Future<ApiResponse> createCommunityPost(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/community-create/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 커뮤니티 목록 조회
  Future<ApiResponse> fetchCommunityList({
    String? categoryMain,
    String? categorySub,
    String? categorySub2,
    String? findUserId,
    String? searchQuery,
    String? userId,
  }) async {
    final uri = Uri.parse('$baseUrl/community-list/')
        .replace(queryParameters: {
      if (categoryMain != null) 'category_main': categoryMain,
      if (categorySub != null) 'category_sub': categorySub,
      if (categorySub2 != null) 'category_sub2': categorySub2,
      if (findUserId != null) 'find_user_id': findUserId,
      if (searchQuery != null) 'search_query': searchQuery,
      if (userId != null) 'user_id': userId,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 커뮤니티 세부사항 조회
  Future<ApiResponse> fetchCommunityDetails(int communityId, {String? userId}) async {
    final uri = Uri.parse('$baseUrl/community-details/$communityId/')
        .replace(queryParameters: userId != null ? {'user_id': userId} : null);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 커뮤니티 업데이트
  Future<ApiResponse> updateCommunity(int communityId, Map<String, dynamic> updateData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/community-details/$communityId/'),
      body: json.encode(updateData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 커뮤니티 삭제
  Future<ApiResponse> deleteCommunity(int communityId, String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/community-details/$communityId/'),
      headers: {'Content-Type': 'application/json', 'user_id': userId},
    );

    if (response.statusCode == 204) {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 댓글 생성
  Future<ApiResponse> createComment(Map<String, dynamic> commentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comment-create/'),
      body: json.encode(commentData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 댓글 상세 조회
  Future<ApiResponse> fetchCommentDetails(int commentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/comment-details/$commentId/'),
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 댓글 목록 조회
  Future<ApiResponse> fetchComments(int communityId, {String? userId}) async {
    final uri = Uri.parse('$baseUrl/comment-list/')
        .replace(queryParameters: {
      'community_id': communityId.toString(),
      if (userId != null) 'user_id': userId,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 댓글 업데이트
  Future<ApiResponse> updateComment(int commentId, Map<String, dynamic> updateData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/comment-details/$commentId/'),
      body: json.encode(updateData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 댓글 삭제
  Future<ApiResponse> deleteComment(int commentId, String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/comment-details/$commentId/'),
      headers: {'Content-Type': 'application/json', 'user_id': userId},
    );

    if (response.statusCode == 204) {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 답글 생성
  Future<ApiResponse> createReply(Map<String, dynamic> replyData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reply-create/'),
      body: json.encode(replyData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 답글 상세 조회
  Future<ApiResponse> fetchReplyDetails(int replyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reply-details/$replyId/'),
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 답글 목록 조회
  Future<ApiResponse> fetchReplies(int commentId, {String? userId}) async {
    final uri = Uri.parse('$baseUrl/reply-list/')
        .replace(queryParameters: {
      'comment_id': commentId.toString(),
      if (userId != null) 'user_id': userId,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 답글 업데이트
  Future<ApiResponse> updateReply(int replyId, Map<String, dynamic> updateData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reply-details/$replyId/'),
      body: json.encode(updateData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 답글 삭제
  Future<ApiResponse> deleteReply(int replyId, String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reply-details/$replyId/'),
      headers: {'Content-Type': 'application/json', 'user_id': userId},
    );

    if (response.statusCode == 204) {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 커뮤니티 신고
  Future<ApiResponse> reportCommunity(String userId, String communityId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report-community/'),
      body: json.encode({'user_id': userId, 'community_id': communityId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

  // 댓글 신고
  Future<ApiResponse> reportComment(String userId, String commentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report-comment/'),
      body: json.encode({'user_id': userId, 'comment_id': commentId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }


  // 답글 신고
  Future<ApiResponse> reportReply(String userId, String replyId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report-reply/'),
      body: json.encode({'user_id': userId, 'reply_id': replyId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }
}

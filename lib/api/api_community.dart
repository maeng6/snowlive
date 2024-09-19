import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ApiResponse.dart';

class CommunityAPI {
  // Base URL
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/community';

  // 커뮤니티 게시글 생성
  Future<ApiResponse> createCommunityPost(Map<String, dynamic> body) async {
    print(body);
    final response = await http.post(
      Uri.parse('$baseUrl/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    print(response.statusCode);

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
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
    String? url,  // URL을 추가
  }) async {
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/').replace(
      queryParameters: {
        if (categoryMain != null) 'category_main': categoryMain,
        if (categorySub != null) 'category_sub': categorySub,
        if (categorySub2 != null) 'category_sub2': categorySub2,
        if (findUserId != null) 'find_user_id': findUserId,
        if (searchQuery != null) 'search_query': searchQuery,
        if (userId != null) 'user_id': userId.toString(),
      },
    );

    final response = await http.get(uri);
    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  // 커뮤니티 세부사항 조회
  Future<ApiResponse> fetchCommunityDetails(int communityId, String userId) async {
    final uri = Uri.parse('$baseUrl/$communityId/')
        .replace(queryParameters: {'user_id': userId.toString()} );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 커뮤니티 업데이트
  Future<ApiResponse> updateCommunity(int communityId, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$communityId/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 커뮤니티 삭제
  Future<ApiResponse> deleteCommunity(int communityId, String userId) async {
    final uri = Uri.parse('$baseUrl/$communityId/')
        .replace(queryParameters: {'user_id': userId.toString()});

    final response = await http.delete(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 204) {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 댓글 생성
  Future<ApiResponse> createComment(Map<String, dynamic> commentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comments/'),
      body: json.encode(commentData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 댓글 상세 조회
  Future<ApiResponse> fetchCommentDetails(int commentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/comments/${commentId}/'),
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 댓글 목록 조회
  Future<ApiResponse> fetchComments({
    required int userId,
    required int communityId,
    String? url,
  }) async {
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/comments/').replace(
      queryParameters: {
        'community_id': communityId.toString(),
        'user_id': userId.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 댓글 업데이트
  Future<ApiResponse> updateComment(int commentId, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/comment-details/$commentId/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 댓글 삭제
  Future<ApiResponse> deleteComment(int commentId, int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$commentId/').replace(queryParameters: {
        'user_id': userId.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 답글 생성
  Future<ApiResponse> createReply(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/replies/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 답글 상세 조회
  Future<ApiResponse> fetchReplyDetails(int replyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reply-details/$replyId/'),
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
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
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 답글 업데이트
  Future<ApiResponse> updateReply(int replyId, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reply-details/$replyId/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 답글 삭제
  Future<ApiResponse> deleteReply(int replyId, String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/replies/$replyId/'),
      headers: {'Content-Type': 'application/json', 'user_id': userId},
    );

    if (response.statusCode == 204) {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 커뮤니티 신고
  Future<ApiResponse> reportCommunity(body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 댓글 신고
  Future<ApiResponse> reportComment(int userId, int commentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report/'),
      body: json.encode({'user_id': userId.toString(), 'comment_id': commentId.toString()}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // 답글 신고
  Future<ApiResponse> reportReply({required int userId, required int replyId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report-reply/'),
      body: json.encode({'user_id': userId.toString(), 'reply_id': replyId.toString()}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }
}

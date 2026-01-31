import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ApiResponse.dart';

class LiveTalkAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/livetalk';

  // ============================================
  // 1. 게시글 (LiveTalk)
  // ============================================

  /// 1.1 목록 조회
  Future<ApiResponse> fetchList(Map<String, dynamic> body, {String? url}) async {
    final response = await http.post(
      Uri.parse(url ?? '$baseUrl/list/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 1.2 상세 조회 (댓글+답글 포함)
  Future<ApiResponse> fetchDetail(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/detail/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 1.3 작성
  Future<ApiResponse> create(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 1.4 수정
  Future<ApiResponse> update(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 1.5 삭제
  Future<ApiResponse> delete(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 1.6 좋아요 토글
  Future<ApiResponse> toggleLike(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/like/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 1.7 내 게시글 목록
  Future<ApiResponse> fetchMyList(Map<String, dynamic> body, {String? url}) async {
    final response = await http.post(
      Uri.parse(url ?? '$baseUrl/my/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // ============================================
  // 2. 댓글 (Comment)
  // ============================================

  /// 2.1 댓글 목록 조회
  Future<ApiResponse> fetchCommentList(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comment/list/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 2.2 댓글 작성
  Future<ApiResponse> createComment(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comment/create/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 2.3 댓글 수정
  Future<ApiResponse> updateComment(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comment/update/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 2.4 댓글 삭제
  Future<ApiResponse> deleteComment(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comment/delete/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 2.5 댓글 좋아요 토글
  Future<ApiResponse> toggleCommentLike(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comment/like/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // ============================================
  // 3. 답글 (Reply)
  // ============================================

  /// 3.1 답글 목록 조회
  Future<ApiResponse> fetchReplyList(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reply/list/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 3.2 답글 작성
  Future<ApiResponse> createReply(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reply/create/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 3.3 답글 수정
  Future<ApiResponse> updateReply(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reply/update/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 3.4 답글 삭제
  Future<ApiResponse> deleteReply(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reply/delete/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 3.5 답글 좋아요 토글
  Future<ApiResponse> toggleReplyLike(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reply/like/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  // ============================================
  // 4. 신고 (Report)
  // ============================================

  /// 4.1 게시글 신고
  Future<ApiResponse> report(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 4.2 댓글 신고
  Future<ApiResponse> reportComment(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report/comment/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  /// 4.3 답글 신고
  Future<ApiResponse> reportReply(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report/reply/'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }
}

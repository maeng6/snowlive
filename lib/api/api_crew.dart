import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ApiResponse.dart';

class CrewAPI {
// baseUrl 설정
  static const baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/crew';

// 크루 이름 확인
  Future<ApiResponse<Map<String, dynamic>>> checkCrewName(
      String crewName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-crew-name/'),
      body: json.encode({'crew_name': crewName}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 생성
  Future<ApiResponse<Map<String, dynamic>>> createCrew(
      Map<String, dynamic> crewData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create-crew/'),
      body: json.encode(crewData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 세부사항 조회
  Future<ApiResponse<Map<String, dynamic>>> getCrewDetails(int crewId, {int? season}) async {
    final uri = Uri.parse('$baseUrl/crew-details/$crewId/').replace(
      queryParameters: season != null ? {'season': season.toString()} : null,
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 세부사항 업데이트
  Future<ApiResponse<Map<String, dynamic>>> updateCrewDetails(int crewId,
      Map<String, dynamic> updateData) async {
    final uri = Uri.parse('$baseUrl/crew-details/$crewId/');
    final response = await http.put(
      uri,
      body: json.encode(updateData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 삭제
  Future<ApiResponse<void>> deleteCrew(int crewId, String userId) async {
    final uri = Uri.parse('$baseUrl/crew-details/$crewId/').replace(
        queryParameters: {'user_id': userId});

    final response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 리스트 조회
  Future<ApiResponse<List<dynamic>>> listCrews({
    String? crewName,
    bool? iskusbf,
    String? baseResortId
  }) async {
    final uri = Uri.parse('$baseUrl/crew-list/')
        .replace(queryParameters: {
      if (crewName != null) 'crew_name': crewName,
      if (iskusbf != null) 'iskusbf': iskusbf.toString(),
      if (baseResortId != null) 'base_resort_id': baseResortId,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 가입 신청
  Future<ApiResponse<Map<String, dynamic>>> applyForCrew(
      Map<String, dynamic> applicationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/apply-crew/'),
      body: json.encode(applicationData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 가입 신청 승인
  Future<ApiResponse<Map<String, dynamic>>> approveCrewApplication(
      Map<String, dynamic> approvalData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/approve-crew-application/'),
      body: json.encode(approvalData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 가입 신청 삭제
  Future<ApiResponse<Map<String, dynamic>>> deleteCrewApplication(
      Map<String, dynamic> deleteData) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete-crew-application/'),
      body: json.encode(deleteData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 멤버 상태 업데이트
  Future<ApiResponse<Map<String, dynamic>>> updateCrewMemberStatus(
      Map<String, dynamic> statusData) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/update-crew-member-status/'),
      body: json.encode(statusData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 멤버 리스트 조회
  Future<ApiResponse<List<dynamic>>> listCrewMembers(int crewId,
      {bool? isLiveOn}) async {
    final uri = Uri.parse('$baseUrl/crew-members/$crewId/')
        .replace(queryParameters: {
      if (isLiveOn != null) 'is_live_on': isLiveOn.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 탈퇴
  Future<ApiResponse<Map<String, dynamic>>> leaveCrew(
      Map<String, dynamic> leaveData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leave-crew/'),
      body: json.encode(leaveData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 일일 리포트
  Future<ApiResponse<List<dynamic>>> getCrewDailyReport(String crewId,
      String year) async {
    final uri = Uri.parse('$baseUrl/crew-daily-report/')
        .replace(queryParameters: {'crew_id': crewId, 'year': year});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 공지 생성
  Future<ApiResponse<Map<String, dynamic>>> createCrewNotice(
      Map<String, dynamic> noticeData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/crew-notice/'),
      body: json.encode(noticeData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 공지 업데이트
  Future<ApiResponse<Map<String, dynamic>>> updateCrewNotice(
      Map<String, dynamic> noticeData) async {
    final noticeId = noticeData['notice_id'];
    final response = await http.patch(
      Uri.parse('$baseUrl/update-notice/$noticeId/'),
      body: json.encode(noticeData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 공지 삭제
  Future<ApiResponse<void>> deleteCrewNotice(String noticeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete-notice/$noticeId/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

// 크루 공지 리스트 조회
  Future<ApiResponse<List<dynamic>>> listCrewNotices(String userId,
      String crewId) async {
    final uri = Uri.parse('$baseUrl/notice-crew-list/')
        .replace(queryParameters: {'user_id': userId, 'crew_id': crewId});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class SnowballAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/ranking';

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // -----------------------
  // 공통: 안전 디코딩
  // -----------------------
  dynamic _decodeBody(http.Response r) {
    return json.decode(utf8.decode(r.bodyBytes));
  }

  // -----------------------
  // 눈송이 기록 생성
  // POST /snowball-record/
  // body: { user_id, snowball_id, coordinates, event_date }
  // -----------------------
  Future<ApiResponse> createSnowballRecord(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl/snowball-record/'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = _decodeBody(r);
    return (r.statusCode == 201) ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  // -----------------------
  // 스노우볼 홈
  // POST /snowball-home/
  // body: { user_id, event_date }
  // resp: { summary:[{kind,remaining}], records:[...], sponsor:[...] }
  // -----------------------
  Future<ApiResponse> fetchSnowballHome(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl/snowball-home/'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = _decodeBody(r);
    return (r.statusCode == 200) ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  // -----------------------
  // 상점 목록
  // POST /snowball-shop/
  // body: { user_id, event_date, is_tier_only?, is_for_mission? }
  // resp: { summary:[...], items:[{...}] }
  // -----------------------
  Future<ApiResponse> fetchSnowballShop(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl/snowball-shop/'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = _decodeBody(r);
    return (r.statusCode == 200) ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  // -----------------------
  // 아이템 구매
  // POST /snowball-item-purchase/
  // body: { user_id, snowball_item_id, event_date }
  // resp: { message } (201)
  // -----------------------
  Future<ApiResponse> purchaseSnowballItem(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl/snowball-item-purchase/'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = _decodeBody(r);
    return (r.statusCode == 201) ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  // -----------------------
  // 구매 기록 리스트
  // POST /snowball-buy-record/
  // body: { user_id }
  // resp: { snowball_buy_records: [ {...} ] }
  // -----------------------
  Future<ApiResponse> fetchSnowballBuyRecords(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl/snowball-buy-record/'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = _decodeBody(r);
    return (r.statusCode == 200) ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  // -----------------------
  // 구매 기록 수령 처리
  // POST /snowball-item-receive/
  // body: { snowball_buy_record_id }
  // resp: { display_name, item_name } (200) / 409 등
  // -----------------------
  Future<ApiResponse> receiveSnowballBuyRecord(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl/snowball-item-receive/'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = _decodeBody(r);
    return (r.statusCode == 200) ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  // -----------------------
  // 요약(남은 눈송이)
  // POST /snowball-summary/
  // body: { user_id, event_date }
  // resp: [ { kind, remaining }, ... ]
  // -----------------------
  Future<ApiResponse> fetchSnowballSummary(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl/snowball-summary/'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = _decodeBody(r);
    return (r.statusCode == 200) ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  // -----------------------
  // 미션 상태
  // POST /snowball-mission-status/
  // body: { user_id, event_date }
  // resp: { mission_status:{mission_1:{title,complete},...}, complete_total, brand_item_premium:[...], brand_item_basic:[...], is_applied }
  // -----------------------
  Future<ApiResponse> fetchSnowballMissionStatus(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl/snowball-mission-status/'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = _decodeBody(r);
    return (r.statusCode == 200) ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  // -----------------------
  // 미션 신청
  // POST /snowball-mission-apply/
  // body: { user_id, event_date, Snowball_sponsor_id }
  // resp: { message } (201 or 200(중복))
  // -----------------------
  Future<ApiResponse> applySnowballMission(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl/snowball-mission-apply/'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = _decodeBody(r);
    return (r.statusCode == 201 || r.statusCode == 200)
        ? ApiResponse.success(data)
        : ApiResponse.error(data);
  }

  // -----------------------
  // 내 눈송이 기록
  // POST /user-snowball-record/
  // body: { user_id, event_date }
  // resp: [ SnowballRecord... ] / 404
  // -----------------------
  Future<ApiResponse> fetchUserSnowballRecords(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl/user-snowball-record/'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = _decodeBody(r);
    return (r.statusCode == 200) ? ApiResponse.success(data) : ApiResponse.error(data);
  }
}

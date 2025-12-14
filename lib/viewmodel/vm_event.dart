import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:com.snowlive/api/api_event.dart';
import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/model/m_event.dart';

class EventViewModel extends GetxController {
  // API 인스턴스
  final EventAPI _eventAPI = EventAPI();

  // 로딩 상태
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isLoadingDetail = false.obs;

  // 이벤트 목록
  var _eventList = <EventModel>[].obs;
  List<EventModel> get eventList => _eventList;

  // 이벤트 상세
  var _eventDetail = Rxn<EventModel>();
  EventModel? get eventDetail => _eventDetail.value;

  // 페이지네이션
  var _nextPageUrl = ''.obs;
  String get nextPageUrl => _nextPageUrl.value;
  bool get hasNextPage => _nextPageUrl.value.isNotEmpty;

  // 필터
  var _selectedCategory = ''.obs;
  String get selectedCategory => _selectedCategory.value;

  var _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;

  // 무한 스크롤 컨트롤러
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  /// 스크롤 리스너 (무한 스크롤)
  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && hasNextPage) {
        fetchMoreEvents();
      }
    }
  }

  /// 카테고리 변경
  void setCategory(String category) {
    _selectedCategory.value = category;
    fetchEventList();
  }

  /// 검색어 변경
  void setSearchQuery(String query) {
    _searchQuery.value = query;
    fetchEventList();
  }

  /// 필터 초기화
  void clearFilters() {
    _selectedCategory.value = '';
    _searchQuery.value = '';
    fetchEventList();
  }

  /// 이벤트 목록 조회
  Future<void> fetchEventList() async {
    if (isLoading.value) return;

    try {
      isLoading(true);
      _eventList.clear();

      final response = await _eventAPI.fetchEventList(
        category: _selectedCategory.value.isNotEmpty ? _selectedCategory.value : null,
        searchQuery: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
      );

      if (response.success) {
        final eventListResponse = EventListResponse.fromJson(response.data!);
        _eventList.value = eventListResponse.events;
        _nextPageUrl.value = eventListResponse.next ?? '';
        print('이벤트 목록 조회 완료: ${_eventList.length}개');
      } else {
        print('이벤트 목록 조회 실패: ${response.error}');
      }
    } catch (e) {
      print('이벤트 목록 조회 에러: $e');
    } finally {
      isLoading(false);
    }
  }

  /// 이벤트 추가 로드 (무한 스크롤)
  Future<void> fetchMoreEvents() async {
    if (!hasNextPage || isLoadingMore.value) return;

    try {
      isLoadingMore(true);

      final response = await _eventAPI.fetchEventList(
        url: _nextPageUrl.value,
      );

      if (response.success) {
        final eventListResponse = EventListResponse.fromJson(response.data!);
        _eventList.addAll(eventListResponse.events);
        _nextPageUrl.value = eventListResponse.next ?? '';
        print('이벤트 추가 로드 완료: ${eventListResponse.events.length}개 추가');
      } else {
        print('이벤트 추가 로드 실패: ${response.error}');
      }
    } catch (e) {
      print('이벤트 추가 로드 에러: $e');
    } finally {
      isLoadingMore(false);
    }
  }

  /// 이벤트 상세 조회
  Future<void> fetchEventDetail({
    required int eventId,
    int? userId,
  }) async {
    try {
      isLoadingDetail(true);

      final response = await _eventAPI.fetchEventDetail(
        eventId: eventId,
        userId: userId,
      );

      if (response.success) {
        _eventDetail.value = EventModel.fromJson(response.data!);
        print('이벤트 상세 조회 완료: ${_eventDetail.value?.title}');
      } else {
        print('이벤트 상세 조회 실패: ${response.error}');
      }
    } catch (e) {
      print('이벤트 상세 조회 에러: $e');
    } finally {
      isLoadingDetail(false);
    }
  }

  /// 이벤트 생성
  Future<bool> createEvent({
    required int userId,
    required String category,
    required String title,
    String? description,
    String? thumbImgUrl,
  }) async {
    try {
      isLoading(true);

      final body = {
        'user_id': userId,
        'category': category,
        'title': title,
        if (description != null) 'description': description,
        if (thumbImgUrl != null) 'thumb_img_url': thumbImgUrl,
      };

      final response = await _eventAPI.createEvent(body);

      if (response.success) {
        print('이벤트 생성 완료');
        await fetchEventList(); // 목록 새로고침
        return true;
      } else {
        print('이벤트 생성 실패: ${response.error}');
        return false;
      }
    } catch (e) {
      print('이벤트 생성 에러: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// 이벤트 수정
  Future<bool> updateEvent({
    required int eventId,
    int? userId,
    String? category,
    String? title,
    String? description,
    String? thumbImgUrl,
  }) async {
    try {
      isLoading(true);

      final body = <String, dynamic>{};
      if (userId != null) body['user_id'] = userId;
      if (category != null) body['category'] = category;
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (thumbImgUrl != null) body['thumb_img_url'] = thumbImgUrl;

      final response = await _eventAPI.updateEvent(
        eventId: eventId,
        body: body,
      );

      if (response.success) {
        print('이벤트 수정 완료');
        _eventDetail.value = EventModel.fromJson(response.data!);
        await fetchEventList(); // 목록 새로고침
        return true;
      } else {
        print('이벤트 수정 실패: ${response.error}');
        return false;
      }
    } catch (e) {
      print('이벤트 수정 에러: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// 이벤트 삭제
  Future<bool> deleteEvent({
    required int eventId,
    required int userId,
  }) async {
    try {
      isLoading(true);

      final response = await _eventAPI.deleteEvent(
        eventId: eventId,
        userId: userId,
      );

      if (response.success) {
        print('이벤트 삭제 완료');
        _eventList.removeWhere((event) => event.eventId == eventId);
        return true;
      } else {
        print('이벤트 삭제 실패: ${response.error}');
        Get.snackbar('삭제 실패', '이벤트를 삭제할 권한이 없습니다.');
        return false;
      }
    } catch (e) {
      print('이벤트 삭제 에러: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// 조회수 증가
  Future<void> incrementViewCount({
    required int eventId,
    required int userId,
  }) async {
    try {
      final response = await _eventAPI.incrementViewCount(
        eventId: eventId,
        userId: userId,
      );

      if (response.success) {
        print('조회수 증가 완료');
      } else {
        print('조회수 증가 실패: ${response.error}');
      }
    } catch (e) {
      print('조회수 증가 에러: $e');
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await fetchEventList();
  }

  /// 상세 정보 초기화
  void clearDetail() {
    _eventDetail.value = null;
  }
}

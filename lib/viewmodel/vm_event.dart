import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:com.snowlive/api/api_event.dart';
import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/model/m_event.dart';

class EventViewModel extends GetxController {
  // API 인스턴스
  final EventAPI _eventAPI = EventAPI();

  // 로딩 상태
  var isLoading = false.obs;        // 초기/일반 로딩
  var isLoadingMore = false.obs;    // 무한스크롤 로딩
  var isLoadingDetail = false.obs;  // 상세 로딩
  var isRefreshing = false.obs;     // ✅ 당겨서 새로고침 전용

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
  var _selectedCategory = '전체'.obs;
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
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      // ✅ 새로고침 중에는 더보기 호출 방지
      if (!isRefreshing.value && !isLoadingMore.value && hasNextPage) {
        fetchMoreEvents();
      }
    }
  }

  /// 카테고리 변경 (이건 UX상 새로 로딩하는 게 맞으니 clear=true 유지)
  void setCategory(String category) {
    _selectedCategory.value = category;
    fetchEventList(clearBeforeFetch: true);
  }

  /// 검색어 변경 (이것도 clear=true 유지)
  void setSearchQuery(String query) {
    _searchQuery.value = query;
    fetchEventList(clearBeforeFetch: true);
  }

  /// 필터 초기화 (clear=true 유지)
  void clearFilters() {
    _selectedCategory.value = '';
    _searchQuery.value = '';
    fetchEventList(clearBeforeFetch: true);
  }

  /// ✅ 이벤트 목록 조회
  /// - clearBeforeFetch=true  : 초기 진입/필터 변경용 (리스트 비우고 새로 그림)
  /// - clearBeforeFetch=false : 당겨서 새로고침용 (리스트 유지 + 갱신만)
  Future<void> fetchEventList({bool clearBeforeFetch = true}) async {
    // 새로고침 모드일 때는 isLoading 대신 isRefreshing을 쓰는 게 깔끔
    if (clearBeforeFetch) {
      if (isLoading.value) return;
    } else {
      if (isRefreshing.value) return;
    }

    try {
      if (clearBeforeFetch) {
        isLoading(true);
        _eventList.clear(); // ✅ 초기 로딩/필터변경일 때만 비움
        _nextPageUrl.value = ''; // 초기화
      } else {
        // ✅ 당겨서 새로고침에서는 리스트를 비우지 않는다
        isRefreshing(true);
      }

      final response = await _eventAPI.fetchEventList(
        category: _selectedCategory.value != '전체'
            ? _selectedCategory.value
            : null,
        searchQuery:
        _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
      );

      if (response.success) {
        final eventListResponse = EventListResponse.fromJson(response.data!);

        // ✅ 여기서 한 번에 갈아끼우면 “리스트 유지 + 최신화” UX
        // (당겨서 새로고침에서도 기존 리스트는 남아있고,
        //  응답 도착하는 순간 자연스럽게 최신으로 바뀜)
        _eventList.assignAll(eventListResponse.events);

        _nextPageUrl.value = eventListResponse.next ?? '';
        print('이벤트 목록 조회 완료: ${_eventList.length}개');
      } else {
        print('이벤트 목록 조회 실패: ${response.error}');
      }
    } catch (e) {
      print('이벤트 목록 조회 에러: $e');
    } finally {
      if (clearBeforeFetch) {
        isLoading(false);
      } else {
        isRefreshing(false);
      }
    }
  }

  Future<void> addViewCount({user_id, event_id}) async{
    _eventAPI.incrementViewCount(userId: user_id, eventId: event_id);
  }



  /// 이벤트 추가 로드 (무한 스크롤)
  Future<void> fetchMoreEvents() async {
    if (!hasNextPage || isLoadingMore.value) return;

    // ✅ 새로고침 중이면 더보기 금지
    if (isRefreshing.value) return;

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
        await fetchEventList(clearBeforeFetch: true);
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
        await fetchEventList(clearBeforeFetch: true);
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

  /// ✅ 새로고침 (당겨서 새로고침에서 이걸 호출하면 리스트 유지됨)
  Future<void> refresh() async {
    await fetchEventList(clearBeforeFetch: false);
  }

  /// 상세 정보 초기화
  void clearDetail() {
    _eventDetail.value = null;
  }
}

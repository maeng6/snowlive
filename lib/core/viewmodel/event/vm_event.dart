import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:com.snowlive/core/api/api_event.dart';
import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/model/m_event.dart';

class EventViewModel extends GetxController {
  // API 인스턴스
  final EventAPI _eventAPI = EventAPI();

  // 로딩 상태
  var isLoading = false.obs;        // 초기/일반 로딩
  var isLoadingMore = false.obs;    // 무한스크롤 로딩
  var isRefreshing = false.obs;     // ✅ 당겨서 새로고침 전용
  var isInitialLoaded = false.obs;  // 초기 데이터 로드 완료 여부

  // 이벤트 목록
  var _eventList = <EventModel>[].obs;
  List<EventModel> get eventList => _eventList;

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

        // ✅ 여기서 한 번에 갈아끼우면 "리스트 유지 + 최신화" UX
        // (당겨서 새로고침에서도 기존 리스트는 남아있고,
        //  응답 도착하는 순간 자연스럽게 최신으로 바뀜)
        _eventList.assignAll(eventListResponse.events);

        _nextPageUrl.value = eventListResponse.next ?? '';
        isInitialLoaded.value = true;  // 초기 로딩 완료 표시
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

  // 목록 전용(각종소식)으로 정리 — 상세/생성/수정/삭제 및 조회수(addViewCount/incrementViewCount) 제거.
  // (어드민 CRUD는 웹 각종소식 어드민에서, 아이템 탭 시 landingUrl로 바로 이동)

  /// ✅ 새로고침 (당겨서 새로고침에서 이걸 호출하면 리스트 유지됨)
  Future<void> refresh() async {
    await fetchEventList(clearBeforeFetch: false);
  }
}

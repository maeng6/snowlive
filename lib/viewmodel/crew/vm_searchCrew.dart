import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/api/api_crew.dart';
import 'package:com.snowlive/model/m_crewList.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchCrewViewModel extends GetxController {

  // 검색 결과 리스트
  var crewList = <Crew>[].obs;
  var isLoading = false.obs; // 로딩 상태 관리
  var searchText = ''.obs; // 검색어 관리

  // 검색 결과 없을 때 메시지 관리
  var noResultsMessage = ''.obs;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final formKey = GlobalKey<FormState>();

  RxBool showRecentSearch = true.obs;
  RxBool isSearching = false.obs;
  RxList<String> recentSearches = <String>[].obs;

  // 초기 상태
  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();
    noResultsMessage.value = '검색어를 입력해주세요.';
  }

  // 크루 리스트 가져오는 함수
  Future<void> searchCrews(String crewName) async {
    isLoading.value = true;
    try {
      final response = await CrewAPI().listCrews(crewName: crewName);
      print(crewName);
      if (response.success) {
        CrewListResponse crewListResponse = CrewListResponse.fromJson(response.data as List<dynamic>);
        crewList.assignAll(crewListResponse.results ?? []);
        if (crewList.isEmpty) {
          noResultsMessage.value = '검색된 크루가 없습니다.';
        } else {
          noResultsMessage.value = '';
        }
      } else {
        noResultsMessage.value = '크루 목록을 가져오는데 실패했습니다.';
      }
    } catch (e) {
      noResultsMessage.value = '에러가 발생했습니다: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // 검색어 입력에 따라 검색 실행
  Future<void> onSearchTextChanged(String text) async{
    searchText.value = text;
    if (text.isNotEmpty) {
      showRecentSearch.value = false;  // 검색어가 입력되면 최근 검색어 숨기기
      await searchCrews(text);
    } else {
      showRecentSearch.value = true;  // 검색어가 없으면 최근 검색어 보여주기
      crewList.clear();
      noResultsMessage.value = '검색어를 입력해주세요.';
    }
  }

  // 최근 검색어 로드
  Future<void> loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    recentSearches.value = prefs.getStringList('recentSearches_crew') ?? [];
  }

  // 최근 검색어 저장
  Future<void> saveRecentSearch(String searchQuery) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 기존 검색어 리스트 불러오기
    List<String> searches = prefs.getStringList('recentSearches_crew') ?? [];

    // 중복 검색어 제거
    searches.remove(searchQuery);

    // 최신 검색어를 리스트의 맨 앞에 추가
    searches.insert(0, searchQuery);

    // 최대 10개의 검색어만 저장 (필요에 따라 조정)
    if (searches.length > 10) {
      searches = searches.sublist(0, 10);
    }

    // SharedPreferences에 저장
    await prefs.setStringList('recentSearches_crew', searches);

    // 상태 반영
    recentSearches.value = searches;
  }

  // 최근 검색어 삭제
  Future<void> deleteRecentSearch(String searchQuery) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    recentSearches.remove(searchQuery);
    await prefs.setStringList('recentSearches_crew', recentSearches);
  }

  // 검색 시작 시 호출
  void search(String query) {
    if (query.isNotEmpty) {
      isSearching.value = true;
      saveRecentSearch(query);
    }
  }

  // 모든 최근 검색어 삭제
  Future<void> deleteAllRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    recentSearches.clear();
    await prefs.remove('recentSearches_crew');
  }

}

import 'package:com.snowlive/model/m_resortModel.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/api/api_crew.dart';
import 'package:com.snowlive/model/m_crewDetail.dart';

class CrewDetailViewModel extends GetxController {
  // 탭 관리 리스트
  static const tabNameListConst = ['홈', '멤버', '갤러리'];

  // 탭과 관련된 Rx 변수들
  late RxList<String> tabNameList;
  late RxString _selectedTabName;

  // 크루 디테일 모델을 옵저버블로 선언
  var crewDetailResponse = CrewDetailResponse().obs;

  // 로딩 상태
  RxBool isLoading = false.obs;

  // 그래프 토글
  RxBool isSlopeGraph = true.obs;

  // 리조트 이름 저장용 변수 (리조트 변환 로직 필요)
  final RxString _resortName = ''.obs;

  CrewDetailInfo get crewDetailInfo => crewDetailResponse.value.crewDetailInfo ?? CrewDetailInfo(); // Null-safe 처리
  SeasonRankingInfo get seasonRankingInfo => crewDetailResponse.value.seasonRankingInfo ?? SeasonRankingInfo(); // Null-safe 처리

  String get crewName => crewDetailInfo.crewName ?? '';
  String get crewLogoUrl => crewDetailInfo.crewLogoUrl ?? '';
  String get description => crewDetailInfo.description ?? '';
  String get createdDate => crewDetailInfo.createdDate ?? '';
  int get crewMemberTotal => crewDetailInfo.crewMemberTotal ?? 0;
  String get color => crewDetailInfo.color ?? 'FFFFFF';
  String get resortName => _resortName.value;
  String get notice => crewDetailInfo.notice ?? '';

  double get overallTotalScore => seasonRankingInfo.overallTotalScore ?? 0;
  int get overallRank => seasonRankingInfo.overallRank ?? 0;
  double get overallRankPercentage => seasonRankingInfo.overallRankPercentage ?? 0;
  String get overallTierIconUrl => seasonRankingInfo.overallTierIconUrl ?? '';
  int get totalSlopeCount => seasonRankingInfo.totalSlopeCount ?? 0;
  List<CountInfo> get countInfo => seasonRankingInfo.countInfo ?? [];
  Map<String, int> get timeInfo => seasonRankingInfo.timeCountInfo ?? {};

  String get selectedTabName => _selectedTabName.value;

  @override
  void onInit() {
    super.onInit();
    tabNameList = tabNameListConst.obs;
    _selectedTabName = tabNameList[0].obs;
  }

  // API 호출해서 데이터를 가져오는 메소드
  Future<void> fetchCrewDetail(int crewId, String season) async {
    isLoading.value = true;
    try {
      // 시즌 정보 함께 전달
      final response = await CrewAPI().getCrewDetails(crewId, season: season);
      if (response.success) {
        crewDetailResponse.value = CrewDetailResponse.fromJson(response.data!);

        // 리조트 이름 변환
        changeResortNumberToName(crewDetailResponse.value.crewDetailInfo?.baseResortId);
      } else {
        print('Error fetching crew details: ${response.error}');
      }
    } catch (e) {
      print('Exception while fetching crew details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 탭 변경 함수
  void changeTab(String tabName) {
    _selectedTabName.value = tabName;
  }

  // 리조트 번호를 리조트 이름으로 변환
  void changeResortNumberToName(int? selectedResortId) {
    int adjustedResortId = selectedResortId! - 1;  // 서버 인덱스가 1부터 시작하면 -1 해주기

    if (adjustedResortId >= 0 && adjustedResortId < resortNameList.length) {
      _resortName.value = resortNameList[adjustedResortId] ?? "Unknown Resort";
    } else {
      _resortName.value = "Unknown Resort";
    }
  }


  // 그래프 토글 함수
  void toggleGraph() {
    isSlopeGraph.value = !isSlopeGraph.value;
  }
}

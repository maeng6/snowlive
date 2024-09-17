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
  var crewDetailModel = CrewDetailInfo().obs;
  var seasonRankingInfo = SeasonRankingInfo().obs;

  // 로딩 상태
  RxBool isLoading = false.obs;

  // 그래프 토글
  RxBool isSlopeGraph = true.obs;

  // 리조트 이름 저장용 변수 (리조트 변환 로직 필요)
  final RxString _resortName = ''.obs;

  // Getter for View access (모델 데이터를 직접 참조)
  String get crewName => crewDetailModel.value.crewName ?? '';
  String get crewLogoUrl => crewDetailModel.value.crewLogoUrl ?? '';
  String get description => crewDetailModel.value.description ?? '';
  String get createdDate => crewDetailModel.value.createdDate ?? '';
  int get crewMemberTotal => crewDetailModel.value.crewMemberTotal ?? 0;
  String get color => crewDetailModel.value.color ?? 'FFFFFF';
  String get resortName => _resortName.value;

  double get overallTotalScore => seasonRankingInfo.value.overallTotalScore ?? 0;
  int get overallRank => seasonRankingInfo.value.overallRank ?? 0;
  double get overallRankPercentage => seasonRankingInfo.value.overallRankPercentage ?? 0;
  String get overallTierIconUrl => seasonRankingInfo.value.overallTierIconUrl ?? '';
  int get totalSlopeCount => seasonRankingInfo.value.totalSlopeCount ?? 0;
  List<CountInfo> get countInfo => seasonRankingInfo.value.countInfo ?? [];
  List<int> get timeInfo => seasonRankingInfo.value.timeInfo ?? [];

  String get selectedTabName => _selectedTabName.value;

  @override
  void onInit() {
    super.onInit();
    tabNameList = tabNameListConst.obs;
    _selectedTabName = tabNameList[0].obs;
  }

  // API 호출해서 데이터를 가져오는 메소드
  Future<void> fetchCrewDetail(int crewId) async {
    isLoading.value = true;
    try {
      final response = await CrewAPI().getCrewDetails(crewId);
      if (response.success) {
        // API 호출 성공 시 데이터를 모델에 저장
        var crewDetailResponse = CrewDetailResponse.fromJson(response.data!);
        crewDetailModel.value = crewDetailResponse.crewDetailInfo!;
        seasonRankingInfo.value = crewDetailResponse.seasonRankingInfo!;

        // 리조트 이름 변환
        changeResortNumberToName(crewDetailModel.value.baseResortId);
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
    if (selectedResortId != null && selectedResortId >= 0 && selectedResortId < resortNameList.length) {
      _resortName.value = resortNameList[selectedResortId] ?? "Unknown Resort";  // null 값 처리
    } else {
      _resortName.value = "Unknown Resort";
    }
  }

  // 그래프 토글 함수
  void toggleGraph() {
    isSlopeGraph.value = !isSlopeGraph.value;
  }
}

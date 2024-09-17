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

  // 크루 디테일 정보
  final RxString _crewName = ''.obs;
  final RxString _crewLogoUrl = ''.obs;
  final RxString _description = ''.obs;
  final RxString _createdDate = ''.obs;
  final RxInt _crewMemberTotal = 0.obs;
  final RxString _color = 'FFFFFF'.obs; // 기본값: 흰색
  final RxString _resortName = ''.obs;
  final RxInt _baseResortId = 99.obs;

  // 시즌 랭킹 정보
  final RxDouble _overallTotalScore = 0.0.obs;
  final RxInt _overallRank = 0.obs;
  final RxDouble _overallRankPercentage = 0.0.obs;
  final RxString _overallTierIconUrl = ''.obs;
  final RxInt _totalSlopeCount = 0.obs;
  final RxList<CountInfo> _countInfo = <CountInfo>[].obs;
  final RxList<int> _timeInfo = <int>[].obs;

  // Getter for View access
  String get crewName => _crewName.value;
  String get crewLogoUrl => _crewLogoUrl.value;
  String get description => _description.value;
  String get createdDate => _createdDate.value;
  int get crewMemberTotal => _crewMemberTotal.value;
  String get color => _color.value;
  String get resortName => _resortName.value;

  double get overallTotalScore => _overallTotalScore.value;
  int get overallRank => _overallRank.value;
  double get overallRankPercentage => _overallRankPercentage.value;
  String get overallTierIconUrl => _overallTierIconUrl.value;
  int get totalSlopeCount => _totalSlopeCount.value;
  List<CountInfo> get countInfo => _countInfo;
  List<int> get timeInfo => _timeInfo;

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
        print('ddafsdf');
        // API 호출 성공 시 데이터를 모델에 저장
        var crewDetailResponse = CrewDetailResponse.fromJson(response.data!);
        crewDetailModel.value = crewDetailResponse.crewDetailInfo!;
        seasonRankingInfo.value = crewDetailResponse.seasonRankingInfo!;
        // 크루 디테일 정보 저장
        _crewName.value = crewDetailModel.value.crewName ?? '';
        _crewLogoUrl.value = crewDetailModel.value.crewLogoUrl ?? '';
        _description.value = crewDetailModel.value.description ?? '';
        _createdDate.value = crewDetailModel.value.createdDate ?? '';
        _crewMemberTotal.value = crewDetailModel.value.crewMemberTotal ?? 0;
        _color.value = crewDetailModel.value.color ?? 'FFFFFF';
        _baseResortId.value = crewDetailModel.value.baseResortId ?? 0;

        // 시즌 랭킹 정보 저장
        _overallTotalScore.value = seasonRankingInfo.value.overallTotalScore ?? 0;
        _overallRank.value = seasonRankingInfo.value.overallRank ?? 0;
        _overallRankPercentage.value = seasonRankingInfo.value.overallRankPercentage ?? 0;
        _overallTierIconUrl.value = seasonRankingInfo.value.overallTierIconUrl ?? '';
        _totalSlopeCount.value = seasonRankingInfo.value.totalSlopeCount ?? 0;
        _countInfo.value = seasonRankingInfo.value.countInfo ?? [];
        _timeInfo.value = seasonRankingInfo.value.timeInfo ?? [];

        // 리조트 이름 변환
        print(_baseResortId.value);
        changeResortNumberToName(_baseResortId.value);
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

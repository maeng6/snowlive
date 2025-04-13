
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList_recordRoom.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/api/api_crew.dart';
import 'package:com.snowlive/model/m_crewDetail_recordRoom.dart';

class CrewDetailViewModel_recordRoom extends GetxController {

  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();

  late RxString _selectedTabName;

  var crewDetailResponse = CrewDetailResponse_recordRoom().obs;

  RxBool isLoading = false.obs;

  RxBool isSlopeGraph = true.obs;

  var crewDetails = <int, Map<String, String>>{}.obs;

  RxBool _isCrewIntroExpanded = false.obs;

  CrewDetailInfo_recordRoom get crewDetailInfo => crewDetailResponse.value.crewDetailInfo ?? CrewDetailInfo_recordRoom();
  SeasonRankingInfo_recordRoom get seasonRankingInfo => crewDetailResponse.value.seasonRankingInfo ?? SeasonRankingInfo_recordRoom();

  String get crewName => crewDetailInfo.crewName ?? '';
  String get crewLogoUrl => crewDetailInfo.crewLogoUrl ?? '';
  String get description => crewDetailInfo.description ?? '';
  String get createdDate => crewDetailInfo.createdDate ?? '';
  int get crewMemberTotal => crewDetailInfo.crewMemberTotal ?? 0;
  String get color => crewDetailInfo.color ?? 'FFFFFF';

  double get overallTotalScore => seasonRankingInfo.overallTotalScore ?? 0;
  int get overallRank => seasonRankingInfo.overallRank ?? 0;
  double get overallRankPercentage => seasonRankingInfo.overallRankPercentage ?? 0;
  String get overallTierIconUrl => seasonRankingInfo.overallTierIconUrl ?? '';
  int get totalSlopeCount => seasonRankingInfo.totalSlopeCount ?? 0;
  List<CountInfo_recordRoom> get countInfo => seasonRankingInfo.countInfo ?? [];
  Map<String, int> get timeInfo => seasonRankingInfo.timeCountInfo ?? {};

  String get selectedTabName => _selectedTabName.value;

  bool get isCrewIntroExpanded => _isCrewIntroExpanded.value;

  @override
  void onInit() async{
    // TODO: implement onInit
    super.onInit();
    await fetchCrewDetail_recordRoom(_crewDetailViewModel.crewDetailInfo.crewId!,  RankingFilter_season.values.first.dbSeason );
  }


  Future<void> fetchCrewDetail_recordRoom(int crewId, String selected_season) async {
    isLoading.value = true;
    try {
      final response = await CrewAPI().getCrewDetails_recordRoom(crewId, selected_season);

      if (response.success) {
        crewDetailResponse.value = CrewDetailResponse_recordRoom.fromJson(response.data!);
        print('크루 라이딩 통계 페치완료');
      } else {
        print('Error fetching crew details: \${response.error}');
      }
    } catch (e) {
      print('Exception while fetching crew details: \$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCrewDetail_refresh_recordRoom(int crewId, String selected_season) async {
    try {
      final response = await CrewAPI().getCrewDetails_recordRoom(crewId, selected_season);

      if (response.success) {
        crewDetailResponse.value = CrewDetailResponse_recordRoom.fromJson(response.data!);
      } else {
        print('Error fetching crew details: \${response.error}');
      }
    } catch (e) {
      print('Exception while fetching crew details: \$e');
    }
  }

  void toggleGraph() {
    isSlopeGraph.value = !isSlopeGraph.value;
  }

  void toggleExpandCrewIntro() async {
    _isCrewIntroExpanded.value = !_isCrewIntroExpanded.value;
  }
}

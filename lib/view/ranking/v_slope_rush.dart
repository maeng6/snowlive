import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_slope_rush.dart';
import 'package:com.snowlive/model/m_slolpe_rush.dart';
import 'package:shimmer/shimmer.dart';

class SlopeRushHomeView extends StatefulWidget {
  const SlopeRushHomeView({super.key});

  @override
  State<SlopeRushHomeView> createState() => _SlopeRushHomeViewState();
}

class _SlopeRushHomeViewState extends State<SlopeRushHomeView> {
  final SlopeRushViewModel _slopeRushViewModel = Get.put(SlopeRushViewModel());
  final UserViewModel _userViewModel = Get.put(UserViewModel());
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();


  late int selectedResortId;        // ← 여기서 바로 값 넣지 않음
  String? selectedSlopeKey;

  final resortOptions = const [
    {'id': 1, 'name': '곤지암리조트'},
    {'id': 2, 'name': '무주덕유산리조트'},
    {'id': 3, 'name': '비발디파크'},
    {'id': 4, 'name': '알펜시아'},
    {'id': 6, 'name': '엘리시안강촌'},
    {'id': 7, 'name': '오크밸리리조트'},
    {'id': 8, 'name': '오투리조트'},
    {'id': 9, 'name': '용평리조트'},
    {'id': 10, 'name': '웰리힐리파크'},
    {'id': 11, 'name': '지산리조트'},
    {'id': 12, 'name': '하이원리조트'},
    {'id': 13, 'name': '휘닉스파크'},
  ];

  // 리조트별 이미지 폴더 슬러그
  static const Map<int, String> _resortSlug = {
    1: 'gonjiam',
    2: 'muju',
    3: 'vivaldi',
    4: 'alpensia',
    6: 'gangchon',
    7: 'oakvalley',
    8: 'o2',
    9: 'yongpyong',
    10: 'wellihilli',
    11: 'jisan',
    12: 'high1',
    13: 'phoenix',
  };

  // 서버 슬로프명 → 이미지키
  static const Map<int, Map<String, String>> _slopeKeyByResort = {
    1: {
      'CNP1': 'CNP1',
      'CNP2': 'CNP2',
      '씽큐1': 'thinq1',
      '씽큐2': 'thinq2',
      '씽큐3': 'thinq3',
      '씽큐B': 'thinqB',
      '그램1': 'gram1',
      '그램2': 'gram2',
      '와이낫': 'whynot',
      '휘센': 'whisen',
    },
    2: {
      '알레그로': 'allegro',
      '카덴자': 'cadenza',
      '커넥션': 'connection',
      '이스턴': 'eastern',
      '프리W': 'freeway',
      '미뉴': 'minuet',
      '파노(무)': 'panorama',
      '폴카': 'polka',
      '레이하': 'raidersdown',
      '레이상': 'raidersup',
      '루키힐': 'rookiehill',
      '실크하': 'silkdown',
      '서역': 'silkroad',
      '실크상': 'silkup',
      '스피츠': 'spitz',
      '터보': 'turbo',
      '왈츠': 'waltz',
      '웨스턴': 'western',
      '야마가': 'yamaga',
    },
    3: {
      '발라드': 'ballad',
      '락': 'rock',
      '블루스': 'blues',
      '클래식': 'classic',
      '펑키': 'funky',
      '힙합': 'hiphop',
      '재즈': 'jazz',
      '레게': 'reggae',
      '테크노1': 'techno1',
      '테크노2': 'techno2',
    },
    4: {
      '알파': 'alpha',
      '브라보': 'bravo',
      '찰리': 'charlie',
      '델타': 'delta',
      '에코': 'echo',
      '폭스트롯': 'foxtrot',
    },
    6: {
      '디어': 'deer',
      '드래곤': 'dragon',
      '재규어': 'jaguar',
      '래퍼드': 'leopard',
      '팬더': 'panda',
      '페가수': 'pegasus',
      '퓨마': 'puma',
      '래빗': 'rabbit',
      '제브라': 'zebra',
    },
    7: {
      'F': 'F',
      'G': 'G',
      'I': 'I',
    },
    8: {
      '챌1(오)': 'challenge1',
      '챌2(오)': 'challenge2',
      '챌3(오)': 'challenge3',
      '드림1': 'dream1',
      '드림2': 'dream2',
      '글로리1': 'glory1',
      '글로리2': 'glory2',
      '글로리3': 'glory3',
      '해피': 'happy',
      '헤드': 'head',
      '패션1': 'passion1',
      '패션2': 'passion2',
    },
    9: {
      '블루': 'blue',
      '파크(용)': 'dragonpark',
      '골드F': 'goldfantastic',
      '골드P': 'goldparadise',
      '골드V': 'goldvalley',
      '메가G': 'megagreen',
      '뉴골드': 'newgold',
      '뉴레드': 'newred',
      '핑크': 'pink',
      '렌보1': 'rainbow1',
      '렌보2': 'rainbow2',
      '렌보3': 'rainbow3',
      '렌보4': 'rainbow4',
      '렌보P': 'rainbowparadise',
      '레드': 'red',
      '레골브': 'redgoldbridge',
      '레드P': 'redparadise',
      '실버': 'silver',
      '실버P': 'silverparadise',
      '옐로우': 'yellow',
    },
    10: {
      '알파1': 'alpha1',
      '알파2': 'alpha2',
      '알파3': 'alpha3',
      '브라보1': 'bravo1',
      '브라보2': 'bravo2',
      '챌린지1': 'challenge1',
      '챌린지2': 'challenge2',
      '챌린지3': 'challenge3',
      '챌린지4': 'challenge4',
      '챌린지5': 'challenge5',
      '델타1': 'delta1',
      '델타플': 'deltaplus',
      '에코1': 'echo1',
      '에코2': 'echo2',
      '에코3': 'echo3',
      'S1': 'starexpress1',
      'S2': 'starexpress2',
    },
    11: {
      '1': '1',
      '1-1': '1-1',
      '2': '2',
      '5': '5',
      '6': '6',
      '7': '7',
    },
    12: {
      '아폴로1': 'apolo1',
      '아폴로3': 'apolo3',
      '아폴로4': 'apolo4',
      '아폴로6': 'apolo6',
      '아테나2': 'athena2',
      '아테나3': 'athena3',
      '헤라1': 'hera1',
      '헤라2': 'hera2',
      '헤라3': 'hera3',
      '빅토1': 'victoria1',
      '빅토2': 'victoria2',
      '빅토3': 'victoria3',
      '제우스1': 'zeus1',
      '제우스2': 'zeus2',
      '제우스3': 'zeus3',
      '제우3-1': 'zeus3-1',
    },
    13: {
      '챔피온': 'champion',
      '디지': 'digi',
      '도도': 'dodo',
      '듀크': 'duke',
      '환타지': 'fantasy',
      '호크1': 'hawk1',
      '호크2': 'hawk2',
      '키위': 'kiwi',
      '모글': 'mogul',
      '파노(휘)': 'panorama',
      '파라': 'paradise',
      '파크(휘)': 'park',
      '펭귄': 'penguin',
      '슬스': 'slopestyle',
      '스패': 'sparrow',
      '밸리': 'valley',
    },
  };

  // 이미지 기준 0~1 포지션
  Map<int, Map<String, Offset>> get _markerPos => {
    1: {
      'CNP1': const Offset(0.29, 0.22),
      'CNP2': const Offset(0.30, 0.68),
      'thinq1': const Offset(0.41, 0.05),
      'thinq2': const Offset(0.47, 0.62),
      'thinq3': const Offset(0.46, 0.32),
      'thinqB': const Offset(0.33, 0.47),
      'gram1': const Offset(0.48, 0.16),
      'gram2': const Offset(0.71, 0.20),
      'whynot': const Offset(0.69, 0.50),
      'whisen': const Offset(0.68, 0.90),
    },
    2: {
      'allegro':const Offset(0.45, 0.15),
      'cadenza':const Offset(0.40, 0.25),
      'connection':const Offset(0.35, 0.88),
      'eastern':const Offset(0.55, 0.77),
      'freeway':const Offset(0.75, 0.45),
      'minuet':const Offset(0.27, 0.10),
      'panorama':const Offset(0.76, 0.82),
      'polka':const Offset(0.22, 0.30),
      'raidersdown':const Offset(0.57, 0.62),
      'raidersup':const Offset(0.58, 0.47),
      'rookiehill':const Offset(0.61, 0.88),
      'silkdown':const Offset(0.15, 0.55),
      'silkroad':const Offset(0.88, 0.52),
      'silkup':const Offset(0.10, 0.20),
      'spitz':const Offset(0.35, 0.65),
      'turbo':const Offset(0.90, 0.75),
      'waltz':const Offset(0.10, 0.40),
      'western':const Offset(0.85, 0.65),
      'yamaga':const Offset(0.73, 0.68),
    },
    3: {
      'ballad': const Offset(0.43, 0.72),
      'blues': const Offset(0.78, 0.82),
      'rock': const Offset(0.33, 0.30),
      'classic': const Offset(0.10, 0.22),
      'funky': const Offset(0.36, 0.53),
      'hiphop': const Offset(0.70, 0.60),
      'jazz': const Offset(0.15, 0.62),
      'reggae': const Offset(0.15, 0.42),
      'techno1': const Offset(0.60, 0.40),
      'techno2': const Offset(0.54, 0.20),
    },
    4: {
      'alpha': const Offset(0.80, 0.40),
      'bravo': const Offset(0.65, 0.05),
      'charlie': const Offset(0.47, 0.30),
      'delta': const Offset(0.40, 0.45),
      'echo': const Offset(0.23, 0.55),
      'foxtrot': const Offset(0.10, 0.40),
    },
    6: {
      'deer': const Offset(0.45, 0.33),
      'dragon': const Offset(0.15, 0.10),
      'jaguar': const Offset(0.85, 0.70),
      'leopard': const Offset(0.68, 0.45),
      'panda': const Offset(0.15, 0.82),
      'pegasus': const Offset(0.50, 0.65),
      'puma': const Offset(0.50, 0.20),
      'rabbit': const Offset(0.10, 0.67),
      'zebra': const Offset(0.50, 0.78),

    },
    7: {
      'F': const Offset(0.64, 0.40),
      'G': const Offset(0.87, 0.50),
      'I': const Offset(0.47, 0.60),
    },
    8: {
      'challenge1': const Offset(0.15, 0.70),
      'challenge2': const Offset(0.33, 0.75),
      'challenge3': const Offset(0.35, 0.60),
      'dream1': const Offset(0.60, 0.83),
      'dream2': const Offset(0.75, 0.55),
      'glory1': const Offset(0.16, 0.86),
      'glory2': const Offset(0.36, 0.87),
      'glory3': const Offset(0.55, 0.10),
      'happy': const Offset(0.55, 0.65),
      'head': const Offset(0.37, 0.22),
      'passion1': const Offset(0.58, 0.34),
      'passion2': const Offset(0.55, 0.45),
    },
    9: {
      'blue': const Offset(0.32, 0.70),
      'dragonpark': const Offset(0.53, 0.75),
      'goldfantastic': const Offset(0.05, 0.52),
      'goldparadise': const Offset(0.30, 0.35),
      'goldvalley': const Offset(0.21, 0.28),
      'megagreen': const Offset(0.68, 0.73),
      'newgold': const Offset(0.24, 0.47),
      'newred': const Offset(0.32, 0.58),
      'pink': const Offset(0.27, 0.81),
      'rainbow1': const Offset(0.65, 0.05),
      'rainbow2': const Offset(0.75, 0.25),
      'rainbow3': const Offset(0.87, 0.35),
      'rainbow4': const Offset(0.90, 0.20),
      'rainbowparadise': const Offset(0.50, 0.20),
      'red': const Offset(0.20, 0.70),
      'redgoldbridge': const Offset(0.17, 0.41),
      'redparadise': const Offset(0.16, 0.60),
      'silver': const Offset(0.60, 0.60),
      'silverparadise': const Offset(0.45, 0.58),
      'yellow': const Offset(0.36, 0.84),
    },
    10: {
      'alpha1': const Offset(0.16, 0.80),
      'alpha2': const Offset(0.17, 0.67),
      'alpha3': const Offset(0.32, 0.72),
      'bravo1': const Offset(0.26, 0.53),
      'bravo2': const Offset(0.34, 0.46),
      'challenge1': const Offset(0.32, 0.28),
      'challenge2': const Offset(0.42, 0.14),
      'challenge3': const Offset(0.47, 0.32),
      'challenge4': const Offset(0.55, 0.45),
      'challenge5': const Offset(0.60, 0.26),
      'delta1': const Offset(0.43, 0.66),
      'deltaplus': const Offset(0.57, 0.73),
      'echo1': const Offset(0.67, 0.36),
      'echo2': const Offset(0.74, 0.20),
      'echo3': const Offset(0.85, 0.27),
      'starexpress1': const Offset(0.84, 0.10),
      'starexpress2': const Offset(0.76, 0.64),
    },
    11: {
      '1': const Offset(0.19, 0.70),
      '1-1': const Offset(0.05, 0.52),
      '2': const Offset(0.14, 0.32),
      '5': const Offset(0.47, 0.30),
      '6': const Offset(0.64, 0.40),
      '7': const Offset(0.74, 0.64),
    },
    12: {
      'apolo1': const Offset(0.74, 0.40),
      'apolo3': const Offset(0.63, 0.51),
      'apolo4': const Offset(0.49, 0.56),
      'apolo6': const Offset(0.53, 0.70),
      'athena2': const Offset(0.60, 0.85),
      'athena3': const Offset(0.40, 0.84),
      'hera1': const Offset(0.59, 0.18),
      'hera2': const Offset(0.68, 0.23),
      'hera3': const Offset(0.58, 0.34),
      'victoria1': const Offset(0.37, 0.34),
      'victoria2': const Offset(0.39, 0.20),
      'victoria3': const Offset(0.42, 0.07),
      'zeus1': const Offset(0.60, 0.05),
      'zeus2': const Offset(0.74, 0.10),
      'zeus3': const Offset(0.35, 0.50),
      'zeus3-1': const Offset(0.30, 0.73),
    },
    13: {
      'champion': const Offset(0.55, 0.22),
      'digi': const Offset(0.48, 0.34),
      'dodo': const Offset(0.11, 0.70),
      'duke': const Offset(0.06, 0.57),
      'fantasy': const Offset(0.55, 0.45),
      'hawk1': const Offset(0.52, 0.76),
      'hawk2': const Offset(0.55, 0.59),
      'kiwi': const Offset(0.12, 0.42),
      'mogul': const Offset(0.23, 0.60),
      'panorama': const Offset(0.73, 0.08),
      'paradise': const Offset(0.75, 0.31),
      'park': const Offset(0.64, 0.71),
      'penguin': const Offset(0.40, 0.70),
      'slopestyle': const Offset(0.20, 0.76),
      'sparrow': const Offset(0.78, 0.56),
      'valley': const Offset(0.34, 0.12),
    },
  };

  late ScrollController _scrollController;
  bool isScrolled = false;


  @override
  void initState() {
    super.initState();

    final fav = _userViewModel.user.favorite_resort; // 필요하면 ?. 로 처리
    selectedResortId = (fav == 0 ? 1 : fav);         // 스펙에 맞춰 폴백

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _slopeRushViewModel.fetchSlopeRush(resort_id: selectedResortId);
      await _precacheDefaultMap(selectedResortId);
    });

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !isScrolled) {
        setState(() => isScrolled = true);
      } else if (_scrollController.offset <= 100 && isScrolled) {
        setState(() => isScrolled = false);
      }
    });

  }

  Future<void> _precacheDefaultMap(int resortId) async {
    final slug = _resortSlug[resortId];
    if (slug == null) return;
    final path = 'assets/imgs/imgs/slopeRush/$slug/${slug}_default.png';
    try {
      await precacheImage(AssetImage(path), context);
    } catch (_) {}
  }

  // 현재 선택된 키를 사람이 읽을 수 있는 슬로프명으로
// 현재 선택된 키를 사람이 읽을 수 있는 슬로프명으로
  String _selectedSlopeDisplayName() {
    final key = selectedSlopeKey;
    if (key == null) return '슬로프명';

    // 1️⃣ 먼저 _slopeRushViewModel.items 안에서 매칭된 데이터 찾기
    for (final s in _slopeRushViewModel.items) {
      final k = _slopeKeyOf(s);
      if (k == key) {
        return s.slopeNickname.isNotEmpty ? s.slopeNickname : s.slopeFullname;
      }
    }

    // 2️⃣ 데이터가 없으면, key를 한글명으로 변환해서 반환
    final table = _slopeKeyByResort[selectedResortId] ?? const {};
    for (final entry in table.entries) {
      if (entry.value == key) return entry.key; // 예: 'allegro' → '알레그로'
    }

    // 3️⃣ 그래도 못 찾으면 그대로 반환 (fallback)
    return key;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFC9DEE9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: AppBar(
          backgroundColor:
          isScrolled ? Colors.white : const Color(0xFFC9DEE9),
          elevation: isScrolled ? 0 : 0,
          shadowColor: isScrolled ? Colors.black.withOpacity(0.05) : Colors.transparent,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  IconButton(
                    highlightColor: Colors.transparent,
                    onPressed: () async{
                      HapticFeedback.lightImpact();
                      Get.toNamed(AppRoutes.slopeRushHistoryHome);
                    },
                    icon: Image.asset(
                      'assets/imgs/icons/ic_header_history.png',
                      width: 26,
                      height: 26,
                    ),
                  ),
                ],
              ),
            ),
          ],
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
              color: isScrolled ? SDSColor.gray900 : null, // 🔥 스크롤 시 아이콘 색 변경
            ),
            onTap: () => Get.back(),
          ),

          title: Text(
            '슬로프크래프트',
            style: SDSTextStyle.extraBold.copyWith(
              fontSize: 18,
              color: isScrolled ? SDSColor.gray900 : SDSColor.gray900.withOpacity(0.9),
            ),
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: _refreshCurrentResort,      // ✅ 아래로 당기면 현재 리조트 재조회
        displacement: 72,                      // 인디케이터 위치(옵션)
        edgeOffset: 0,                         // 앱바 아래 바로 시작
        child: Obx(() {
          final items = _slopeRushViewModel.items.toList();
          final loading = _slopeRushViewModel.isLoading.value;

          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(), // ✅ 리스트가 짧아도 당길 수 있게
            slivers: [
              // ⬇️ 상단(필터+지도) 하늘색 구역
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFFC9DEE9),
                  child: Column(
                    children: [
                      _buildCapsuleFilter(),
                      SizedBox(
                        height: 6,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: _buildMapSection(items),
                      ),
                    ],
                  ),
                ),
              ),
              // 안내 텍스트
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 20),
                  child: Center(
                    child: Text(
                      '슬로프에서 가장 최근 라이딩 횟수 500회 기준으로 계산',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 12,
                        color: SDSColor.gray500,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: SDSColor.snowliveWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  )
              ),
              // 로딩/빈상태/리스트
              if (loading)
                _buildSlopeListSkeleton()
              else if (items.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    height: 400,
                    color: Colors.white,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('데이터가 없습니다.',
                        style: TextStyle(
                          color: Color(0xFF949494),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: SDSColor.snowliveWhite,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _buildSlopeRow(items[index]);
                        },
                        separatorBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: SDSColor.snowliveWhite,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),

    );
  }


// ---------------------------
// 상단 캡슐 필터 UI (아이콘이 리조트명 바로 우측에 붙도록 수정)
// ---------------------------
  Widget _buildCapsuleFilter() {
    final pillColor = Colors.white;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: pillColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // 리조트 드롭다운: 컨텐츠만큼만 너비를 차지하게 해서
            // 아이콘이 리조트명 바로 오른쪽에 위치
            IntrinsicWidth(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedResortId,
                  isDense: true,
                  isExpanded: false,
                  borderRadius: BorderRadius.circular(16),
                  dropdownColor: Color(0xFFFFFFFF),
                  // 🔸 기본 icon 제거 (우리가 직접 붙일거라)
                  icon: const SizedBox.shrink(),

                  // 🔸 닫힌 상태의 위젯을 직접 커스텀
                  selectedItemBuilder: (context) {
                    return resortOptions.map((r) {
                      final name = r['name'] as String;
                      return Row(
                        mainAxisSize: MainAxisSize.min,  // 🔥 텍스트 길이만큼만 너비
                        children: [
                          Text(
                            name,
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 15,
                              color: SDSColor.gray900,
                            ),
                          ),

                          const SizedBox(width: 2),  // 🔥 텍스트와 아이콘 간격
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                        ],
                      );
                    }).toList();
                  },

                  items: resortOptions
                      .map((r) => DropdownMenuItem<int>(
                    value: r['id'] as int,
                    child: Text(
                      r['name'] as String,
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 15,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ))
                      .toList(),

                  onChanged: (id) async {
                    if (id == null) return;
                    setState(() {
                      selectedResortId = id;
                      selectedSlopeKey = null;
                    });
                    await _precacheDefaultMap(id);
                    await _slopeRushViewModel.fetchSlopeRush(resort_id: id);
                  },
                ),
              ),
            ),

            Spacer(),

            // 선택된 슬로프명 표시 (없으면 '슬로프명')
            GestureDetector(
              onTap: () => setState(() => selectedSlopeKey = null),
              child: Text(
                _selectedSlopeDisplayName(),
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 15,
                  color: SDSColor.snowliveBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ---------------------------
  // 지도 섹션
  // ---------------------------
  Widget _buildMapSection(List<SlopeRushItem> items) {
    final slug = _resortSlug[selectedResortId];
    if (slug == null) return const SizedBox();

    final defaultPath = 'assets/imgs/imgs/slopeRush/$slug/${slug}_default.png';
    final highlightPath = selectedSlopeKey == null
        ? null
        : 'assets/imgs/imgs/slopeRush/$slug/${slug}_${selectedSlopeKey!}.png';
    final posMap = _markerPos[selectedResortId] ?? const {};

    return AspectRatio(
      aspectRatio: 780 / 900,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final markers = <Widget>[];

      // key ↔ 표시명 역변환(예: 'allegro' → '알레그로')
          final keyMap = _slopeKeyByResort[selectedResortId] ?? const {};
          String displayNameFromKey(String key) {
            for (final e in keyMap.entries) {
              if (e.value == key) return e.key;
            }
            return key;
          }

      // items에서 키로 매칭되는 슬로프 찾기
          SlopeRushItem? findItemByKey(String key) {
            for (final s in items) {
              final k = _slopeKeyOf(s);
              if (k == key) return s;
            }
            return null;
          }

      // ✅ posMap 기준 모든 슬로프 마커 생성 (데이터 없어도 표시)
          for (final entry in (posMap.entries)) {
            final key = entry.key;   // ex) 'allegro'
            final pos = entry.value;

            final matched = findItemByKey(key);
            final leader  = matched == null ? null : _leaderOf(matched);
            final isLoading = _slopeRushViewModel.isLoading.value;


            // ▶ 미점령/데이터 없음이면 '미점령'만 표시
            final bool unclaimed = (matched == null) || (leader == null);

            final label = unclaimed
                ? '미점령'
                : (matched!.slopeNickname.isNotEmpty ? matched.slopeNickname : matched.slopeFullname);

            final left = (pos.dx * w) - 12;
            final top  = (pos.dy * h) - 12;

            markers.add(
              Positioned(
                left: left,
                top: top,
                child: _Marker(
                  selected: selectedSlopeKey == key,
                  leader: unclaimed ? null : leader,
                  label: label,
                  onTap: () {
                    if (isLoading) return; // 로딩 중이면 탭 동작 막고 싶으면 넣기
                    if (!unclaimed && matched != null) {
                      _onMarkerTap(key, matched);
                    } else {
                      setState(() => selectedSlopeKey = key);
                    }
                  },
                  isLoading: isLoading,   // 🔥 여기서 연결된다
                ),
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Color(0xFFC9DEE9), // 원하는 색상으로 변경 가능
              ),
              Image.asset(defaultPath, fit: BoxFit.cover),
              if (highlightPath != null)
                Image.asset(highlightPath, fit: BoxFit.cover),
              ...markers,
            ],
          );
        },
      ),
    );
  }

  // ---------------------------
  // 마커 탭 → 하이라이트 & 상세
  // ---------------------------
  Future<void> _onMarkerTap(String slopeKey, SlopeRushItem slope) async {
    final slug = _resortSlug[selectedResortId];
    if (slug == null) return;
    final highlight =
        'assets/imgs/imgs/slopeRush/$slug/${slug}_$slopeKey.png';
    try {
      await precacheImage(AssetImage(highlight), context);
    } catch (_) {}
    setState(() => selectedSlopeKey = slopeKey);
    _showSlopeDetail(slope);
  }

  // 현재 점령(1위) 크루
  SlopeCrew? _leaderOf(SlopeRushItem slope) {
    if (slope.crews.isEmpty) return null;
    final sorted = [...slope.crews]..sort((a, b) => b.ratio.compareTo(a.ratio));
    return sorted.first;
  }

  // 서버 슬로프명 → 이미지키
  String? _slopeKeyOf(SlopeRushItem slope) {
    final table = _slopeKeyByResort[selectedResortId] ?? const {};
    final name =
    slope.slopeNickname.isNotEmpty ? slope.slopeNickname : slope.slopeFullname;
    return table[name];
  }

  // ---------------------------
  // 리스트 카드 (슬로프명 + 1위 크루 표시)
  // ---------------------------
  Widget _buildSlopeRow(SlopeRushItem slope) {
    final leader = _leaderOf(slope);
    final slopeName =
    slope.slopeNickname.isNotEmpty ? slope.slopeNickname : slope.slopeFullname;

    return InkWell(
      onTap: () {
        final key = _slopeKeyOf(slope);
        if (key != null) _onMarkerTap(key, slope);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leader != null)
              Row(
                children: [
                  // 슬로프명
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Container(
                      width: 50,
                      child: Text(
                        slopeName,
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 14,
                          color: SDSColor.gray900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Get.toNamed(AppRoutes.crewMain);
                      await _crewMemberListViewModel.fetchCrewMembers(crewId: leader.crewId!);
                      await _crewDetailViewModel.fetchCrewDetail(
                          leader.crewId!,
                          _friendDetailViewModel.seasonDate
                      );
                    },
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: leader.crewLogoUrl.isNotEmpty
                          ? ExtendedImage.network(
                        leader.crewLogoUrl,
                        cache: true,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                          color: Colors.grey[300]!,
                        ),
                        width: 36,
                        height: 36,
                        cacheHeight: 200, // 필요 없으면 지워도 됨
                        fit: BoxFit.cover,
                        loadStateChanged: (ExtendedImageState state) {
                          switch (state.extendedImageLoadState) {
                            case LoadState.loading:
                            // 로딩 중 스켈레톤
                              return Shimmer.fromColors(
                                baseColor: SDSColor.gray200,
                                highlightColor: SDSColor.gray50,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            case LoadState.completed:
                            // 로딩 완료 시 이미지
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: state.completedWidget,
                              );
                            case LoadState.failed:
                            // 실패 시 기본 아이콘
                              return Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.group,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              );
                          }
                        },
                      )
                          : Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.group,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leader.crewName,
                          style: SDSTextStyle.regular.copyWith(fontSize: 14, height: 1.2,),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          leader.description,
                          style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      "${(leader.ratio * 100).toStringAsFixed(1)}%",
                      style: SDSTextStyle.bold.copyWith(
                        color: SDSColor.snowliveBlack,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                '점령중인 크루 없음',
                style: SDSTextStyle.regular.copyWith(
                  color: SDSColor.gray500,
                ),
              ),
          ],
        ),
      ),
    );
  }



  // ---------------------------
  // 바텀싯: 크루 상세 (화면 절반)
  // ---------------------------
  void _showSlopeDetail(SlopeRushItem slope) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final sorted = [...slope.crews]..sort((a, b) => b.ratio.compareTo(a.ratio));

        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: SDSColor.gray200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${slope.slopeNickname.isNotEmpty ? slope.slopeNickname : slope.slopeFullname} 점령 현황',
                      style: SDSTextStyle.bold.copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: sorted.length,
                      itemBuilder: (context, i) {
                        final c = sorted[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () async{
                                  Get.toNamed(AppRoutes.crewMain);
                                  await _crewMemberListViewModel.fetchCrewMembers(crewId: c.crewId!);
                                  await _crewDetailViewModel.fetchCrewDetail(
                                      c.crewId!,
                                      _friendDetailViewModel.seasonDate
                                  );
                                },
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: c.crewLogoUrl.isNotEmpty
                                      ? ExtendedImage.network(
                                    c.crewLogoUrl,
                                    cache: true,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.grey[300]!,
                                    ),
                                    width: 40,
                                    height: 40,
                                    cacheHeight: 240, // 필요하면 제거 가능
                                    fit: BoxFit.cover,
                                    loadStateChanged: (ExtendedImageState state) {
                                      switch (state.extendedImageLoadState) {
                                        case LoadState.loading:
                                          return Shimmer.fromColors(
                                            baseColor: SDSColor.gray200!,
                                            highlightColor: SDSColor.gray50!,
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          );

                                        case LoadState.completed:
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: state.completedWidget,
                                          );

                                        case LoadState.failed:
                                          return Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.group,
                                              color: Colors.grey,
                                              size: 18,
                                            ),
                                          );
                                      }
                                    },
                                  )
                                      : Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.group,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.crewName,
                                      style: SDSTextStyle.regular.copyWith(
                                          fontSize: 14
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      c.description,
                                      style: SDSTextStyle.regular
                                          .copyWith(color: SDSColor.gray500,
                                      fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                  "${(c.ratio * 100).toStringAsFixed(1)}%",
                                  style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveBlack, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  // ==== Pull-to-Refresh: 현재 선택된 리조트 데이터 재조회 ====
  Future<void> _refreshCurrentResort() async {
    // 필요시 캐시 무시 옵션이 있으면 추가: force: true 같은 파라미터
    await _slopeRushViewModel.fetchSlopeRush(resort_id: selectedResortId);
    await _precacheDefaultMap(selectedResortId);
    // 선택된 슬로프 하이라이트는 유지 (리셋 원하면 아래 주석 해제)
    // setState(() => selectedSlopeKey = null);
    setState(() {}); // UI 갱신
  }


// 스켈레톤 로딩
  SliverToBoxAdapter _buildSlopeListSkeleton() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // 슬로프명 영역 스켈레톤
                        Container(
                          width: 50,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 크루 로고 스켈레톤(정사각형 아바타)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 크루명 + 설명 영역 스켈레톤
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14,
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                height: 12,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // 비율(%) 영역 스켈레톤
                        Container(
                          width: 40,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }




}

// =======================
// 마커 (아바타 ↑ / 크루명 ↓)
// =======================
class _Marker extends StatelessWidget {
  final bool selected;
  final SlopeCrew? leader;
  final String label;
  final VoidCallback onTap;

  /// 🔥 추가: 로딩 상태 플래그
  final bool isLoading;

  const _Marker({
    required this.selected,
    required this.leader,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 로딩 중이면 스켈레톤 UI로 대체
    if (isLoading) {
      return _buildSkeletonMarker();
    }

    final bool unclaimed = leader == null;
    final crewName = unclaimed ? '미점령' : leader!.crewName;
    final crewLogo = unclaimed ? '' : leader!.crewLogoUrl;


    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ 이 줄 추가!!
        children: [
          // 🔹 프로필 이미지 (이제 미점령이어도 항상 표시)
          Container(
            width: selected ? 36 : 24,
            height: selected ? 36 : 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.black12,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: crewLogo.isNotEmpty
                  ? ExtendedImage.network(
                crewLogo,
                cache: true,
                width: selected ? 36 : 24,
                height: selected ? 36 : 24,
                fit: BoxFit.cover,
                loadStateChanged: (ExtendedImageState state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[200]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: selected ? 36 : 24,
                          height: selected ? 36 : 24,
                          color: Colors.white,
                        ),
                      );
                    case LoadState.completed:
                      return state.completedWidget;
                    case LoadState.failed:
                      return Container(
                        width: selected ? 36 : 24,
                        height: selected ? 36 : 24,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.group,
                          size: 14,
                          color: Colors.grey,
                        ),
                      );
                  }
                },
              )
                  : const Icon(
                Icons.group,
                size: 14,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 2),

          // 🔹 라벨 캡슐 (미점령 포함 항상 표시)
          Container(
            constraints: const BoxConstraints(
              maxWidth: 38,   // ← 🔥 캡슐 최대 너비 제한
            ),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: selected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: selected ? Colors.black26 : Colors.black26,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              crewName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: selected
                    ? Colors.white
                    : (unclaimed ? Colors.grey[500] : Colors.black),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 마커용 스켈레톤 (로딩 상태에서만 사용)
  Widget _buildSkeletonMarker() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ 이 줄 추가!!
        children: [
          // 동그란 아바타 스켈레톤
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // 라벨 캡슐 스켈레톤
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const SizedBox(
              width: 20,
              height: 10,
            ),
          ),
        ],
      ),
    );
  }
}




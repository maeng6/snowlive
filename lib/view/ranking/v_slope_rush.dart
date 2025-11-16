import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_slope_rush.dart';
import 'package:com.snowlive/model/m_slolpe_rush.dart';

class SlopeRushHomeView extends StatefulWidget {
  const SlopeRushHomeView({super.key});

  @override
  State<SlopeRushHomeView> createState() => _SlopeRushHomeViewState();
}

class _SlopeRushHomeViewState extends State<SlopeRushHomeView> {
  final SlopeRushViewModel _slopeRushViewModel = Get.put(SlopeRushViewModel());

  int selectedResortId = 1;
  String? selectedSlopeKey; // 예: 'CNP1', 'thinq2' …

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
    3: 'vivaldi',
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
    13: {
      'champion': const Offset(0.55, 0.22),
      'digi': const Offset(0.48, 0.34),
      'dodo': const Offset(0.10, 0.75),
      'duke': const Offset(0.04, 0.55),
      'fantasy': const Offset(0.55, 0.45),
      'hawk1': const Offset(0.55, 0.86),
      'hawk2': const Offset(0.55, 0.59),
      'kiwi': const Offset(0.05, 0.43),
      'mogul': const Offset(0.20, 0.65),
      'panorama': const Offset(0.73, 0.08),
      'paradise': const Offset(0.76, 0.35),
      'park': const Offset(0.64, 0.71),
      'penguin': const Offset(0.40, 0.75),
      'slopestyle': const Offset(0.19, 0.85),
      'sparrow': const Offset(0.80, 0.52),
      'valley': const Offset(0.35, 0.10),
    },
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _slopeRushViewModel.fetchSlopeRush(resort_id: selectedResortId);
      await _precacheDefaultMap(selectedResortId);
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
  String _selectedSlopeDisplayName() {
    final key = selectedSlopeKey;
    if (key == null) return '슬로프명';
    // vm.items 에서 매칭 검색
    for (final s in _slopeRushViewModel.items) {
      final k = _slopeKeyOf(s);
      if (k == key) {
        return s.slopeNickname.isNotEmpty ? s.slopeNickname : s.slopeFullname;
      }
    }
    // 없으면 키 그대로
    return key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF5FF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              Get.back();
            },
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Text(
              '슬로프 러쉬',
              style: SDSTextStyle.extraBold.copyWith(
                color: SDSColor.gray900,
                fontSize: 18,
              ),
            ),
          ),
          centerTitle: true,
          titleSpacing: 0,
          backgroundColor: Color(0xFFEFF5FF),
          foregroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
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
            physics: const AlwaysScrollableScrollPhysics(), // ✅ 리스트가 짧아도 당길 수 있게
            slivers: [
              // ⬇️ 상단(필터+지도) 하늘색 구역
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFFEFF5FF),
                  child: Column(
                    children: [
                      _buildCapsuleFilter(),
                      _buildMapSection(items),
                    ],
                  ),
                ),
              ),

              // 안내 텍스트
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              // 로딩/빈상태/리스트
              if (loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (items.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('데이터가 없습니다.')),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _buildSlopeCard(items[index]),
                    ),
                    childCount: items.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: pillColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
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
                  isExpanded: false, // ★ 중요: 가로 전체 차지 금지
                  borderRadius: BorderRadius.circular(16),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  items: resortOptions
                      .map((r) => DropdownMenuItem<int>(
                    value: r['id'] as int,
                    child: Text(
                      r['name'] as String,
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 14,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ))
                      .toList(),
                  onChanged: (id) async {
                    if (id == null) return;
                    setState(() {
                      selectedResortId = id;
                      selectedSlopeKey = null; // 하이라이트 리셋
                    });
                    await _precacheDefaultMap(id);
                    await _slopeRushViewModel.fetchSlopeRush(resort_id: id);
                  },
                ),
              ),
            ),

            const Spacer(),

            // 선택된 슬로프명 표시 (없으면 '슬로프명')
            GestureDetector(
              onTap: () => setState(() => selectedSlopeKey = null),
              child: Text(
                _selectedSlopeDisplayName(),
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF5B7CFF),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final markers = <Widget>[];

            for (final slope in items) {
              final key = _slopeKeyOf(slope);
              final pos = key == null ? null : posMap[key];
              if (pos == null) continue;

              final left = (pos.dx * w) - 12;
              final top = (pos.dy * h) - 12;
              final leader = _leaderOf(slope);

              markers.add(Positioned(
                left: left,
                top: top,
                child: _Marker(
                  selected: selectedSlopeKey == key,
                  leader: leader,
                  label: slope.slopeNickname.isNotEmpty
                      ? slope.slopeNickname
                      : slope.slopeFullname,
                  onTap: () {
                    if (key != null) _onMarkerTap(key, slope);
                  },
                ),
              ));
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: const Color(0xFFEFF5FF), // 원하는 색상으로 변경 가능
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(defaultPath, fit: BoxFit.cover),
                ),
                if (highlightPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(highlightPath, fit: BoxFit.cover),
                  ),
                ...markers,
              ],
            );
          },
        ),
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
  Widget _buildSlopeCard(SlopeRushItem slope) {
    final leader = _leaderOf(slope);
    final slopeName =
    slope.slopeNickname.isNotEmpty ? slope.slopeNickname : slope.slopeFullname;

    return GestureDetector(
      onTap: () {
        final key = _slopeKeyOf(slope);
        if (key != null) _onMarkerTap(key, slope);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SDSColor.snowliveWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 슬로프명 (카드 상단에 명확히 표시)
            Text(
              slopeName,
              style: SDSTextStyle.bold.copyWith(
                fontSize: 15,
                color: SDSColor.gray900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            if (leader != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: leader.crewLogoUrl.isNotEmpty
                        ? NetworkImage(leader.crewLogoUrl)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: leader.crewLogoUrl.isEmpty
                        ? const Icon(Icons.group, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      leader.crewName,
                      style: SDSTextStyle.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "${(leader.ratio * 100).toStringAsFixed(1)}%",
                    style: SDSTextStyle.bold
                        .copyWith(color: SDSColor.snowliveBlack),
                  ),
                ],
              )
            else
              Text(
                '점령중인 크루 없음',
                style: SDSTextStyle.regular.copyWith(color: SDSColor.gray500),
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
          heightFactor: 0.5,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: SDSColor.gray200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${slope.slopeNickname.isNotEmpty ? slope.slopeNickname : slope.slopeFullname} 점령 현황',
                      style: SDSTextStyle.bold.copyWith(fontSize: 18),
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
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: c.crewLogoUrl.isNotEmpty
                                    ? NetworkImage(c.crewLogoUrl)
                                    : null,
                                backgroundColor: Colors.grey[200],
                                child: c.crewLogoUrl.isEmpty
                                    ? const Icon(Icons.group, color: Colors.grey)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  c.crewName,
                                  style: SDSTextStyle.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "${(c.ratio * 100).toStringAsFixed(1)}%",
                                style: SDSTextStyle.bold
                                    .copyWith(color: SDSColor.snowliveBlack),
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


}

// =======================
// 마커 (아바타 ↑ / 크루명 ↓)
// =======================
class _Marker extends StatelessWidget {
  final bool selected;
  final SlopeCrew? leader;
  final String label;
  final VoidCallback onTap;

  const _Marker({
    required this.selected,
    required this.leader,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final crewName = leader?.crewName ?? label;
    final crewLogo = leader?.crewLogoUrl ?? '';

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: selected ? const Color(0xFF5B7CFF) : Colors.black12,
                width: selected ? 2 : 1,
              ),
            ),
            child: ClipOval(
              child: crewLogo.isNotEmpty
                  ? Image.network(crewLogo, fit: BoxFit.cover)
                  : const Icon(Icons.group, size: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFF5B7CFF) : Colors.black12,
              ),
            ),
            child: Text(
              crewName,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

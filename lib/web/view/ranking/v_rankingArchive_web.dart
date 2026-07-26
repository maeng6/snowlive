import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rankingListCrew_recordRoom.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv_recordRoom.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList.dart' show RankingFilter_resort, RankingFilter_fed;
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart' show RankingFilter_season;
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/view/ranking/v_rankingHome_web.dart'
    show kRankingContentMaxWidth, kRankingResortIds, kRankingSelectableResorts, kRankingSelectableFeds;
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingArchiveCrew_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingArchiveIndiv_web.dart';
import 'package:com.snowlive/web/widget/w_numbered_pagination_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum _ArchiveTab { individual, crew }

/// 웹 "랭킹 기록실" — 지난 시즌 개인/크루 랭킹 기록을 번호식 페이지네이션으로 본다.
/// 라이브 랭킹 화면(RankingHomeViewWeb)과 같은 골격이되, 시즌 선택 필터가 추가되고
/// 누적/일간 토글은 없다(기록실은 시즌 누적 기록만 다룬다).
class RankingArchiveViewWeb extends StatefulWidget {
  const RankingArchiveViewWeb({super.key});

  @override
  State<RankingArchiveViewWeb> createState() => _RankingArchiveViewWebState();
}

class _RankingArchiveViewWebState extends State<RankingArchiveViewWeb> {
  final RankingArchiveIndivViewModelWeb _vm = Get.find<RankingArchiveIndivViewModelWeb>();
  final RankingArchiveCrewViewModelWeb _crewVm = Get.find<RankingArchiveCrewViewModelWeb>();
  final _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  _ArchiveTab _tab = _ArchiveTab.individual;
  RankingFilter_season _selectedSeason = RankingFilter_season.season2526;
  RankingFilter_resort _selectedResort = RankingFilter_resort.total;
  RankingFilter_fed _selectedFed = RankingFilter_fed.initial;

  /// 1280px 이상에서는 검색창이 타이틀 오른쪽 같은 줄에 놓인다 (다른 웹 화면과 동일).
  static const double _wideLayoutBreakpoint = 1280;

  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload();
    });
    // 자동로그인 확인이 최초 조회보다 늦게 끝나면 첫 조회가 user_id 없이 나가서
    // 서버가 내 랭킹 정보를 안 준다. 로그인 확정 시 한 번 더 조회한다(랭킹 화면과 동일).
    _authWorker = ever<WebAuthStatus>(
      Get.find<AuthCheckViewModelWeb>().statusRx,
      (status) {
        if (status == WebAuthStatus.authenticated && mounted) _reload();
      },
    );
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  int? get _resortId => _selectedResort == RankingFilter_resort.total ? null : kRankingResortIds[_selectedResort];
  String? get _federation => _selectedFed == RankingFilter_fed.initial ? null : _selectedFed.english;

  void _reload() {
    final season = _selectedSeason.dbSeason;
    if (_tab == _ArchiveTab.individual) {
      _vm.loadFirstPage(season: season, resortId: _resortId, federation: _federation);
    } else {
      _crewVm.loadFirstPage(season: season, resortId: _resortId, federation: _federation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isWide = MediaQuery.sizeOf(context).width >= _wideLayoutBreakpoint;

    return Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(isDesktop ? SDSSpacing.xl : SDSSpacing.md, 32, isDesktop ? SDSSpacing.xl : SDSSpacing.md, SDSSpacing.xl),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kRankingContentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTitleRow(),
                      const SizedBox(width: SDSSpacing.lg),
                      Expanded(child: _buildSearchBar()),
                    ],
                  )
                else ...[
                  _buildTitleRow(),
                  const SizedBox(height: SDSSpacing.md),
                  _buildSearchBar(),
                ],
                const SizedBox(height: SDSSpacing.md),
                _buildTabAndFilterRow(),
                const SizedBox(height: SDSSpacing.lg),
                // 아래 여백은 카드 안(margin)에 있어서, 카드가 숨겨지면 여백도 같이 사라진다.
                _tab == _ArchiveTab.individual ? _buildMyRankingCard() : _buildMyCrewRankingCard(),
                _tab == _ArchiveTab.individual ? _buildIndivList() : _buildCrewList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.arrow_back, size: 24, color: SDSColor.gray900),
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        Text('랭킹 기록실', style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: SDSColor.gray400),
          const SizedBox(width: 8),
          Expanded(
            // TODO: 백엔드가 랭킹 검색을 지원하면 활성화한다(랭킹 화면과 동일한 사유).
            child: TextField(
              controller: _searchController,
              enabled: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '유저 검색 준비 중',
                hintStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
              ),
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
        ],
      ),
    );
  }

  /// 크루/개인 탭 + 시즌·리조트·리그 필터를 한 줄에 배치. 좁은 화면에서는 Wrap으로 접힌다.
  Widget _buildTabAndFilterRow() {
    return Row(
      children: [
        _TabLabel(
          label: '크루랭킹',
          isActive: _tab == _ArchiveTab.crew,
          onTap: () => setState(() { _tab = _ArchiveTab.crew; _reload(); }),
        ),
        const SizedBox(width: 12),
        Text('|', style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray200)),
        const SizedBox(width: 12),
        _TabLabel(
          label: '개인랭킹',
          isActive: _tab == _ArchiveTab.individual,
          onTap: () => setState(() { _tab = _ArchiveTab.individual; _reload(); }),
        ),
        const Spacer(),
        FleamarketFilterPill(
          label: '${_selectedSeason.korean.replaceAll('시즌', '')} 시즌',
          isActive: true,
          onTap: () => showFleamarketFilterSheet<RankingFilter_season>(
            context,
            values: RankingFilter_season.values,
            labelOf: (v) => v.korean,
            onSelected: (v) => setState(() {
              _selectedSeason = v;
              _reload();
            }),
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        FleamarketFilterPill(
          label: _selectedResort == RankingFilter_resort.total ? '전체 스키장' : _selectedResort.korean,
          isActive: _selectedResort != RankingFilter_resort.total,
          onTap: () => showFleamarketFilterSheet<RankingFilter_resort>(
            context,
            values: [RankingFilter_resort.total, ...kRankingSelectableResorts],
            labelOf: (v) => v == RankingFilter_resort.total ? '전체 스키장' : v.korean,
            onSelected: (v) => setState(() {
              _selectedResort = v;
              _selectedFed = RankingFilter_fed.initial;
              _reload();
            }),
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        FleamarketFilterPill(
          label: _selectedFed == RankingFilter_fed.initial ? '대학 리그' : _selectedFed.korean,
          isActive: _selectedFed != RankingFilter_fed.initial,
          onTap: () => showFleamarketFilterSheet<RankingFilter_fed>(
            context,
            values: kRankingSelectableFeds,
            labelOf: (v) => v.korean,
            onSelected: (v) => setState(() {
              _selectedFed = v;
              _selectedResort = RankingFilter_resort.total;
              _reload();
            }),
          ),
        ),
      ],
    );
  }

  bool get _isResortScoped => _selectedResort != RankingFilter_resort.total;

  Widget _buildMyRankingCard() {
    return Obx(() {
      final my = _vm.myRankingInfo;
      if (my == null) return const SizedBox.shrink();
      return Container(
        // 카드가 숨겨질 때 아래 여백까지 같이 사라지도록 간격을 카드 안에 둔다.
        margin: const EdgeInsets.only(bottom: SDSSpacing.xl),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Text('내 랭킹', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
            const Spacer(),
            _MyStat(label: '개인 점수', value: '${_isResortScoped ? my.resortTotalScore : my.overallTotalScore}'),
            Container(width: 1, height: 32, color: SDSColor.gray200, margin: const EdgeInsets.symmetric(horizontal: SDSSpacing.lg)),
            _MyStat(label: '개인 랭킹', value: '${_isResortScoped ? my.resortRank : my.overallRank}'),
            if (!_isResortScoped) ...[
              Container(width: 1, height: 32, color: SDSColor.gray200, margin: const EdgeInsets.symmetric(horizontal: SDSSpacing.lg)),
              Text(my.tierNameKor ?? '', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
              if (my.overallTierIconUrl?.isNotEmpty ?? false) ...[
                const SizedBox(width: 8),
                WebNetworkImage(url: my.overallTierIconUrl, width: 28, height: 28, fit: BoxFit.contain),
              ],
            ],
          ],
        ),
      );
    });
  }

  Widget _buildMyCrewRankingCard() {
    return Obx(() {
      // 로그인 여부를 Obx 바깥에서 검사하면 로그인 확정 시점에 다시 그려지지 않는다.
      // 소속 크루가 없으면 뷰모델이 null로 정규화해주므로 데이터 유무만 보고 판단한다.
      final my = _crewVm.myCrewRankingInfo;
      if (my == null) return const SizedBox.shrink();
      return Container(
        // 카드가 숨겨질 때 아래 여백까지 같이 사라지도록 간격을 카드 안에 둔다.
        margin: const EdgeInsets.only(bottom: SDSSpacing.xl),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Text('내 크루 랭킹', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
            const Spacer(),
            _MyStat(label: '크루 점수', value: '${_isResortScoped ? my.resortTotalScore : my.overallTotalScore}'),
            Container(width: 1, height: 32, color: SDSColor.gray200, margin: const EdgeInsets.symmetric(horizontal: SDSSpacing.lg)),
            _MyStat(label: '크루 랭킹', value: '${_isResortScoped ? my.resortRank : my.overallRank}'),
          ],
        ),
      );
    });
  }

  Widget _buildIndivList() {
    return Obx(() {
      final items = _vm.items;
      if (_vm.isLoading && items.isEmpty) {
        return const RankingListSkeleton();
      }
      if (items.isEmpty) return _emptyState();

      return _twoColumnList(
        count: items.length,
        rowAt: (i) => _buildIndivRow(items[i]),
        currentPage: _vm.currentPage,
        totalPages: _vm.totalPages,
        hasPrevious: _vm.hasPrevious,
        hasNext: _vm.hasNext,
        pageWindow: _vm.pageWindow(),
        onGotoPage: _vm.gotoPage,
      );
    });
  }

  Widget _buildCrewList() {
    return Obx(() {
      final items = _crewVm.items;
      if (_crewVm.isLoading && items.isEmpty) {
        return const RankingListSkeleton();
      }
      if (items.isEmpty) return _emptyState();

      return _twoColumnList(
        count: items.length,
        rowAt: (i) => _buildCrewRow(items[i]),
        currentPage: _crewVm.currentPage,
        totalPages: _crewVm.totalPages,
        hasPrevious: _crewVm.hasPrevious,
        hasNext: _crewVm.hasNext,
        pageWindow: _crewVm.pageWindow(),
        onGotoPage: _crewVm.gotoPage,
      );
    });
  }

  Widget _emptyState() => const WebEmptyState(message: '해당 시즌의 랭킹 기록이 없습니다.');

  /// 데스크탑에서는 2단, 좁은 화면에서는 1단으로 목록을 나눠 그린다.
  Widget _twoColumnList({
    required int count,
    required Widget Function(int index) rowAt,
    required int currentPage,
    required int totalPages,
    required bool hasPrevious,
    required bool hasNext,
    required List<int> pageWindow,
    required Future<void> Function(int page) onGotoPage,
  }) {
    final isDesktop = context.isDesktop;
    final half = isDesktop ? (count / 2).ceil() : count;

    return Column(
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [for (int i = 0; i < half; i++) rowAt(i)])),
              const SizedBox(width: SDSSpacing.xl),
              Expanded(child: Column(children: [for (int i = half; i < count; i++) rowAt(i)])),
            ],
          )
        else
          Column(children: [for (int i = 0; i < count; i++) rowAt(i)]),
        const SizedBox(height: SDSSpacing.lg),
        NumberedPaginationBar(
          currentPage: currentPage,
          totalPages: totalPages,
          hasPrevious: hasPrevious,
          hasNext: hasNext,
          pageWindow: pageWindow,
          onGotoPage: onGotoPage,
        ),
      ],
    );
  }

  Widget _buildIndivRow(RankingUser_recordRoom user) {
    return Obx(() {
      final query = _searchQuery.value;
      final isHighlighted = query.isNotEmpty && (user.displayName?.contains(query) ?? false);
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isHighlighted ? SDSColor.blue50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '${_isResortScoped ? user.resortRank ?? '' : user.overallRank ?? ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
              ),
            ),
            const SizedBox(width: 8),
            ClipOval(
              child: (user.profileImageUrlUser?.isNotEmpty ?? false)
                  ? WebNetworkImage(
                      url: user.profileImageUrlUser,
                      width: 32,
                      height: 32,
                      fallback: _avatarFallback(),
                    )
                  : _avatarFallback(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? '',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                  Text(
                    [
                      if (user.resortNickname?.isNotEmpty ?? false) user.resortNickname,
                      if (user.crewName?.isNotEmpty ?? false) user.crewName,
                    ].join(' · '),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                '${_isResortScoped ? user.resortTotalScore ?? 0 : user.overallTotalScore ?? 0}점',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
              ),
            ),
            if (!_isResortScoped && (user.overallTierIconUrl?.isNotEmpty ?? false)) ...[
              const SizedBox(width: 6),
              WebNetworkImage(url: user.overallTierIconUrl, width: 24, height: 24, fit: BoxFit.contain),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCrewRow(CrewRanking_recordRoom crew) {
    final logoUrl = (crew.crewLogoUrl?.isNotEmpty ?? false) ? crew.crewLogoUrl : crewDefaultLogoUrl[crew.color ?? ''];
    final hasTierIcon = !_isResortScoped && (crew.overallTierIconUrl?.isNotEmpty ?? false);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${_isResortScoped ? crew.resortRank ?? '' : crew.overallRank ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (logoUrl?.isNotEmpty ?? false)
                ? WebNetworkImage(url: logoUrl, width: 32, height: 32)
                : Container(width: 32, height: 32, color: SDSColor.gray100),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              crew.crewName ?? '',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              '${_isResortScoped ? crew.resortTotalScore ?? 0 : crew.overallTotalScore ?? 0}점',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
          ),
          if (hasTierIcon) ...[
            const SizedBox(width: 6),
            WebNetworkImage(url: crew.overallTierIconUrl, width: 24, height: 24, fit: BoxFit.contain),
          ],
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      width: 32,
      height: 32,
      color: SDSColor.gray100,
      child: Icon(Icons.person, size: 18, color: SDSColor.gray400),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabLabel({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: (isActive ? SDSTextStyle.bold : SDSTextStyle.regular)
            .copyWith(fontSize: 15, color: isActive ? SDSColor.gray900 : SDSColor.gray300),
      ),
    );
  }
}

class _MyStat extends StatelessWidget {
  final String label;
  final String value;

  const _MyStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500)),
        const SizedBox(width: 8),
        Text(value, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
      ],
    );
  }
}

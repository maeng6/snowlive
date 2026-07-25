import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rankingListCrew.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList.dart' show RankingFilter_resort, RankingFilter_fed;
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_profile_modal_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_tier_guide_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingList_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingListCrew_web.dart';
import 'package:com.snowlive/web/widget/w_numbered_pagination_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 데스크탑 콘텐츠 최대폭 (중고거래 화면과 동일 톤으로 맞춤).
const double kRankingContentMaxWidth = 1136;

/// 랭킹 리조트 픽커 표시 순서(총 스키장 랭킹 enum) → 실제 backend resort_id.
/// 4(에덴밸리/한솔)가 빠져서 4 다음이 6으로 건너뛴다(모바일과 동일한 매핑).
const Map<RankingFilter_resort, int> kRankingResortIds = {
  RankingFilter_resort.konjiam: 1,
  RankingFilter_resort.muju: 2,
  RankingFilter_resort.vivaldi: 3,
  RankingFilter_resort.alphen: 4,
  RankingFilter_resort.gangchon: 6,
  RankingFilter_resort.oak: 7,
  RankingFilter_resort.o2: 8,
  RankingFilter_resort.yongpyong: 9,
  RankingFilter_resort.welli: 10,
  RankingFilter_resort.jisan: 11,
  RankingFilter_resort.high1: 12,
  RankingFilter_resort.phoenix: 13,
};

const List<RankingFilter_resort> kRankingSelectableResorts = [
  RankingFilter_resort.konjiam,
  RankingFilter_resort.muju,
  RankingFilter_resort.vivaldi,
  RankingFilter_resort.alphen,
  RankingFilter_resort.gangchon,
  RankingFilter_resort.oak,
  RankingFilter_resort.o2,
  RankingFilter_resort.yongpyong,
  RankingFilter_resort.welli,
  RankingFilter_resort.jisan,
  RankingFilter_resort.high1,
  RankingFilter_resort.phoenix,
];

const List<RankingFilter_fed> kRankingSelectableFeds = [RankingFilter_fed.univ_ski, RankingFilter_fed.univ_board];

enum _RankingTab { individual, crew }

/// 웹 랭킹 화면 — 개인랭킹(번호식 페이지네이션) + 크루랭킹(next/previous 커서,
/// fetchRankingData_crew가 아직 번호식/게스트를 지원하지 않아 로그인 사용자만 조회 가능).
/// "랭킹 기록실"(시즌별 기록)은 이번 범위에서는 준비 중 안내만 띄운다.
class RankingHomeViewWeb extends StatefulWidget {
  const RankingHomeViewWeb({super.key});

  @override
  State<RankingHomeViewWeb> createState() => _RankingHomeViewWebState();
}

class _RankingHomeViewWebState extends State<RankingHomeViewWeb> {
  final RankingListViewModelWeb _vm = Get.find<RankingListViewModelWeb>();
  final RankingListCrewViewModelWeb _crewVm = Get.find<RankingListCrewViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  _RankingTab _tab = _RankingTab.individual;
  bool _daily = false;
  RankingFilter_resort _selectedResort = RankingFilter_resort.total;
  RankingFilter_fed _selectedFed = RankingFilter_fed.initial;

  @override
  void initState() {
    super.initState();
    // 각 뷰모델의 onInit()이 최초 진입 시점에 조회한 결과가 화면에 반영되지
    // 않는 경우가 있어(중고거래와 동일 증상), 화면이 마운트되는 시점에
    // 현재 탭 기준으로 한 번 더 명시적으로 조회해서 항상 목록이 뜨도록 한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int? get _resortId => _selectedResort == RankingFilter_resort.total ? null : kRankingResortIds[_selectedResort];
  String? get _federation => _selectedFed == RankingFilter_fed.initial ? null : _selectedFed.english;

  void _reload() {
    if (_tab == _RankingTab.individual) {
      _vm.loadFirstPage(resortId: _resortId, federation: _federation, daily: _daily);
    } else {
      _crewVm.loadFirstPage(userId: _userVm.user.user_id, resortId: _resortId, federation: _federation, daily: _daily);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

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
                Text('랭킹', style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900)),
                const SizedBox(height: SDSSpacing.md),
                _buildSearchBar(),
                const SizedBox(height: SDSSpacing.md),
                _buildTabRow(),
                const SizedBox(height: SDSSpacing.md),
                _buildDailyToggleRow(),
                const SizedBox(height: SDSSpacing.lg),
                _tab == _RankingTab.individual ? _buildMyRankingCard() : _buildMyCrewRankingCard(),
                const SizedBox(height: SDSSpacing.xl),
                _tab == _RankingTab.individual ? _buildIndivList() : _buildCrewList(),
              ],
            ),
          ),
        ),
      ),
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
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _searchQuery.value = v.trim(),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '닉네임으로 검색',
                hintStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
              ),
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() { _tab = _RankingTab.crew; _reload(); }),
          child: Text(
            '크루랭킹',
            style: (_tab == _RankingTab.crew ? SDSTextStyle.bold : SDSTextStyle.regular)
                .copyWith(fontSize: 15, color: _tab == _RankingTab.crew ? SDSColor.gray900 : SDSColor.gray300),
          ),
        ),
        const SizedBox(width: 12),
        Text('|', style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray200)),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => setState(() { _tab = _RankingTab.individual; _reload(); }),
          child: Text(
            '개인랭킹',
            style: (_tab == _RankingTab.individual ? SDSTextStyle.bold : SDSTextStyle.regular)
                .copyWith(fontSize: 15, color: _tab == _RankingTab.individual ? SDSColor.gray900 : SDSColor.gray300),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Get.snackbar('알림', '랭킹 기록실은 준비 중이에요.'),
          child: Row(
            children: [
              Text('랭킹 기록실', style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500)),
              Icon(Icons.chevron_right, size: 16, color: SDSColor.gray400),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => showRankingTierGuide(context),
          child: Row(
            children: [
              Text('랭킹 등급표 안내', style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500)),
              Icon(Icons.chevron_right, size: 16, color: SDSColor.gray400),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyToggleRow() {
    return Row(
      children: [
        _ToggleTab(label: '누적', isActive: !_daily, onTap: () => setState(() { _daily = false; _reload(); })),
        const SizedBox(width: SDSSpacing.lg),
        _ToggleTab(label: '일간', isActive: _daily, onTap: () => setState(() { _daily = true; _reload(); })),
        const Spacer(),
        FleamarketFilterPill(
          label: _selectedResort.korean,
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

  Widget _buildMyRankingCard() {
    return Obx(() {
      final my = _vm.myRankingInfo;
      if (my == null) return const SizedBox.shrink();
      final isResortScoped = _selectedResort != RankingFilter_resort.total;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Text('내 랭킹', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
            const SizedBox(width: SDSSpacing.xl),
            _MyRankingStat(label: '개인 점수', value: '${isResortScoped ? my.resortTotalScore : my.overallTotalScore}'),
            Container(width: 1, height: 32, color: SDSColor.gray200, margin: const EdgeInsets.symmetric(horizontal: SDSSpacing.lg)),
            _MyRankingStat(label: '개인 랭킹', value: '${isResortScoped ? my.resortRank : my.overallRank}'),
            if (!isResortScoped && !_daily) ...[
              Container(width: 1, height: 32, color: SDSColor.gray200, margin: const EdgeInsets.symmetric(horizontal: SDSSpacing.lg)),
              if (my.overallTierIconUrl?.isNotEmpty ?? false) Image.network(my.overallTierIconUrl!, width: 28, height: 28),
              const SizedBox(width: 8),
              Text(my.tierNameKor ?? '', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildMyCrewRankingCard() {
    if (_userVm.user.user_id == null) return const SizedBox.shrink();
    return Obx(() {
      final my = _crewVm.myCrewRankingInfo;
      if (my == null) return const SizedBox.shrink();
      final isResortScoped = _selectedResort != RankingFilter_resort.total;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Text('내 크루 랭킹', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
            const SizedBox(width: SDSSpacing.xl),
            _MyRankingStat(label: '크루 점수', value: '${isResortScoped ? my.resortTotalScore : my.overallTotalScore}'),
            Container(width: 1, height: 32, color: SDSColor.gray200, margin: const EdgeInsets.symmetric(horizontal: SDSSpacing.lg)),
            _MyRankingStat(label: '크루 랭킹', value: '${isResortScoped ? my.resortRank : my.overallRank}'),
          ],
        ),
      );
    });
  }

  Widget _buildIndivList() {
    return Obx(() {
      final items = _vm.items;
      final isLoading = _vm.isLoading;

      if (isLoading && items.isEmpty) {
        return const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: CircularProgressIndicator()));
      }
      if (items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Center(child: Text('랭킹 데이터가 없습니다.', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500))),
        );
      }

      final half = (items.length / 2).ceil();
      final left = items.sublist(0, half);
      final right = items.sublist(half);

      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [for (final u in left) _buildIndivRow(u)])),
              const SizedBox(width: SDSSpacing.xl),
              Expanded(child: Column(children: [for (final u in right) _buildIndivRow(u)])),
            ],
          ),
          const SizedBox(height: SDSSpacing.lg),
          NumberedPaginationBar(
            currentPage: _vm.currentPage,
            totalPages: _vm.totalPages,
            hasPrevious: _vm.hasPrevious,
            hasNext: _vm.hasNext,
            pageWindow: _vm.pageWindow(),
            onGotoPage: (page) => _vm.gotoPage(page),
          ),
        ],
      );
    });
  }

  Widget _buildCrewList() {
    return Obx(() {
      final items = _crewVm.items;
      final isLoading = _crewVm.isLoading;

      if (isLoading && items.isEmpty) {
        return const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: CircularProgressIndicator()));
      }
      if (items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Center(child: Text('랭킹 데이터가 없습니다.', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500))),
        );
      }

      final half = (items.length / 2).ceil();
      final left = items.sublist(0, half);
      final right = items.sublist(half);

      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [for (final c in left) _buildCrewRow(c)])),
              const SizedBox(width: SDSSpacing.xl),
              Expanded(child: Column(children: [for (final c in right) _buildCrewRow(c)])),
            ],
          ),
          const SizedBox(height: SDSSpacing.lg),
          NumberedPaginationBar(
            currentPage: _crewVm.currentPage,
            totalPages: _crewVm.totalPages,
            hasPrevious: _crewVm.hasPrevious,
            hasNext: _crewVm.hasNext,
            pageWindow: _crewVm.pageWindow(),
            onGotoPage: (page) => _crewVm.gotoPage(page),
          ),
        ],
      );
    });
  }

  Widget _buildIndivRow(RankingUser user) {
    final isResortScoped = _selectedResort != RankingFilter_resort.total;
    return Obx(() {
      final query = _searchQuery.value;
      final isHighlighted = query.isNotEmpty && (user.displayName?.contains(query) ?? false);
      return InkWell(
        onTap: () => showRankingProfileModal(context, user),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isHighlighted ? SDSColor.blue50 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  '${isResortScoped ? user.resortRank ?? '' : user.overallRank ?? ''}',
                  style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                ),
              ),
              const SizedBox(width: 8),
              ClipOval(
                child: (user.profileImageUrlUser?.isNotEmpty ?? false)
                    ? Image.network(user.profileImageUrlUser!, width: 32, height: 32, fit: BoxFit.cover)
                    : Container(width: 32, height: 32, color: SDSColor.gray100, child: Icon(Icons.person, size: 18, color: SDSColor.gray400)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName ?? '', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900)),
                    Text(
                      [
                        if (user.resortNickname?.isNotEmpty ?? false) user.resortNickname,
                        if (user.crewName?.isNotEmpty ?? false) user.crewName,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
                    ),
                  ],
                ),
              ),
              Text(
                '${isResortScoped ? user.resortTotalScore ?? 0 : user.overallTotalScore ?? 0}점',
                style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
              ),
              if (!isResortScoped && !_daily && (user.overallTierIconUrl?.isNotEmpty ?? false)) ...[
                const SizedBox(width: 6),
                Image.network(user.overallTierIconUrl!, width: 24, height: 24),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCrewRow(CrewRanking crew) {
    final isResortScoped = _selectedResort != RankingFilter_resort.total;
    final logoUrl = (crew.crewLogoUrl?.isNotEmpty ?? false) ? crew.crewLogoUrl : crewDefaultLogoUrl[crew.color ?? ''];
    final hasTierIcon = !isResortScoped && !_daily && (crew.overallTierIconUrl?.isNotEmpty ?? false);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${isResortScoped ? crew.resortRank ?? '' : crew.overallRank ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (logoUrl?.isNotEmpty ?? false)
                ? Image.network(
                    logoUrl!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 32, height: 32, color: SDSColor.gray100),
                  )
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
              '${isResortScoped ? crew.resortTotalScore ?? 0 : crew.overallTotalScore ?? 0}점',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
          ),
          if (hasTierIcon) ...[
            const SizedBox(width: 6),
            Image.network(
              crew.overallTierIconUrl!,
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) => const SizedBox(width: 24, height: 24),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: (isActive ? SDSTextStyle.bold : SDSTextStyle.regular).copyWith(
          fontSize: 15,
          color: isActive ? SDSColor.gray900 : SDSColor.gray300,
        ),
      ),
    );
  }
}

class _MyRankingStat extends StatelessWidget {
  final String label;
  final String value;

  const _MyRankingStat({required this.label, required this.value});

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

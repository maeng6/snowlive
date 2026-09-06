import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/community/w_community_header_web.dart';
import 'package:com.snowlive/web/view/community/w_event_list_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityListPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/event/vm_eventListPagination_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 커뮤니티와 같은 계산식(1440px - GNB - 좌우 여백)으로 콘텐츠 폭을 맞춘다.
/// 각종소식은 우측 사이드바가 없어 목록이 이 폭을 전부 쓴다.
const double kEventContentMaxWidth =
    WebBreakpoints.maxContentWidth - kGnbSidebarWidth - (SDSSpacing.xl * 2);

/// 웹 각종소식(이벤트) 독립 목록 화면.
/// 커뮤니티에서 분리해 좌측 GNB의 "각종소식" 항목으로 진입한다.
/// 소스는 `/api/event/` 하나뿐이라 정렬 없이 검색바 + 크롤 계정 필터 + 목록만 둔다.
/// 목록에서 제목을 누르면 조회수를 올리고 `landing_url`로 외부 이동한다(뷰모델이 처리).
class EventHomeViewWeb extends StatefulWidget {
  const EventHomeViewWeb({super.key});

  @override
  State<EventHomeViewWeb> createState() => _EventHomeViewWebState();
}

class _EventHomeViewWebState extends State<EventHomeViewWeb> {
  final EventListPaginationViewModelWeb _vm =
      Get.find<EventListPaginationViewModelWeb>();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  /// 선택된 크롤 계정 필터(기본 '전체 계정').
  EventAccountFilter _account = EventAccountFilter.all;

  @override
  void initState() {
    super.initState();
    // 뷰모델 onInit에서 조회하지 않으므로(중복 요청 방지) 최초 조회는 여기서 한다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
    // 필터 드롭다운에 채울 크롤 계정 목록도 함께 받아온다.
    _vm.fetchAccountFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _reload() => _vm.loadFirstPage(query: _searchController.text);

  void _onAccountSelected(EventAccountFilter account) {
    if (account.id == _account.id) return;
    setState(() => _account = account);
    // 검색어는 유지한 채 계정 필터만 바꿔 다시 조회한다.
    _vm.setCrawlAccount(account.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final titleText = Text(
      '각종소식',
      style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900),
    );
    final searchBar = CommunitySearchBarWeb(
      controller: _searchController,
      focusNode: _searchFocus,
      // 이벤트 API는 search_query(제목+내용)만 지원한다 → 범위 드롭다운을 잠근다.
      scope: CommunitySearchScope.titleContent,
      onScopeChanged: (_) {},
      onSubmitted: (_) => _reload(),
      scopeLocked: true,
    );
    // 크롤 계정 필터 드롭다운. 계정 목록이 비동기로 채워지므로 Obx로 감싼다.
    // .toList()로 RxList 원소를 실제로 읽어야 Obx가 갱신 대상으로 등록한다
    // (그냥 참조만 넘기면 "improper use of GetX" 에러가 난다).
    final accountFilter = Obx(
      () => FleamarketFilterPill<EventAccountFilter>(
        label: _account.label,
        isActive: !_account.isAll,
        title: '계정 필터',
        showTitleInSheet: true,
        values: _vm.accountFilters.toList(),
        labelOf: (a) => a.label,
        onSelected: _onAccountSelected,
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          // 데스크탑: 타이틀 + 검색바 + 계정 필터가 한 줄에 온다.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleText,
              const SizedBox(width: SDSSpacing.lg),
              SizedBox(width: kCommunityDesktopSearchBarWidth, child: searchBar),
              const SizedBox(width: SDSSpacing.md),
              accountFilter,
            ],
          )
        else ...[
          titleText,
          const SizedBox(height: SDSSpacing.md),
          searchBar,
          const SizedBox(height: SDSSpacing.md),
          // 모바일: 검색바 아래에 계정 필터를 오른쪽 정렬로 둔다.
          Align(alignment: Alignment.centerRight, child: accountFilter),
        ],
        const SizedBox(height: SDSSpacing.lg),
        // 검색 중이면 안내 박스를 목록 위에 둔다. 서버에 실제로 보낸 검색어를 쓴다.
        Obx(() {
          final query = _vm.appliedQuery;
          if (query.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: SDSSpacing.md),
            child: CommunitySearchNoticeWeb(query: query),
          );
        }),
        const EventListWeb(),
      ],
    );

    return Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        32,
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        SDSSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kEventContentMaxWidth),
            child: content,
          ),
        ),
      ),
    );
  }
}

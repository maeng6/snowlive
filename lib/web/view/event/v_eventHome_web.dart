import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/community/w_community_header_web.dart';
import 'package:com.snowlive/web/view/community/w_event_list_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart' show HomeFooterWeb;
import 'package:com.snowlive/web/viewmodel/community/vm_communityListPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/event/vm_eventListPagination_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 각종소식은 우측 사이드바가 없어 목록 최대폭(웹 공통 1280)만 쓴다.
const double kEventContentMaxWidth = kWebDesktopListMaxWidth;

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

  /// 선택된 1차 카테고리 그룹(기본 '전체').
  EventPrimaryCategory _primary = EventPrimaryCategory.all;

  /// 선택된 2차 크롤 계정 필터(기본 '그룹 전체').
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

  Future<void> _reload() => _vm.loadFirstPage(query: _searchController.text);

  void _onPrimarySelected(EventPrimaryCategory primary) {
    if (primary == _primary) return;
    setState(() {
      _primary = primary;
      // 1차 그룹이 바뀌면 2차 선택은 '그룹 전체'로 초기화한다.
      _account = EventAccountFilter.all;
    });
    _vm.setPrimaryCategory(primary);
  }

  void _onAccountSelected(EventAccountFilter account) {
    if (account.id == _account.id) return;
    setState(() => _account = account);
    // 검색어는 유지한 채 2차 계정 필터만 바꿔 다시 조회한다.
    _vm.setCrawlAccount(account.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final titleText = Text(
      '각종소식',
      // 홈 타이틀 공통: PC 32 / 태블릿·모바일 24 (중고거래 홈 기준).
      style: SDSTextStyle.extraBold.copyWith(fontSize: webHomeTitleSize(context), color: SDSColor.gray900),
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
    // 1차 카테고리 pill (스키장 / 브랜드). 전체면 기본 상태.
    final primaryFilter = FleamarketFilterPill<EventPrimaryCategory>(
      label: _primary.isAll ? '카테고리' : _primary.label,
      labelFontSize: 14,
      isActive: !_primary.isAll,
      title: '카테고리',
      showTitleInSheet: true,
      dropdownOnTablet: true,
      values: EventPrimaryCategory.values,
      labelOf: (p) => p.label,
      onSelected: _onPrimarySelected,
    );

    // 2차 계정 pill. 1차에서 스키장/브랜드를 고른 경우에만 노출한다.
    // 1차=전체면 Obx로 감싸지 않는다(Obx 안에서 Rx를 하나도 안 읽고 반환하면
    // "improper use of GetX" 에러가 난다). _primary는 평범한 state라 setState로
    // 재빌드되므로 조건 분기는 build가 다시 평가한다.
    final Widget accountFilter = _primary.isAll
        ? const SizedBox.shrink()
        // 계정 목록이 비동기로 채워지므로 Obx로 감싼다(accountsFor가 RxList를 읽음).
        : Obx(() {
            final values = _vm.accountsFor(_primary);
            final groupAllLabel = _primary == EventPrimaryCategory.resort
                ? '스키장 전체'
                : '브랜드 전체';
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FleamarketFilterPill<EventAccountFilter>(
                label: _account.isAll ? groupAllLabel : _account.label,
                labelFontSize: 14,
                isActive: !_account.isAll,
                title: _primary == EventPrimaryCategory.resort ? '스키장 선택' : '브랜드 선택',
                showTitleInSheet: true,
                dropdownOnTablet: true,
                values: values,
                labelOf: (a) => a.label,
                onSelected: _onAccountSelected,
              ),
            );
          });

    // 두 pill을 한 묶음으로. 오른쪽 정렬 시 함께 움직이도록 Row로 감싼다.
    final filterRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [primaryFilter, accountFilter],
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop) ...[
          // 데스크탑: 타이틀 + 고정폭 검색바 한 줄, 필터는 아래 줄 우측 —
          // 커뮤니티 홈과 동일한 골격.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleText,
              // 타이틀 ↔ 검색바 36 (커뮤니티와 동일).
              const SizedBox(width: 36),
              SizedBox(width: kCommunityDesktopSearchBarWidth, child: searchBar),
            ],
          ),
          // 타이틀·검색 영역 ↔ 필터 줄 30 (커뮤니티와 동일).
          const SizedBox(height: 30),
          Row(children: [const Spacer(), filterRow]),
          // 필터 줄 ↔ 목록 20 (커뮤니티와 동일).
          const SizedBox(height: 20),
        ] else ...[
          titleText,
          const SizedBox(height: SDSSpacing.md),
          searchBar,
          // 검색 영역 ↔ 필터 줄: 태블릿 24 / 모바일 20 (커뮤니티와 동일).
          SizedBox(height: webTitleToFilterGap(context)),
          // 태블릿·모바일: 검색바 아래에 카테고리/계정 필터를 오른쪽 정렬로 둔다.
          Align(alignment: Alignment.centerRight, child: filterRow),
          // 필터 줄 ↔ 목록 20 (커뮤니티와 동일).
          const SizedBox(height: 20),
        ],
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
      // 콘텐츠가 짧으면 푸터가 뷰포트 하단에 붙는다(공통 골격).
      child: WebStickyFooterScroll(
        onRefresh: _reload, // 당겨서 새로고침
        padding: webHomePagePadding(context),
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kEventContentMaxWidth),
            child: content,
          ),
        ),
        // 홈과 동일한 푸터 — 1280 제한 밖, 콘텐츠 영역 폭(푸터 정책).
        // 간격은 최소값(콘텐츠가 길면 이 값 그대로).
        footer: Column(
          children: [
            SizedBox(height: webFooterTopGap(context)),
            const HomeFooterWeb(),
          ],
        ),
      ),
    );
  }
}

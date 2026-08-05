import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/community/w_community_header_web.dart';
import 'package:com.snowlive/web/view/community/w_event_list_web.dart';
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
/// 소스는 `/api/event/` 하나뿐이라 탭·정렬 없이 검색바 + 목록만 둔다.
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

  @override
  void initState() {
    super.initState();
    // 뷰모델 onInit에서 조회하지 않으므로(중복 요청 방지) 최초 조회는 여기서 한다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _reload() => _vm.loadFirstPage(query: _searchController.text);

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

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleText,
              const SizedBox(width: SDSSpacing.lg),
              SizedBox(width: kCommunityDesktopSearchBarWidth, child: searchBar),
            ],
          )
        else ...[
          titleText,
          const SizedBox(height: SDSSpacing.md),
          searchBar,
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

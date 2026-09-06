import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketHome_web.dart' show kFleamarketContentMaxWidth;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_body_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_comments_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_gallery_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_owner_actions_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_recommend_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_seller_row_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 중고거래 웹 상세화면.
///
/// 커뮤니티 상세처럼 **URL의 id로 조회**한다(`/fleamarket-detail?id=1365`).
/// 목록 카드 탭 시에는 즉시 표시를 위해 목록 데이터를 먼저 주입하고, 진입 후 그 id로
/// API 재조회한다. 그래서 새로고침·링크 공유로 직접 들어와도(=주입 데이터가 없어도) 열린다.
class FleamarketDetailView extends StatefulWidget {
  const FleamarketDetailView({super.key});

  @override
  State<FleamarketDetailView> createState() => _FleamarketDetailViewState();
}

class _FleamarketDetailViewState extends State<FleamarketDetailView> {
  final FleamarketDetailViewModel _detailVm = Get.find<FleamarketDetailViewModel>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();

  int? _fleaId;
  bool _loadingById = false;
  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    // Get.parameters는 전역 가변 맵이라 build에서 읽으면 다른 라우트 값에 덮인다.
    _fleaId = int.tryParse(Get.parameters['id'] ?? '');
    if (_fleaId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
      // 자동로그인이 늦게 확정되면 user_id 없이 조회된 상태다 → 확정 후 다시 받는다(찜 상태 등).
      _authWorker = ever<WebAuthStatus>(_authVm.statusRx, (status) {
        if (status == WebAuthStatus.authenticated) _load();
      });
    }
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_fleaId == null) return;
    if (mounted) setState(() => _loadingById = true);
    // 게스트면 user_id는 null로 나가고, 서버는 로그인 없이도 상세를 준다.
    await _detailVm.fetchFleamarketDetailFromAPI(
      fleamarketId: _fleaId!,
      userId: _userVm.user.user_id,
    );
    if (mounted) setState(() => _loadingById = false);
  }

  void _goBack() {
    // 딥링크로 바로 들어왔으면 pop할 히스토리가 없다.
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      Get.offAllNamed(WebRoutes.fleamarketList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Obx(() {
      final detail = _detailVm.fleamarketDetail;
      if (detail.fleaId == null) {
        // id로 조회 중이면 스피너를, 조회할 id조차 없으면(비정상 진입) 안내를 준다.
        if (_loadingById) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return WebEmptyState(
          message: '상품 정보를 불러올 수 없어요.\n목록에서 다시 선택해주세요.',
          actionLabel: '중고거래 목록으로',
          onAction: () => Get.offAllNamed(WebRoutes.fleamarketList),
        );
      }

      final gallery = FleamarketDetailGalleryWeb(photos: detail.photos ?? []);
      final infoColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FleamarketDetailSellerRowWeb(detail: detail),
          const SizedBox(height: SDSSpacing.md),
          FleamarketDetailBodyWeb(detail: detail),
          FleamarketDetailOwnerActionsWeb(detail: detail),
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
              constraints: const BoxConstraints(maxWidth: kFleamarketContentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: Icon(Icons.arrow_back, color: SDSColor.gray900),
                  ),
                  const SizedBox(height: SDSSpacing.sm),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: gallery),
                        const SizedBox(width: SDSSpacing.xl),
                        Expanded(flex: 6, child: infoColumn),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        gallery,
                        const SizedBox(height: SDSSpacing.md),
                        infoColumn,
                      ],
                    ),
                  // 목업에는 댓글 위 구분선(회색 밴드)이 없다.
                  const SizedBox(height: SDSSpacing.xxl),
                  FleamarketDetailCommentsWeb(detail: detail),
                  const SizedBox(height: SDSSpacing.xl),
                  FleamarketDetailRecommendWeb(categoryMain: detail.categoryMain, excludeFleaId: detail.fleaId),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

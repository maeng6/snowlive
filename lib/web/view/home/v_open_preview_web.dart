import 'dart:convert';

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_open_preview.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/w_home_open_preview_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart' show HomeFooterWeb;
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// 개장 미리보기 **페이지**(`/open-preview`) — 노출(active) 체크된 **모든** 스키장
/// 웹캠을 스키장별로 묶어 재생한다. 뒤로가기 버튼은 홈으로 간다(외부 배너에서 바로
/// 진입하는 경우가 있어 히스토리 유무와 무관하게 홈으로 보낸다).
class OpenPreviewPageWeb extends StatefulWidget {
  const OpenPreviewPageWeb({super.key});

  @override
  State<OpenPreviewPageWeb> createState() => _OpenPreviewPageWebState();
}

class _OpenPreviewPageWebState extends State<OpenPreviewPageWeb> {
  List<OpenPreviewItem> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await http.get(Uri.parse(
          'https://snowlive-api-c617725e2b78.herokuapp.com/api/open-preview/'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body is Map ? body['items'] : null);
        if (list is List) {
          _items = list
              .map(OpenPreviewItem.tryParse)
              .whereType<OpenPreviewItem>()
              .toList();
        }
      }
    } catch (_) {
      // 실패 시 빈 목록 — 빈 상태 위젯이 뜬다.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goHome() => Get.offAllNamed(WebRoutes.home);

  /// 스키장별로 묶는다(등장 순서 유지).
  Map<String, List<OpenPreviewItem>> _grouped() {
    final map = <String, List<OpenPreviewItem>>{};
    for (final it in _items) {
      map.putIfAbsent(it.resort, () => []).add(it);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final groups = _grouped();

    return Container(
      color: SDSColor.snowliveWhite,
      child: WebStickyFooterScroll(
        onRefresh: _load,
        padding: webHomePagePadding(context),
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kWebDesktopListMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더: 뒤로가기 + 제목
                Row(
                  children: [
                    _BackButton(onTap: _goHome),
                    const SizedBox(width: 8),
                    Text(
                      '개장 미리보기',
                      style: SDSTextStyle.extraBold.copyWith(
                        fontSize: isMobile ? 20 : 26,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 20 : 28),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: WebEmptyState(message: '아직 공개된 웹캠이 없어요'),
                  )
                else
                  for (final entry in groups.entries) ...[
                    Text(
                      entry.key,
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: isMobile ? 16 : 18,
                        color: SDSColor.gray900,
                      ),
                    ),
                    const SizedBox(height: SDSSpacing.md),
                    _CamGrid(items: entry.value),
                    const SizedBox(height: 36),
                  ],
              ],
            ),
          ),
        ),
        footer: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kWebDesktopListMaxWidth),
            child: Column(
              children: [
                SizedBox(height: webFooterTopGap(context)),
                const HomeFooterWeb(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 한 스키장의 웹캠들 — 2열(모바일 1열) 그리드. 홈 섹션과 같은 카드를 쓴다.
class _CamGrid extends StatelessWidget {
  final List<OpenPreviewItem> items;

  const _CamGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    return LayoutBuilder(
      builder: (context, c) {
        final columns = isMobile ? 1 : 2;
        const gap = 16.0;
        final cellW = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final it in items)
              SizedBox(width: cellW, child: OpenPreviewCard(item: it)),
          ],
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: SDSColor.gray50,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.arrow_back_rounded, size: 24, color: SDSColor.gray900),
        ),
      ),
    );
  }
}

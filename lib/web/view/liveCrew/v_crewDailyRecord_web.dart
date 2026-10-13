import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_widgets_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewRecord_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 일별 현황. `#/livecrew-daily?id=334`
///
/// 기록실과 데이터는 같은데 조회 축이 다르다 — 여기는 **연도**(`year=2026`),
/// 기록실은 **시즌**(`selected_season=2526`).
class CrewDailyRecordViewWeb extends StatefulWidget {
  const CrewDailyRecordViewWeb({super.key});

  @override
  State<CrewDailyRecordViewWeb> createState() => _CrewDailyRecordViewWebState();
}

class _CrewDailyRecordViewWebState extends State<CrewDailyRecordViewWeb> {
  final CrewRecordViewModelWeb _vm = Get.find<CrewRecordViewModelWeb>();

  int? _crewId;

  @override
  void initState() {
    super.initState();
    _crewId = int.tryParse(Get.parameters['id'] ?? '');
    final id = _crewId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _vm.loadYear(id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CrewRecordScaffoldWeb(
      title: '일별 현황',
      // 목록 화면 공통 폭 1280 — 목업(196:19476)은 1440 창에서 콘텐츠가 1160으로
      // 가용 폭을 그대로 쓴다(상한에 안 걸린다). 기본 1136으로 두면 24 좁아진다.
      maxWidth: kWebDesktopListMaxWidth,
      fallbackRoute: '${WebRoutes.crewHome}?id=$_crewId',
      child: Obx(_buildBody),
    );
  }

  Widget _buildBody() {
    // 분기 전에 관찰값을 모두 읽는다(Obx 구독).
    final isInitialLoading = _vm.isInitialLoading;
    final hasError = _vm.hasError;
    final records = _vm.records.toList();
    final year = _vm.year;
    final info = _vm.info;

    if (_crewId == null) {
      return const WebEmptyState(message: '크루 정보를 찾을 수 없어요.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // PC·태블릿은 `2026 | 2025` 텍스트 탭(목업 196:19568), **모바일은 드롭다운**
        // (목업 196:23913 — `2026 ⌄`). 기록실 시즌 선택과 같은 처리.
        SizedBox(
          height: 36,
          child: Align(
            alignment: Alignment.centerLeft,
            child: context.screenType == WebScreenType.mobile
                ? WebDropdownTextButton<int>(
                    label: '$year',
                    values: _vm.years,
                    labelOf: (y) => '$y',
                    onSelected: _vm.setYear,
                    title: '연도',
                    // 꺾쇠는 공용 기본 18보다 크게 — 목업의 11×5 벡터에 맞추면 22쯤이다.
                    // 공용 기본값은 커뮤니티·중고거래가 같이 쓰므로 호출부에서만 키운다.
                    iconSize: 22,
                  )
                : WebTextTabs<int>(
                    values: _vm.years,
                    selected: year,
                    labelOf: (y) => '$y',
                    onSelected: _vm.setYear,
                    lineDivider: true,
                    dividerGap: 10,
                  ),
          ),
        ),
        // 탭 ↔ 첫 월 섹션 32 — PC 목업(196:19476 탭 끝 218, 월 제목 250)과
        // 태블릿 목업(196:21372 탭 끝 154, 월 블록 186)이 같은 값이다.
        const SizedBox(height: 32),
        if (records.isEmpty)
          // 첫 조회 전에도 스켈레톤을 보여준다(빈 상태가 번쩍이지 않게).
          isInitialLoading
              ? const CrewRecordListSkeleton()
              : hasError
                  ? WebErrorState(onRetry: _vm.refreshYear)
                  : const WebEmptyState(message: '데이터가 없어요.')
        else
          CrewRecordMonthList(
            // 연도를 바꾸면 펼침 상태를 새로 시작한다.
            key: ValueKey('year-$year'),
            records: records,
            crewName: info?.crewName,
            resortName: info?.baseResortFullname ?? info?.baseResortNickname,
          ),
      ],
    );
  }
}


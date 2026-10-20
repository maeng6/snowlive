import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_rideDetail.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rideDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/widget/ride/w_ride_detail_view.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/seasonpass/vm_seasonPass_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

/// 웹 데이터랩 페이지 — 시즌권 혜택으로 내 라이딩 상세 데이터를 제공한다.
/// 유료 이용 중이면 라이딩 세션 리스트(최신순)를 바로 보여주고, 미결제면
/// 혜택 소개 + 구매를 노출한다. 기존 웹 디자인 시스템(SDSColor/SDSTextStyle) 그대로.
class SeasonPassHomeViewWeb extends StatefulWidget {
  const SeasonPassHomeViewWeb({super.key});

  @override
  State<SeasonPassHomeViewWeb> createState() => _SeasonPassHomeViewWebState();
}

class _SeasonPassHomeViewWebState extends State<SeasonPassHomeViewWeb> {
  final RideDetailAPI _rideApi = RideDetailAPI();

  bool _loadingTracks = true;
  List<Map<String, dynamic>> _tracks = [];
  Worker? _paidWorker;
  Worker? _authWorker;

  // 데이터 요약 기간(기본: 로드된 라이딩의 최소~최대 날짜).
  DateTime? _sumStart;
  DateTime? _sumEnd;

  @override
  void initState() {
    super.initState();
    _loadTracks();
    // 뷰모델은 fenix로 살아있어 onInit이 재진입마다 돌지 않는다 → 진입할 때마다
    // 구독상태를 다시 불러와, 어드민의 정지/해제가 즉시 반영되게 한다.
    final vm = Get.find<SeasonPassViewModelWeb>();
    vm.refreshAll();
    // 결제가 확정되면(미결제→이용중) 라이딩 리스트를 다시 불러온다.
    _paidWorker = ever<bool>(vm.isPaid, (_) => _loadTracks());
    // ⚠️ 새로고침 직후엔 자동로그인(Firebase 세션 복원→서버 로그인)이 비동기라
    // 이 시점엔 user_id가 아직 없다 → 구독상태 조회가 '미결제'로 떨어져 결제화면이
    // 뜬다. 인증이 확정되는 순간 구독상태·라이딩을 다시 불러온다.
    if (Get.isRegistered<AuthCheckViewModelWeb>()) {
      _authWorker = ever(Get.find<AuthCheckViewModelWeb>().statusRx, (_) {
        vm.refreshAll();
        _loadTracks();
      });
    }
  }

  @override
  void dispose() {
    _paidWorker?.dispose();
    _authWorker?.dispose();
    super.dispose();
  }

  Future<void> _loadTracks() async {
    final uid = Get.isRegistered<UserViewModel>()
        ? Get.find<UserViewModel>().user?.user_id
        : null;
    final userId = (uid is int) ? uid : int.tryParse('$uid');
    if (userId == null) {
      if (mounted) setState(() => _loadingTracks = false);
      return;
    }
    final res = await _rideApi.fetchRideList(userId: userId);
    if (!mounted) return;
    if (res.success && res.data is Map && res.data['tracks'] is List) {
      _tracks = (res.data['tracks'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      // 실제 라이딩 시각(pass_time) 기준 최신순. created_at은 DB 적재 시각이라
      // 더미는 전부 같은 값이 될 수 있어 날짜 구분이 안 된다.
      _tracks.sort((a, b) => _whenStr(b).compareTo(_whenStr(a)));
      // 데이터 요약 기본 기간: 로드된 라이딩의 최소~최대 날짜.
      final dates = _tracks
          .map((t) => DateTime.tryParse(_datePart(_when(t))))
          .whereType<DateTime>()
          .toList();
      if (dates.isNotEmpty) {
        dates.sort();
        _sumStart ??= dates.first;
        _sumEnd ??= dates.last;
      }
    }
    setState(() => _loadingTracks = false);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<SeasonPassViewModelWeb>();
    return Container(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            // 라이딩 그리드(9열)가 가로스크롤 없이 들어가도록 넉넉히 넓힌다.
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('데이터랩',
                    style: SDSTextStyle.extraBold
                        .copyWith(fontSize: 24, color: SDSColor.gray900)),
                const SizedBox(height: 4),
                Text('시즌권 혜택으로 내 라이딩 상세 데이터를 확인하세요.',
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 14, color: SDSColor.gray600)),
                const SizedBox(height: SDSSpacing.lg),
                Obx(() {
                  // 구독 판별 중(자동로그인 복원 중·상태조회 중·아직 1회도 확정 안 됨)에는
                  // 결제화면이 번쩍 떴다 사라지지 않게 스라 풀스크린 인디케이터를 띄운다.
                  final authStatus = Get.isRegistered<AuthCheckViewModelWeb>()
                      ? Get.find<AuthCheckViewModelWeb>().statusRx.value
                      : WebAuthStatus.authenticated;
                  final determining = authStatus == WebAuthStatus.checking ||
                      vm.isLoading.value ||
                      (authStatus == WebAuthStatus.authenticated &&
                          !vm.statusResolved.value);
                  if (determining) {
                    return _fullScreenLoading();
                  }
                  final children = <Widget>[];
                  if (vm.isPaid.value) {
                    children
                      ..add(_statusCard(vm))
                      ..add(const SizedBox(height: SDSSpacing.md))
                      ..add(_dataSummaryCard())
                      ..add(const SizedBox(height: SDSSpacing.md))
                      ..add(_ridingListCard());
                  } else {
                    children
                      ..add(_benefitsCard())
                      ..add(const SizedBox(height: SDSSpacing.md))
                      ..add(_purchaseCard(context, vm));
                  }
                  children
                    ..add(const SizedBox(height: SDSSpacing.md))
                    ..add(_historyCard(context, vm))
                    ..add(const SizedBox(height: SDSSpacing.md))
                    ..add(_messageBox(vm));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 구독 판별 중 표시하는 스라 풀스크린 인디케이터(CustomFullScreenDialog와 동일 로티).
  Widget _fullScreenLoading() => Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 120),
        child: Container(
          width: 90,
          height: 90,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: SDSColor.snowliveBlack.withOpacity(0.8),
          ),
          child: Lottie.asset('assets/json/loadings_wht_final.json'),
        ),
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SDSColor.snowliveWhite,
          border: Border.all(color: SDSColor.gray200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );

  Widget _sectionTitle(String t) => Text(t,
      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900));

  // ───────────────────────── 혜택/구매 (미결제) ─────────────────────────

  Widget _benefitsCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('시즌권 혜택 — 라이딩 상세 데이터'),
            const SizedBox(height: SDSSpacing.md),
            _benefitRow('라이딩 세션별 상세 기록',
                '세션마다 라이딩 시간 · 경사 · 거리 · 속도 · 점수를 한눈에'),
            const SizedBox(height: SDSSpacing.sm),
            _benefitRow('라이딩 궤적 · 애니메이션',
                '내 라이딩 경로를 궤적 이미지로 보고 재생 애니메이션으로 다시보기'),
          ],
        ),
      );

  Widget _benefitRow(String title, String desc) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: SDSTextStyle.bold
                  .copyWith(fontSize: 14, color: SDSColor.gray900)),
          const SizedBox(height: 2),
          Text(desc,
              style: SDSTextStyle.regular
                  .copyWith(fontSize: 13, color: SDSColor.gray600)),
        ],
      );

  Widget _purchaseCard(BuildContext context, SeasonPassViewModelWeb vm) {
    return Obx(() {
      final priceText = '${_comma(vm.price.value)}원';
      final until = vm.validUntil.value ?? '시즌 종료일';
      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('구매'),
            const SizedBox(height: SDSSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(priceText,
                    style: SDSTextStyle.extraBold
                        .copyWith(fontSize: 22, color: SDSColor.snowliveBlue)),
                const SizedBox(width: 8),
                Text('/ $until 까지',
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 13, color: SDSColor.gray500)),
              ],
            ),
            const SizedBox(height: SDSSpacing.md),
            _consentRow(
              value: vm.agreeTerms,
              text:
                  '본 시즌권은 $until까지 이용 가능하며, 결제 시점과 무관하게 종료일은 동일합니다.',
            ),
            const SizedBox(height: SDSSpacing.sm),
            _consentRow(
              value: vm.agreeRefund,
              text: '유료 기능 이용을 시작한 이후에는 환불이 제한됨에 동의합니다.',
            ),
            const SizedBox(height: SDSSpacing.md),
            SizedBox(
              height: 48,
              child: Obx(() => ElevatedButton(
                    onPressed: vm.canPurchase ? () => vm.purchase() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveBlue,
                      disabledBackgroundColor: SDSColor.gray200,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: vm.isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('구매하기',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 15, color: SDSColor.snowliveWhite)),
                  )),
            ),
          ],
        ),
      );
    });
  }

  Widget _consentRow({required RxBool value, required String text}) {
    return Obx(() => InkWell(
          onTap: () => value.value = !value.value,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: value.value,
                  onChanged: (v) => value.value = v ?? false,
                  activeColor: SDSColor.snowliveBlue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(text,
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 13, color: SDSColor.gray700)),
              ),
            ],
          ),
        ));
  }

  // ───────────────────────── 이용 중 / 라이딩 리스트 ─────────────────────────

  Widget _statusCard(SeasonPassViewModelWeb vm) {
    final until = vm.validUntil.value;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('이용 중'),
          const SizedBox(height: SDSSpacing.sm),
          Text(
            '${vm.seasonName.value ?? '시즌권'} 이용 중입니다.'
            '${until != null ? '  ($until 까지)' : ''}',
            style: SDSTextStyle.regular
                .copyWith(fontSize: 14, color: SDSColor.gray700),
          ),
        ],
      ),
    );
  }

  // 그리드 열: 날짜 | 시간 | 슬로프 | 소요시간 | 경로(재생) | 경사 | 거리 | 평균속도 | 최고속도 | 점수.
  static const List<String> _colHeads = [
    '날짜', '시간', '슬로프', '소요시간', '경로', '경사', '거리', '평균속도', '최고속도', '점수',
  ];
  // 각 열의 가변폭 비율(Expanded flex). 카드 너비를 꽉 채워 가로스크롤이 없다.
  static const List<int> _colFlex = [
    80, 52, 104, 78, 48, 52, 68, 72, 72, 56,
  ];
  // 경로(index 4)는 가운데 재생버튼. 숫자 열(경사~점수, index 5~)은 오른쪽 정렬.
  static const int _pathCol = 4;
  static const int _firstNumericCol = 5;

  /// 날짜 그룹 교차 음영 — 스노우라이브 블루를 옅게(0.06의 1.3배인 0.078).
  static final Color _kRowShade =
      SDSColor.snowliveBlue.withValues(alpha: 0.078);

  // ───────────────────────── 데이터 요약 ─────────────────────────

  /// 선택 기간 [_sumStart, _sumEnd] 안의 라이딩 집계.
  Map<String, dynamic> _computeSummary() {
    int count = 0, spdN = 0;
    double dur = 0, dist = 0, spdSum = 0, maxSpd = 0, scoreSum = 0;
    for (final t in _tracks) {
      final day = DateTime.tryParse(_datePart(_when(t)));
      if (day == null) continue;
      if (_sumStart != null && day.isBefore(_sumStart!)) continue;
      if (_sumEnd != null && day.isAfter(_sumEnd!)) continue;
      count++;
      dur += (t['duration_s'] as num?)?.toDouble() ?? 0;
      dist += (t['distance'] as num?)?.toDouble() ?? 0;
      final av = (t['avg_speed'] as num?)?.toDouble() ?? 0;
      if (av > 0) {
        spdSum += av;
        spdN++;
      }
      final mx = (t['max_speed'] as num?)?.toDouble() ?? 0;
      if (mx > maxSpd) maxSpd = mx;
      scoreSum += (t['score'] as num?)?.toDouble() ?? 0;
    }
    return {
      'count': count,
      'dur': dur,
      'dist': dist,
      'avg': spdN > 0 ? spdSum / spdN : 0.0,
      'max': maxSpd,
      'score': scoreSum,
    };
  }

  /// 거리: 1000m 미만은 m, 이상은 km(소수 2자리).
  String _fmtDistance(double m) =>
      m < 1000 ? '${m.round()}m' : '${(m / 1000).toStringAsFixed(2)}km';

  /// 초 → "N시간 M분" / "M분 S초" / "S초".
  String _fmtDurSec(double sec) {
    final s = sec.round();
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, ss = s % 60;
    if (h > 0) return '$h시간 $m분';
    if (m > 0) return '$m분 $ss초';
    return '$ss초';
  }

  String _ymdDot(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isStart) async {
    final init = (isStart ? _sumStart : _sumEnd) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked == null) return;
    setState(() {
      final day = DateTime(picked.year, picked.month, picked.day);
      if (isStart) {
        _sumStart = day;
        if (_sumEnd != null && _sumEnd!.isBefore(day)) _sumEnd = day;
      } else {
        _sumEnd = day;
        if (_sumStart != null && _sumStart!.isAfter(day)) _sumStart = day;
      }
    });
  }

  Widget _dateField(String label, DateTime? value, bool isStart) => InkWell(
        onTap: () => _pickDate(isStart),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: SDSColor.gray200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 15, color: SDSColor.gray500),
              const SizedBox(width: 8),
              Text(
                value != null ? _ymdDot(value) : label,
                style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: value != null ? SDSColor.gray900 : SDSColor.gray500),
              ),
            ],
          ),
        ),
      );

  Widget _summaryTile(String label, String value) => Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: SDSColor.gray50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: SDSTextStyle.regular
                    .copyWith(fontSize: 12, color: SDSColor.gray500)),
            const SizedBox(height: 4),
            Text(value,
                style: SDSTextStyle.extraBold
                    .copyWith(fontSize: 18, color: SDSColor.snowliveBlue)),
          ],
        ),
      );

  Widget _dataSummaryCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('데이터 요약'),
            const SizedBox(height: 4),
            Text('기간을 선택하면 그 기간의 라이딩을 합산해 보여줍니다.',
                style: SDSTextStyle.regular
                    .copyWith(fontSize: 12, color: SDSColor.gray500)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _dateField('시작날짜', _sumStart, true)),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('~',
                        style:
                            TextStyle(fontSize: 14, color: SDSColor.gray500))),
                Expanded(child: _dateField('종료날짜', _sumEnd, false)),
              ],
            ),
            const SizedBox(height: 14),
            Builder(builder: (_) {
              final s = _computeSummary();
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _summaryTile('슬로프 횟수', '${s['count']}회'),
                  _summaryTile('라이딩 시간', _fmtDurSec(s['dur'] as double)),
                  _summaryTile('라이딩 거리', _fmtDistance(s['dist'] as double)),
                  _summaryTile(
                      '평균속도', '${(s['avg'] as double).toStringAsFixed(1)}km/h'),
                  _summaryTile(
                      '최고속도', '${(s['max'] as double).toStringAsFixed(1)}km/h'),
                  _summaryTile(
                      '합산점수', (s['score'] as double).toStringAsFixed(1)),
                ],
              );
            }),
          ],
        ),
      );

  Widget _ridingListCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('내 라이딩'),
            const SizedBox(height: SDSSpacing.md),
            if (_loadingTracks)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_tracks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('아직 기록된 라이딩이 없어요. 폴리곤 라이딩 후 확인해주세요.',
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 14, color: SDSColor.gray500)),
              )
            else
              _rideTable(),
            if (_tracks.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('경로의 재생 버튼을 누르면 라이딩 궤적을 볼 수 있어요.',
                  style: SDSTextStyle.regular
                      .copyWith(fontSize: 12, color: SDSColor.gray500)),
            ],
          ],
        ),
      );

  /// 9열 그리드 표. 가변폭 열이라 카드 너비를 꽉 채우고 가로스크롤이 없다.
  /// 같은 날짜 그룹은 같은 배경색이고, 날짜가 바뀔 때마다 흰색↔옅은 회색으로
  /// 번갈아 칠해 날짜 구분을 돕는다(날짜 기준=실제 라이딩 시각 pass_time).
  Widget _rideTable() {
    // 최신순으로 정렬된 _tracks를 훑으며 날짜 그룹별 음영 플래그를 만든다.
    final shaded = <bool>[];
    String? prevDate;
    bool shade = false; // 첫 그룹은 흰색
    for (final t in _tracks) {
      final d = _datePart(_when(t));
      if (prevDate != null && d != prevDate) shade = !shade;
      shaded.add(shade);
      prevDate = d;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tableHeader(),
        for (var i = 0; i < _tracks.length; i++)
          _tableRow(
            _tracks[i],
            shaded[i],
            // 같은 날짜 그룹의 시작/끝 행(위/아래 테두리용).
            isGroupStart: i == 0 ||
                _datePart(_when(_tracks[i])) !=
                    _datePart(_when(_tracks[i - 1])),
            isGroupEnd: i == _tracks.length - 1 ||
                _datePart(_when(_tracks[i])) !=
                    _datePart(_when(_tracks[i + 1])),
          ),
      ],
    );
  }

  Widget _tableHeader() => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: SDSColor.gray200)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < _colHeads.length; i++)
              _cell(_colHeads[i], _colFlex[i],
                  header: true,
                  right: i >= _firstNumericCol,
                  center: i == _pathCol),
          ],
        ),
      );

  Widget _tableRow(Map<String, dynamic> t, bool shaded,
      {bool isGroupStart = false, bool isGroupEnd = false}) {
    final viewable = t['viewable'] == true;
    final id = (t['riding_track_id'] as num).toInt();
    final when = _when(t);

    // 같은 날짜 그룹의 시작/끝에 스노우라이브 블루 테두리선.
    const line = BorderSide(color: SDSColor.snowliveBlue, width: 1.2);
    return Container(
      decoration: BoxDecoration(
        color: shaded ? _kRowShade : SDSColor.snowliveWhite,
        border: Border(
          top: isGroupStart ? line : BorderSide.none,
          bottom: isGroupEnd ? line : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          _cell(_dateLabel(_datePart(when)), _colFlex[0]),
          _cell(_timePart(when), _colFlex[1]),
          _cell('${t['slope'] ?? '-'}', _colFlex[2]),
          _cell(_fmtDurSec((t['duration_s'] as num?)?.toDouble() ?? 0),
              _colFlex[3]),
          _playCell(_colFlex[4], id, viewable),
          _cell('${t['gradient'] ?? 0}%', _colFlex[5], right: true),
          _cell('${t['distance'] ?? 0}m', _colFlex[6], right: true),
          _cell('${t['avg_speed'] ?? 0}', _colFlex[7], right: true),
          _cell('${t['max_speed'] ?? 0}', _colFlex[8], right: true),
          _cell('${t['score'] ?? 0}', _colFlex[9],
              right: true, color: SDSColor.gray900),
        ],
      ),
    );
  }

  /// 경로 열 — 가운데 재생버튼. 눌러야 라이딩 궤적 다이얼로그가 뜬다.
  Widget _playCell(int flex, int id, bool viewable) => Expanded(
        flex: flex,
        child: Center(
          child: viewable
              ? InkWell(
                  onTap: () => _openRideDialog(id),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: SDSColor.snowliveBlue, width: 1.6),
                    ),
                    child: const Icon(Icons.play_arrow,
                        size: 16, color: SDSColor.snowliveBlue),
                  ),
                )
              : const Icon(Icons.lock,
                  size: 15, color: SDSColor.gray300),
        ),
      );

  /// 라이딩 궤적을 **다이얼로그**로 띄운다(페이지 이동 없음). 상세 화면과 같은
  /// API(fetchRideDetail)·공통 위젯(RideDetailView)을 그대로 재사용한다.
  void _openRideDialog(int trackId) {
    final uid = Get.isRegistered<UserViewModel>()
        ? Get.find<UserViewModel>().user.user_id
        : null;
    final userId = (uid is int) ? uid : int.tryParse('$uid');
    final maxH = (Get.context != null)
        ? MediaQuery.of(Get.context!).size.height * 0.85
        : 640.0;

    Get.dialog(
      Dialog(
        backgroundColor: SDSColor.snowliveWhite,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560, maxHeight: maxH),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('라이딩 궤적',
                          style: SDSTextStyle.extraBold
                              .copyWith(fontSize: 18, color: SDSColor.gray900)),
                    ),
                    InkWell(
                      onTap: Get.back,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close, size: 22, color: SDSColor.gray500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: userId == null
                        ? _dialogNotice('로그인이 필요해요.')
                        : FutureBuilder<ApiResponse>(
                            future: _rideApi.fetchRideDetail(
                                userId: userId, trackId: trackId),
                            builder: (ctx, snap) {
                              if (snap.connectionState != ConnectionState.done) {
                                return const Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              final res = snap.data;
                              if (res != null &&
                                  res.success &&
                                  res.data is Map) {
                                final detail = RideDetail.fromJson(
                                    Map<String, dynamic>.from(res.data));
                                return RideDetailView(detail: detail);
                              }
                              return _dialogNotice(
                                  '라이딩 궤적 상세는 시즌권 이용 중일 때 볼 수 있어요.');
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogNotice(String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 4),
        child: Text(msg,
            style: SDSTextStyle.regular
                .copyWith(fontSize: 14, color: SDSColor.gray600)),
      );

  Widget _cell(String text, int flex,
      {bool header = false, bool right = false, bool center = false, Color? color}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: center
              ? TextAlign.center
              : (right ? TextAlign.right : TextAlign.left),
          style: (header ? SDSTextStyle.bold : SDSTextStyle.regular).copyWith(
            fontSize: 12,
            color: color ?? (header ? SDSColor.gray700 : SDSColor.gray800),
          ),
        ),
      ),
    );
  }

  /// 표시·그룹핑 기준 시각 — 실제 라이딩 시각(pass_time) 우선, 없으면 created_at.
  String _when(Map<String, dynamic> t) =>
      (t['pass_time'] ?? t['created_at'] ?? '').toString();

  /// 정렬 키(최신순). _when과 같은 기준.
  String _whenStr(Map<String, dynamic> t) => _when(t);

  /// "2026-10-19T12:34:.." / "2026-10-19 12:34"에서 날짜(yyyy-MM-dd).
  String _datePart(String when) {
    final s = when.replaceAll('T', ' ');
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  /// yyyy-MM-dd → YY.MM.DD (그리드 날짜 라벨).
  String _dateLabel(String ymd) => ymd.length >= 10
      ? '${ymd.substring(2, 4)}.${ymd.substring(5, 7)}.${ymd.substring(8, 10)}'
      : ymd;

  /// 시작 시각 HH:MM.
  String _timePart(String when) {
    final s = when.replaceAll('T', ' ');
    return s.length >= 16 ? s.substring(11, 16) : '';
  }

  /// 천단위 콤마(예: 7700 → 7,700).
  String _comma(num v) => v
      .toInt()
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  /// "0:03:21" / "0:03:21.123" → "3분 21초" 형태로 짧게.

  // ───────────────────────── 구매내역 ─────────────────────────

  Widget _historyCard(BuildContext context, SeasonPassViewModelWeb vm) => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('구매내역'),
            const SizedBox(height: SDSSpacing.sm),
            Obx(() {
              if (vm.history.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('구매내역이 없습니다.',
                      style: SDSTextStyle.regular
                          .copyWith(fontSize: 13, color: SDSColor.gray500)),
                );
              }
              return Column(
                children:
                    vm.history.map((h) => _historyRow(context, vm, h)).toList(),
              );
            }),
          ],
        ),
      );

  Widget _historyRow(
      BuildContext context, SeasonPassViewModelWeb vm, Map<String, dynamic> h) {
    final status = h['status']?.toString();
    final refundable = h['refund_status'] == null && h['refundable'] == true;
    final refundReq = h['refund_request']?.toString();
    String statusText;
    Color statusColor;
    if (status == 'REFUNDED') {
      statusText = '환불 완료';
      statusColor = SDSColor.gray500;
    } else if (refundReq == 'REQUESTED') {
      statusText = '환불 신청 접수';
      statusColor = SDSColor.snowliveBlue;
    } else {
      statusText = '결제 완료';
      statusColor = SDSColor.gray700;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${h['season'] ?? ''} 시즌권  ${_comma((h['amount'] is int) ? h['amount'] : int.tryParse('${h['amount']}') ?? 0)}원',
                    style: SDSTextStyle.bold
                        .copyWith(fontSize: 14, color: SDSColor.gray900)),
                const SizedBox(height: 2),
                Text(statusText,
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 12, color: statusColor)),
              ],
            ),
          ),
          if (refundable && refundReq == null)
            TextButton(
              onPressed: () =>
                  _confirmRefund(context, vm, h['order_id']?.toString() ?? ''),
              child: Text('환불 신청',
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: 13, color: SDSColor.red)),
            ),
        ],
      ),
    );
  }

  void _confirmRefund(
      BuildContext context, SeasonPassViewModelWeb vm, String orderId) {
    Get.dialog(AlertDialog(
      backgroundColor: SDSColor.snowliveWhite,
      title: Text('환불 신청',
          style:
              SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
      content: Text(
        '환불을 신청하시겠어요? 신청 접수 후 영업일 기준 3일 이내에 안내드립니다.',
        style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray700),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('취소',
              style: SDSTextStyle.regular.copyWith(color: SDSColor.gray500)),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await vm.requestRefund(orderId);
          },
          child: Text('신청',
              style: SDSTextStyle.bold.copyWith(color: SDSColor.red)),
        ),
      ],
    ));
  }

  Widget _messageBox(SeasonPassViewModelWeb vm) => Obx(() {
        final m = vm.message.value;
        if (m == null || m.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SDSColor.blue50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(m,
              style: SDSTextStyle.regular
                  .copyWith(fontSize: 13, color: SDSColor.gray700)),
        );
      });
}

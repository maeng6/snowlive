import 'package:com.snowlive/core/api/api_rideDetail.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/widget/w_web_back_icon_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 "내 라이딩 궤적" 목록. 각 항목 탭 → /ride-detail?id=N.
class RideListViewWeb extends StatefulWidget {
  const RideListViewWeb({super.key});

  @override
  State<RideListViewWeb> createState() => _RideListViewWebState();
}

class _RideListViewWebState extends State<RideListViewWeb> {
  final RideDetailAPI _api = RideDetailAPI();
  bool _loading = true;
  List<Map<String, dynamic>> _tracks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = Get.isRegistered<UserViewModel>()
        ? Get.find<UserViewModel>().user.user_id
        : null;
    final userId = (uid is int) ? uid : int.tryParse('$uid');
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    final res = await _api.fetchRideList(userId: userId);
    if (!mounted) return;
    if (res.success && res.data is Map && res.data['tracks'] is List) {
      _tracks = (res.data['tracks'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 시즌권 홈 바로가기 등에서 push로 들어오면 뒤로가기로 복귀.
                if (Navigator.of(context).canPop()) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: WebIconButton(
                      onTap: Get.back,
                      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      icon: const WebBackIcon(size: 24),
                    ),
                  ),
                  const SizedBox(height: SDSSpacing.sm),
                ],
                Text('라이딩 궤적',
                    style: SDSTextStyle.extraBold
                        .copyWith(fontSize: 22, color: SDSColor.gray900)),
                const SizedBox(height: SDSSpacing.lg),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_tracks.isEmpty)
                  Text('아직 기록된 궤적이 없어요. 폴리곤 라이딩 후 확인해주세요.',
                      style: SDSTextStyle.regular
                          .copyWith(fontSize: 14, color: SDSColor.gray500))
                else
                  ..._tracks.map(_row),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(Map<String, dynamic> t) {
    final viewable = t['viewable'] == true;
    final id = (t['riding_track_id'] as num).toInt();
    final when = (t['created_at']?.toString() ?? '').replaceAll('T', ' ');
    final whenShort = when.length >= 16 ? when.substring(5, 16) : when;
    return InkWell(
      onTap: viewable
          ? () => Get.toNamed('${WebRoutes.rideDetail}?id=$id')
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SDSColor.snowliveWhite,
          border: Border.all(color: SDSColor.gray200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${t['slope'] ?? '-'}  ·  $whenShort',
                      style: SDSTextStyle.bold.copyWith(
                          fontSize: 14,
                          color: viewable ? SDSColor.gray900 : SDSColor.gray400)),
                  const SizedBox(height: 4),
                  Text(
                      '거리 ${t['distance'] ?? 0}m · 평균 ${t['avg_speed'] ?? 0}km/h · 최고 ${t['max_speed'] ?? 0}km/h',
                      style: SDSTextStyle.regular
                          .copyWith(fontSize: 12, color: SDSColor.gray500)),
                ],
              ),
            ),
            Text(viewable ? '상세' : '프리미엄 전용',
                style: SDSTextStyle.regular.copyWith(
                    fontSize: 12,
                    color: viewable ? SDSColor.snowliveBlue : SDSColor.gray400)),
          ],
        ),
      ),
    );
  }
}

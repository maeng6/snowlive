import 'package:com.snowlive/core/api/api_rideDetail.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rideDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/widget/ride/w_ride_detail_view.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 유료 궤적 상세 뷰. '/ride-detail?id=N'. 유료 게이트는 서버가 판정(403이면 안내).
class RideDetailViewWeb extends StatefulWidget {
  const RideDetailViewWeb({super.key});

  @override
  State<RideDetailViewWeb> createState() => _RideDetailViewWebState();
}

class _RideDetailViewWebState extends State<RideDetailViewWeb> {
  final RideDetailAPI _api = RideDetailAPI();
  bool _loading = true;
  bool _forbidden = false;
  RideDetail? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final idStr = Get.parameters['id'];
    final trackId = int.tryParse(idStr ?? '');
    final uid = Get.isRegistered<UserViewModel>()
        ? Get.find<UserViewModel>().user.user_id
        : null;
    final userId = (uid is int) ? uid : int.tryParse('$uid');
    if (trackId == null || userId == null) {
      setState(() => _loading = false);
      return;
    }
    final res = await _api.fetchRideDetail(userId: userId, trackId: trackId);
    if (!mounted) return;
    if (res.success && res.data is Map) {
      _detail = RideDetail.fromJson(Map<String, dynamic>.from(res.data));
    } else {
      _forbidden = true;
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
            child: _body(),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_forbidden || _detail == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('프리미엄 전용',
              style: SDSTextStyle.extraBold
                  .copyWith(fontSize: 20, color: SDSColor.gray900)),
          const SizedBox(height: SDSSpacing.md),
          Text('라이딩 궤적 상세는 시즌권 이용 중일 때 볼 수 있어요.',
              style:
                  SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray600)),
          const SizedBox(height: SDSSpacing.lg),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => Get.toNamed(WebRoutes.seasonPass),
              style: ElevatedButton.styleFrom(
                backgroundColor: SDSColor.snowliveBlue,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('시즌권 보기',
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: 15, color: SDSColor.snowliveWhite)),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('라이딩 궤적',
            style: SDSTextStyle.extraBold
                .copyWith(fontSize: 22, color: SDSColor.gray900)),
        const SizedBox(height: SDSSpacing.lg),
        RideDetailView(detail: _detail!),
      ],
    );
  }
}

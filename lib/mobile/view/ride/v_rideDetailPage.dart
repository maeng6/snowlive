import 'package:com.snowlive/core/api/api_rideDetail.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rideDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/widget/ride/w_ride_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 모바일 유료 궤적 상세. 공통 위젯 RideDetailView를 그대로 재사용.
/// 유료 게이트는 서버가 판정(403이면 안내). Get.to(() => RideDetailPage(trackId: id)).
class RideDetailPage extends StatefulWidget {
  final int trackId;
  const RideDetailPage({super.key, required this.trackId});

  @override
  State<RideDetailPage> createState() => _RideDetailPageState();
}

class _RideDetailPageState extends State<RideDetailPage> {
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
    final uid = Get.isRegistered<UserViewModel>()
        ? Get.find<UserViewModel>().user.user_id
        : null;
    final userId = (uid is int) ? uid : int.tryParse('$uid');
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    final res = await _api.fetchRideDetail(userId: userId, trackId: widget.trackId);
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
    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
      appBar: AppBar(
        backgroundColor: SDSColor.snowliveWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: SDSColor.gray900),
        title: Text('라이딩 궤적',
            style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: (_forbidden || _detail == null)
                  ? _locked()
                  : RideDetailView(detail: _detail!),
            ),
    );
  }

  Widget _locked() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('프리미엄 전용',
              style: SDSTextStyle.extraBold
                  .copyWith(fontSize: 20, color: SDSColor.gray900)),
          const SizedBox(height: 10),
          Text('라이딩 궤적 상세는 시즌권 이용 중일 때 볼 수 있어요.',
              style:
                  SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray600)),
        ],
      );
}

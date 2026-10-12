import 'package:com.snowlive/core/api/api_rideDetail.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/mobile/view/ride/v_rideDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 모바일 "내 라이딩 궤적" 목록. 항목 탭 → RideDetailPage.
class RideListPage extends StatefulWidget {
  const RideListPage({super.key});

  @override
  State<RideListPage> createState() => _RideListPageState();
}

class _RideListPageState extends State<RideListPage> {
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
          : _tracks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('아직 기록된 궤적이 없어요. 폴리곤 라이딩 후 확인해주세요.',
                      style: SDSTextStyle.regular
                          .copyWith(fontSize: 14, color: SDSColor.gray500)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tracks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _row(_tracks[i]),
                ),
    );
  }

  Widget _row(Map<String, dynamic> t) {
    final viewable = t['viewable'] == true;
    final id = (t['riding_track_id'] as num).toInt();
    final when = (t['created_at']?.toString() ?? '').replaceAll('T', ' ');
    final whenShort = when.length >= 16 ? when.substring(5, 16) : when;
    return InkWell(
      onTap: viewable ? () => Get.to(() => RideDetailPage(trackId: id)) : null,
      child: Container(
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

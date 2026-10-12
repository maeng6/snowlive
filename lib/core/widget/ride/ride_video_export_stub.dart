import 'package:com.snowlive/core/model/m_rideDetail.dart';

enum RideVideoResult { saved, failed, unsupported }

/// 웹/비지원 플랫폼: 영상 저장 미지원.
Future<RideVideoResult> exportRideVideo({
  required RideDetail detail,
  int size = 720,
  int fps = 30,
  int durationSec = 6,
}) async =>
    RideVideoResult.unsupported;

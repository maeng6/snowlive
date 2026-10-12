import 'dart:io';
import 'dart:ui' as ui;

import 'package:com.snowlive/core/model/m_rideDetail.dart';
import 'package:com.snowlive/core/widget/ride/w_ride_track_painter.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

enum RideVideoResult { saved, failed, unsupported }

/// 궤적 재생 애니메이션을 오프스크린으로 프레임 렌더(PictureRecorder) →
/// raw RGBA로 모아 ffmpeg(libx264)로 mp4 인코딩 → gal로 갤러리 저장.
/// (PaceFace video_export_service의 rawvideo 파이프 방식 참고)
Future<RideVideoResult> exportRideVideo({
  required RideDetail detail,
  int size = 720,
  int fps = 30,
  int durationSec = 6,
}) async {
  try {
    final total = fps * durationSec;
    final dir = await getTemporaryDirectory();
    final rawPath = '${dir.path}/ride_${detail.ridingTrackId}.rgba';
    final raw = File(rawPath);
    final sink = raw.openWrite();

    for (int i = 0; i < total; i++) {
      final p = (i + 1) / total;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      RideTrackPainter(
        detail: detail,
        progress: p,
        showMovingMarker: true,
        showGpsPoints: false, // 영상 궤적엔 점 미표시
        smooth: true, // 5배 보간으로 부드럽게
      ).paint(canvas, Size(size.toDouble(), size.toDouble()));
      final picture = recorder.endRecording();
      final img = await picture.toImage(size, size);
      final bd = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      img.dispose();
      picture.dispose();
      if (bd != null) sink.add(bd.buffer.asUint8List());
    }
    await sink.flush();
    await sink.close();

    final outPath = '${dir.path}/snowlive_track_${detail.ridingTrackId}.mp4';
    final cmd =
        '-y -f rawvideo -pixel_format rgba -video_size ${size}x$size -framerate $fps '
        '-i "$rawPath" -c:v libx264 -b:v 6M -pix_fmt yuv420p "$outPath"';
    final session = await FFmpegKit.execute(cmd);
    final rc = await session.getReturnCode();
    try {
      raw.deleteSync();
    } catch (_) {}

    if (!ReturnCode.isSuccess(rc)) {
      debugPrint('[RideVideo] ffmpeg 실패: $rc');
      return RideVideoResult.failed;
    }
    await Gal.putVideo(outPath);
    return RideVideoResult.saved;
  } catch (e) {
    debugPrint('[RideVideo] 영상 저장 실패: $e');
    return RideVideoResult.failed;
  }
}

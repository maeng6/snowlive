import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class IntroVideoDialog extends StatefulWidget {
  const IntroVideoDialog({super.key});

  @override
  State<IntroVideoDialog> createState() => _IntroVideoDialogState();
}

class _IntroVideoDialogState extends State<IntroVideoDialog> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/video/snowlive_branding_video.mp4',
    );

    _controller.addListener(() {
      final value = _controller.value;

      if (value.hasError) {
        if (mounted) setState(() => _errorMessage = value.errorDescription);
      }

      if (value.isInitialized) {
        final finished =
            value.position >= value.duration && !value.isPlaying;

        if (finished && mounted) {
          if (Get.isDialogOpen ?? false) Get.back();
        }
      }
    });

    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isInitialized = true);
      _controller.play();
    }).catchError((e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onClosePressed() {
    _controller.pause();
    if (Get.isDialogOpen ?? false) Get.back();
  }

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 6,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // 영상 또는 로딩 or 에러
              SizedBox(
                width: double.infinity,
                child: _errorMessage != null
                    ? _buildError()
                    : _isInitialized
                    ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                    : AspectRatio(
                  aspectRatio: 9/16,
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: SDSColor.snowliveWhite,
                          ),
                        ),
                      ),
                    ),
              ),

              // 닫기 버튼 (팝업 내부 오른쪽 상단)
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: _onClosePressed,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: Colors.black,
      height: 200,
      child: Center(
        child: Text(
          '영상을 불러오지 못했습니다.',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

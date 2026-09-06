import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewCreate_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 색상 배경 위에 얹는 기본 `LIVE CREW` 마크.
const String kCrewDefaultLogoAsset = 'assets/imgs/liveCrew/img_liveCrew_logo_setCrewImage.png';

/// 크루 로고 미리보기 + `이미지 직접 등록` + 대표 색상 스와치.
///
/// 크루 만들기 3단계와 크루 설정의 `크루 이미지 및 컬러 설정`이 **같은 UI**라서 한 위젯으로
/// 둔다. 제목·부제는 화면마다 달라서 여기 넣지 않는다.
class CrewImageColorPicker extends StatelessWidget {
  /// 방금 고른 파일. 있으면 이걸 미리보기에 쓴다.
  final XFile? pickedFile;

  /// 서버에 저장돼 있는 로고. [pickedFile]이 없을 때만 쓴다(설정 화면).
  final String? currentLogoUrl;

  final Color color;
  final int colorIndex;
  final VoidCallback onPickImage;

  /// × 를 눌렀을 때. 고른 파일과 기존 로고 둘 다 없으면 × 를 그리지 않는다.
  final VoidCallback onRemoveImage;

  final ValueChanged<int> onColorSelected;

  /// 모바일에서 색상 줄을 화면 아래(하단 버튼 바로 위)로 밀지 여부.
  /// true면 **높이가 정해진 부모** 안에서 써야 한다.
  final bool fillHeight;

  const CrewImageColorPicker({
    super.key,
    required this.pickedFile,
    required this.color,
    required this.colorIndex,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onColorSelected,
    this.currentLogoUrl,
    this.fillHeight = false,
  });

  bool get _hasImage => pickedFile != null || (currentLogoUrl?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final top = [
      Center(child: _buildPreview()),
      const SizedBox(height: SDSSpacing.md),
      Center(
        child: OutlinedButton(
          onPressed: onPickImage,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: SDSColor.gray200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child: Text(
            '이미지 직접 등록',
            style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
          ),
        ),
      ),
    ];

    final bottom = [
      Text(
        '크루 대표 색상 선택하기',
        textAlign: TextAlign.center,
        style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
      ),
      const SizedBox(height: SDSSpacing.md),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < kCrewColors.length; i++) ...[
            if (i > 0) const SizedBox(width: SDSSpacing.sm),
            _ColorSwatch(
              color: kCrewColors[i],
              isSelected: i == colorIndex,
              onTap: () => onColorSelected(i),
            ),
          ],
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...top,
        // 목업 모바일은 색상 줄이 하단 버튼 바로 위에 붙는다.
        if (fillHeight) const Spacer() else const SizedBox(height: SDSSpacing.xxl),
        ...bottom,
      ],
    );
  }

  Widget _buildPreview() {
    final file = pickedFile;
    final Widget inner;
    if (file != null) {
      inner = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        // 웹의 XFile.path는 blob URL이라 Image.network로 그린다.
        child: Image.network(file.path, width: 88, height: 88, fit: BoxFit.cover),
      );
    } else if (currentLogoUrl?.isNotEmpty ?? false) {
      inner = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: WebNetworkImage(url: currentLogoUrl, width: 88, height: 88),
      );
    } else {
      inner = Image.asset(kCrewDefaultLogoAsset, width: 88, height: 88, fit: BoxFit.contain);
    }

    return SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(32)),
            alignment: Alignment.center,
            child: inner,
          ),
          if (_hasImage)
            Positioned(
              top: -4,
              right: -4,
              child: Material(
                color: SDSColor.gray900,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onRemoveImage,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(Icons.close, size: 18, color: SDSColor.snowliveWhite),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        // 선택된 색은 목업처럼 검은 링을 두른다.
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected ? Border.all(color: SDSColor.gray900, width: 2) : null,
          ),
        ),
      ),
    );
  }
}

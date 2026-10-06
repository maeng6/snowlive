import 'package:com.snowlive/core/data/imgaUrls/Data_url_image.dart';
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
      // 로고 ↔ `이미지 직접 등록` 30 (목업 — 로고 bottom 550, pill top 580).
      const SizedBox(height: 30),
      Center(
        // 목업(174:90258) — 테두리 gray200 · 라운드 20 · 패딩 12/9 · ExtraBold 13.
        // **높이 35** = 9 + 글자 17 + 9. 줄 높이를 묶지 않으면 Pretendard가 더 크게
        // 잡아 37~38이 된다(칩에서 겪은 것과 같은 문제).
        child: OutlinedButton(
          onPressed: onPickImage,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: SDSColor.gray200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            // 웹 기본 compact density가 높이를 깎지 않게 고정한다.
            visualDensity: VisualDensity.standard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            '이미지 직접 등록',
            style: SDSTextStyle.extraBold
                .copyWith(fontSize: 13, height: 17 / 13, color: SDSColor.gray900),
          ),
        ),
      ),
    ];

    final bottom = [
      Text(
        '크루 대표 색상 선택하기',
        textAlign: TextAlign.center,
        style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray900),
      ),
      // 라벨 ↔ 색 줄 12 (목업 16에서 한 단계 줄임 — 사용자 확정).
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < kCrewColors.length; i++) ...[
            // 색 원 사이 10 (목업 16에서 줄임 — 8개가 한 묶음으로 보이게).
            if (i > 0) const SizedBox(width: 10),
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
        // pill ↔ 색상 라벨 52 (목업 ≈53).
        if (fillHeight) const Spacer() else const SizedBox(height: 52),
        ...bottom,
      ],
    );
  }

  Widget _buildPreview() {
    final file = pickedFile;
    final Widget inner;
    if (file != null) {
      inner = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        // 웹의 XFile.path는 blob URL이라 Image.network로 그린다.
        child: Image.network(file.path, width: 80, height: 80, fit: BoxFit.cover),
      );
    } else if (currentLogoUrl?.isNotEmpty ?? false) {
      inner = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: WebNetworkImage(url: currentLogoUrl, width: 80, height: 80),
      );
    } else {
      // 기본 마크는 **색마다 다른 이미지**다(크루 카드·목록이 쓰는 것과 같은 맵).
      // 로컬 에셋은 한 가지 색으로 고정이라 색을 바꿔도 그대로였다.
      final defaultLogoUrl = crewDefaultLogoUrl[crewColorToHex(color)];
      inner = defaultLogoUrl == null
          ? Image.asset(kCrewDefaultLogoAsset, width: 80, height: 80, fit: BoxFit.contain)
          : WebNetworkImage(
              url: defaultLogoUrl,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              // 색을 바꾸면 **다른 URL**을 새로 받는다 → 그동안 이전 마크를 들고 있고
              // (gapless), 스켈레톤 밑판은 끈다. 밑판을 두면 배경이 투명한 아이콘이라
              // 색 타일 위에 흰 사각이 깜빡인다(실측).
              gaplessPlayback: true,
              showPlaceholder: false,
            );
    }

    // 목업(174:90241) — 색 타일 150 라운드 30, 안쪽 로고 80 라운드 16.
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
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
        // 선택된 색은 목업처럼 검은 링을 두른다. 링과 색 사이에 **흰 링**을 한 겹 더
        // 끼워 띄운 것처럼 보이게 한다(검정이 색에 바로 붙으면 탁해 보인다).
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isSelected ? SDSColor.snowliveWhite : color,
            shape: BoxShape.circle,
            border: isSelected ? Border.all(color: SDSColor.gray900, width: 2) : null,
          ),
          child: isSelected
              ? Padding(
                  // 흰 간격 2 — 바깥 검정 링 2 + 흰 2 + 색 원(=24−8=16).
                  padding: const EdgeInsets.all(2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

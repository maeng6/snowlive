import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/model/m_seasonRidingCard.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_ridingCard.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:share_plus/share_plus.dart';

class RidingCardListView extends StatefulWidget {
  @override
  State<RidingCardListView> createState() => _RidingCardListViewState();
}

class _RidingCardListViewState extends State<RidingCardListView> {
  late RidingCardViewModel _ridingCardViewModel;
  late UserViewModel _userViewModel;

  // 시즌 카드 저장/공유용
  final GlobalKey _seasonCardKey = GlobalKey();
  bool _isSeasonSaving = false;
  bool _isSeasonSaved = false;
  bool _isSeasonSharing = false;

  // pull-to-refresh 중인지 여부
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _ridingCardViewModel = Get.find<RidingCardViewModel>();
    _userViewModel = Get.find<UserViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // 저장된 카드 타입 불러오기
    await _ridingCardViewModel.loadCardTypeMap();

    await _ridingCardViewModel.fetchSeasonRidingCard(
      userId: _userViewModel.user.user_id,
      season: _ridingCardViewModel.selectedSeasonDb.value,
    );
    await _ridingCardViewModel.fetchDailyRidingCardList(
      userId: _userViewModel.user.user_id,
    );
  }

  Future<void> _onRefresh() async {
    _isRefreshing = true;
    await _loadData();
    _isRefreshing = false;
  }

  Future<void> _saveSeasonCardImage() async {
    if (_isSeasonSaving) return;

    setState(() {
      _isSeasonSaving = true;
    });

    try {
      bool hasAccess = await Gal.hasAccess(toAlbum: true);

      if (!hasAccess) {
        hasAccess = await Gal.requestAccess(toAlbum: true);

        if (!hasAccess) {
          _showPermissionSettingsDialog();
          setState(() {
            _isSeasonSaving = false;
          });
          return;
        }
      }

      RenderRepaintBoundary boundary = _seasonCardKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Get.snackbar('오류', '이미지 생성에 실패했습니다.');
        setState(() {
          _isSeasonSaving = false;
        });
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final fileName = 'snowlive_season_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      await Gal.putImage(tempFile.path, album: 'Snowlive');
      await tempFile.delete();

      setState(() {
        _isSeasonSaved = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isSeasonSaved = false;
          });
        }
      });
    } catch (e) {
      debugPrint('시즌 카드 이미지 저장 오류: $e');
    } finally {
      setState(() {
        _isSeasonSaving = false;
      });
    }
  }

  Future<void> _shareSeasonCardImage() async {
    if (_isSeasonSharing) return;

    setState(() {
      _isSeasonSharing = true;
    });

    try {
      RenderRepaintBoundary boundary = _seasonCardKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Get.snackbar('오류', '이미지 생성에 실패했습니다.');
        if (mounted) {
          setState(() {
            _isSeasonSharing = false;
          });
        }
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final fileName = 'snowlive_season_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      Share.shareXFiles(
        [XFile(tempFile.path)],
        text: '스노우라이브에서 ${_userViewModel.user.display_name}님의 시즌 기록을 공유합니다!',
      );
    } catch (e) {
      debugPrint('시즌 카드 이미지 공유 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSeasonSharing = false;
        });
      }
    }
  }

  void _showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: SDSColor.snowliveWhite,
        contentPadding: const EdgeInsets.only(bottom: 28, left: 28, right: 28, top: 30),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '사진 접근 권한 필요',
              style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '이미지를 저장하려면 사진 접근 권한이\n필요합니다. 설정에서 권한을 허용해주세요.',
              style: SDSTextStyle.regular.copyWith(fontSize: 14, height: 1.4, color: SDSColor.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.gray200,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '설정으로 이동',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(44),
      child: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: SvgPicture.asset(
              'assets/imgs/icons/icon_snowLive_back.svg',
              width: 26,
              height: 26,
            ),
            highlightColor: Colors.transparent,
          ),
        ),
        title: Text(
          '라이딩 기록 카드',
          style: SDSTextStyle.extraBold.copyWith(
            color: SDSColor.gray900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => Padding(
            padding: EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => _showSeasonBottomSheet(),
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      overlayColor: Colors.transparent,
                      padding: EdgeInsets.only(right: 32, left: 12, top: 2, bottom: 1),
                      side: BorderSide(
                        width: 1,
                        color: SDSColor.gray100,
                      ),
                      backgroundColor: SDSColor.snowliveWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      _ridingCardViewModel.selectedSeason.value.replaceAll('/', ''),
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 13,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => _showSeasonBottomSheet(),
                    child: Image.asset(
                      'assets/imgs/icons/icon_check_round_black.png',
                      fit: BoxFit.cover,
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final isLoading = _ridingCardViewModel.isLoadingSeasonCard.value ||
        _ridingCardViewModel.isLoadingDailyList.value;

    // 초기 로딩 시에만 전체 화면 로딩 표시 (당겨서 새로고침 시에는 표시 안함)
    if (isLoading && !_isRefreshing) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            backgroundColor: SDSColor.gray100,
            color: SDSColor.gray300.withOpacity(0.6),
          ),
        ),
      );
    }

    return RefreshIndicator(
      strokeWidth: 2,
      backgroundColor: SDSColor.snowliveBlue,
      color: SDSColor.snowliveWhite,
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // 시즌 카드
            _buildSeasonCard(),
            SizedBox(
              height: (_ridingCardViewModel.seasonRidingCard.value != null &&
                  ((_ridingCardViewModel.seasonRidingCard.value!.totalSlopeCount ?? 0) != 0 ||
                   (_ridingCardViewModel.seasonRidingCard.value!.totalDistance ?? 0) != 0 ||
                   (_ridingCardViewModel.seasonRidingCard.value!.topSpeed ?? 0) != 0))
                  ? 48
                  : 0,
            ),
            // 데일리 카드 타이틀 + 보기 전환 버튼
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '라이딩 기록 카드 리스트',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 16,
                      color: SDSColor.snowliveBlack,
                    ),
                  ),
                  Row(
                    children: [
                      // 카드 버튼
                      GestureDetector(
                        onTap: () {
                          if (!_ridingCardViewModel.isGridView.value) {
                            HapticFeedback.lightImpact();
                            _ridingCardViewModel.isGridView.value = true;
                          }
                        },
                        child: Image.asset(
                          _ridingCardViewModel.isGridView.value
                              ? 'assets/imgs/icons/icon_view_card_on.png'
                              : 'assets/imgs/icons/icon_view_card_off.png',
                          width: 32,
                          height: 32,
                        ),
                      ),
                      SizedBox(width: 6),
                      // 리스트 버튼
                      GestureDetector(
                        onTap: () {
                          if (_ridingCardViewModel.isGridView.value) {
                            HapticFeedback.lightImpact();
                            _ridingCardViewModel.isGridView.value = false;
                          }
                        },
                        child: Image.asset(
                          !_ridingCardViewModel.isGridView.value
                              ? 'assets/imgs/icons/icon_view_list_on.png'
                              : 'assets/imgs/icons/icon_view_list_off.png',
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // 데일리 카드 (월별 그룹화)
            _buildDailyCardSection(),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showSeasonBottomSheet()           {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._ridingCardViewModel.seasonList.map((season) {
                    final isSelected = _ridingCardViewModel.selectedSeason.value == season['display'];
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        if (!isSelected) {
                          _ridingCardViewModel.changeSeason(
                            season['display']!,
                            season['db']!,
                          );
                          CustomFullScreenDialog.showDialog();
                          await _ridingCardViewModel.fetchSeasonRidingCard(
                            userId: _userViewModel.user.user_id,
                            season: season['db']!,
                          );
                          CustomFullScreenDialog.cancelDialog();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            season['display']!,
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 15,
                              color: isSelected ? SDSColor.snowliveBlue : SDSColor.gray900,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeasonCard() {
    final seasonCard = _ridingCardViewModel.seasonRidingCard.value;

    // 시즌 카드가 없거나 모든 기록이 0인 경우
    final bool hasNoRecord = seasonCard == null ||
        ((seasonCard.totalSlopeCount ?? 0) == 0 &&
         (seasonCard.totalDistance ?? 0) == 0 &&
         (seasonCard.topSpeed ?? 0) == 0);

    if (hasNoRecord) {
      return SizedBox.shrink();
    }

    // 기존 라이딩 기록 카드 UI 스타일
    return Column(
      children: [
        // 카드 (RepaintBoundary로 감싸서 이미지 캡처 가능)
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showSeasonCardDetail();
          },
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: RepaintBoundary(
                key: _seasonCardKey,
                child: SizedBox(
                  width: 240,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                  aspectRatio: 960 / 1524,
                  child: Stack(
                    children: [
                      // 배경 이미지
                      Positioned.fill(
                        child: Image.asset(
                          'assets/imgs/imgs/img_summury_bg_3.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // 상단: 프로필 이미지, 닉네임, 시즌
                      Positioned(
                        top: 28,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [
                            // 프로필 이미지
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: (_userViewModel.user.profile_image_url_user?.isNotEmpty ?? false)
                                    ? ExtendedImage.network(
                                        _userViewModel.user.profile_image_url_user!,
                                        fit: BoxFit.cover,
                                        cache: true,
                                        loadStateChanged: (state) {
                                          if (state.extendedImageLoadState == LoadState.failed) {
                                            return Image.asset(
                                              'assets/imgs/profile/img_profile_default_circle.png',
                                              fit: BoxFit.cover,
                                            );
                                          }
                                          return null;
                                        },
                                      )
                                    : Image.asset(
                                        'assets/imgs/profile/img_profile_default_circle.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // 닉네임
                            Text(
                              _userViewModel.user.display_name ?? '',
                              style: SDSTextStyle.bold.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            // 시즌
                            Text(
                              _ridingCardViewModel.selectedSeason.value,
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 중앙: 라이딩 정보
                      Positioned(
                        top: 128,
                        bottom: 50,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 총 라이딩 숫자
                              Text(
                                (seasonCard.totalSlopeCount ?? 0) == 0 ? '-' : '${seasonCard.totalSlopeCount}',
                                style: SDSTextStyle.extraBold.copyWith(
                                  fontSize: 28,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // 시즌 총 라이딩 라벨
                              Text(
                                '시즌 총 라이딩',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 9,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // 총 거리 & 평균 경사도 & 최고 속도
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 총 거리
                                  Expanded(
                                    child: Column(
                                      children: [
                                        (seasonCard.totalDistance ?? 0) == 0
                                            ? Text(
                                                '-',
                                                style: SDSTextStyle.extraBold.copyWith(
                                                  fontSize: 17,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                                textBaseline: TextBaseline.alphabetic,
                                                children: [
                                                  Text(
                                                    (seasonCard.totalDistance ?? 0).toStringAsFixed(0),
                                                    style: SDSTextStyle.extraBold.copyWith(
                                                      fontSize: 17,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 1),
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 2),
                                                    child: Text(
                                                      'km',
                                                      style: SDSTextStyle.regular.copyWith(
                                                        fontSize: 9,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        Text(
                                          '총 거리',
                                          style: SDSTextStyle.regular.copyWith(
                                            fontSize: 9,
                                            color: Colors.white.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 평균 경사도
                                  Expanded(
                                    child: Column(
                                      children: [
                                        (seasonCard.avgSlope ?? 0) == 0
                                            ? Text(
                                                '-',
                                                style: SDSTextStyle.extraBold.copyWith(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                                textBaseline: TextBaseline.alphabetic,
                                                children: [
                                                  Text(
                                                    (seasonCard.avgSlope ?? 0).toStringAsFixed(1),
                                                    style: SDSTextStyle.extraBold.copyWith(
                                                      fontSize: 17,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 1),
                                                  Text(
                                                    '°',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        Text(
                                          '평균 경사도',
                                          style: SDSTextStyle.regular.copyWith(
                                            fontSize: 9,
                                            color: Colors.white.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 최고 속도
                                  Expanded(
                                    child: Column(
                                      children: [
                                        (seasonCard.topSpeed ?? 0) == 0
                                            ? Text(
                                                '-',
                                                style: SDSTextStyle.extraBold.copyWith(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                                textBaseline: TextBaseline.alphabetic,
                                                children: [
                                                  Text(
                                                    (seasonCard.topSpeed ?? 0).toStringAsFixed(0),
                                                    style: SDSTextStyle.extraBold.copyWith(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 1),
                                                  Text(
                                                    'km/h',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 9,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        Text(
                                          '최고 속도',
                                          style: SDSTextStyle.regular.copyWith(
                                            fontSize: 9,
                                            color: Colors.white.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 하단: 스노우라이브 로고
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            'assets/imgs/logos/snowliveLogo_main_white.png',
                            height: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
            ),
          ),
        ),
        // 카드 아래 버튼들
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 공유 버튼
            GestureDetector(
              onTap: _isSeasonSharing ? null : _shareSeasonCardImage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: SDSColor.gray200,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/imgs/icons/icon_summury_share.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(SDSColor.gray900, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            // 이미지 저장 버튼
            GestureDetector(
              onTap: (_isSeasonSaving || _isSeasonSaved) ? null : _saveSeasonCardImage,
              child: Container(
                width: 110,
                height: 44,
                decoration: BoxDecoration(
                  color: _isSeasonSaved ? const Color(0xFF34C759) : SDSColor.gray900,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: _isSeasonSaving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : _isSeasonSaved
                          ? Icon(
                              Icons.check,
                              size: 22,
                              color: Colors.white,
                            )
                          : Text(
                              '이미지 저장',
                              style: SDSTextStyle.bold.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 날짜에서 일(day) 추출 (예: "2025-01-30" -> "30")
  String _getDayFromDate(String? date) {
    if (date == null || date.isEmpty) return '';
    final parts = date.split('-');
    if (parts.length >= 3) {
      return parts[2];
    }
    return '';
  }

  Widget _buildDailyCardSection() {
    final groupedCards = _ridingCardViewModel.groupedDailyCardsByMonth;

    // 데일리 카드가 없거나, 모든 카드의 기록이 0인지 확인
    bool hasNoValidRecord = groupedCards.isEmpty;
    if (!hasNoValidRecord) {
      // 모든 카드가 0인지 확인
      hasNoValidRecord = groupedCards.values.every((cards) {
        return cards.every((card) {
          return (card.totalSlopeCount ?? 0) == 0 &&
              (card.totalDistance ?? 0) == 0 &&
              (card.topSpeed ?? 0) == 0;
        });
      });
    }

    if (hasNoValidRecord) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/imgs/icons/icon_nodata.png',
                width: 72,
                height: 72,
              ),
              SizedBox(height: 8),
              Text(
                '일일 기록이 없습니다',
                style: SDSTextStyle.regular.copyWith(
                  color: SDSColor.gray500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedCards.entries.map((entry) {
        final monthTitle = entry.key;
        final cards = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 월 타이틀
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: EdgeInsets.only(bottom: _ridingCardViewModel.isGridView.value ? 12 : 0),
                child: Text(
                  monthTitle,
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 18,
                    color: SDSColor.gray900,
                  ),
                ),
              ),
            ),
            // 그리드 또는 리스트
            _ridingCardViewModel.isGridView.value
                ? _buildMonthlyGrid(cards)
                : _buildMonthlyList(cards),
            SizedBox(
                height: _ridingCardViewModel.isGridView.value ? 16 : 60),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyGrid(List<DailyRidingCard> cards) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 6,
          childAspectRatio: 960 / 1524,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return _buildDailyCardItem(card);
        },
      ),
    );
  }

  Widget _buildMonthlyList(List<DailyRidingCard> cards) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: cards.map((card) => _buildDailyListItem(card)).toList(),
      ),
    );
  }

  Widget _buildDailyListItem(DailyRidingCard card) {
    final day = _getDayFromDate(card.date);

    return Obx(() {
      // cardTypeMap 변경 감지를 위해 Obx로 감싸기
      final _ = _ridingCardViewModel.cardTypeMap[card.cardId ?? 0];
      final currentCardType = _ridingCardViewModel.getCardType(card.cardId ?? 0);

      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showDailyCardDetail(card);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: SDSColor.gray100,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // 좌측: 날짜 + 요일
              SizedBox(
                width: 90,
                child: Text(
                  '${day}일 (${card.weekday ?? ''})',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 15,
                    color: SDSColor.snowliveBlack,
                  ),
                ),
              ),
              // 중앙: 라이더 타이틀 + 총 라이딩
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (card.riderTitle != null && card.riderTitle!.isNotEmpty)
                      Text(
                        card.riderTitle!,
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.gray500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        '-',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.gray500,
                        ),
                      ),
                    SizedBox(height: 2),
                    Text(
                      '총 ${card.totalSlopeCount ?? 0}회 라이딩',
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 15,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              // 우측: 미니 카드 이미지 (단순 배경)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 40,
                  height: 64,
                  child: Image.asset(
                    currentCardType == 0
                        ? 'assets/imgs/imgs/img_summury_bg.png'
                        : 'assets/imgs/imgs/img_summury_bg_2.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDailyCardItem(DailyRidingCard card) {
    return Obx(() {
      // cardTypeMap 변경 감지를 위해 Obx로 감싸기
      final _ = _ridingCardViewModel.cardTypeMap[card.cardId ?? 0];
      final currentCardType = _ridingCardViewModel.getCardType(card.cardId ?? 0);

      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showDailyCardDetail(card);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 960 / 1524,
            child: Stack(
              children: [
                // 배경 이미지 (카드 타입에 따라 다름)
                Positioned.fill(
                  child: Image.asset(
                    currentCardType == 0
                        ? 'assets/imgs/imgs/img_summury_bg.png'
                        : 'assets/imgs/imgs/img_summury_bg_2.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // 상단: 프로필 이미지 + 닉네임 + 날짜
                Positioned(
                  top: 16,
                  left: 8,
                  right: 8,
                  child: Column(
                    children: [
                      // 프로필 이미지
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: (_userViewModel.user.profile_image_url_user?.isNotEmpty ?? false)
                              ? ExtendedImage.network(
                                  _userViewModel.user.profile_image_url_user!,
                                  fit: BoxFit.cover,
                                  cache: true,
                                  loadStateChanged: (state) {
                                    if (state.extendedImageLoadState == LoadState.failed) {
                                      return Image.asset(
                                        'assets/imgs/profile/img_profile_default_circle.png',
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    return null;
                                  },
                                )
                              : Image.asset(
                                  'assets/imgs/profile/img_profile_default_circle.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(height: 3),
                      // 닉네임
                      Text(
                        _userViewModel.user.display_name ?? '',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 날짜 + 요일
                      Text(
                        '${card.date ?? ''} ${card.weekday ?? ''}',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 5,
                          color: Colors.white,
                        ),
                      ),
                      // 라이더 타이틀
                      if (card.riderTitle != null && card.riderTitle!.isNotEmpty) ...[
                        SizedBox(height: 2),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: currentCardType == 0
                                ? const Color(0xFF1B3A5C)
                                : const Color(0xFFE2EDF8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            card.riderTitle!,
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 5,
                              color: currentCardType == 0
                                  ? Colors.white
                                  : const Color(0xFF000000),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 중앙: 라이딩 정보 (카드 타입에 따라 다른 내용)
                Positioned(
                  top: 76,
                  bottom: 20,
                  left: 4,
                  right: 4,
                  child: Center(
                    child: currentCardType == 0
                        ? _buildGridCardType0Content(card)
                        : _buildGridCardType1Content(card),
                  ),
                ),
                // 하단: 스노우라이브 로고
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      'assets/imgs/logos/snowliveLogo_main_white.png',
                      height: 4,
                    ),
                  ),
                ),
                // 좌상단: 날짜 뱃지
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_getDayFromDate(card.date)}일',
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 12,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // 미니 카드용 카드 타입 0 컨텐츠: 최다 슬로프 & 라이딩 거리 & 평균 경사도 & 최고 속도
  Widget _buildMiniCardType0Content(DailyRidingCard card) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 오늘 총 라이딩 & 최다 슬로프 (2열)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 오늘 총 라이딩
            Expanded(
              child: Column(
                children: [
                  Text(
                    (card.totalSlopeCount ?? 0) == 0 ? '-' : '${card.totalSlopeCount}',
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 8,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    '총 라이딩',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 2,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // 최다 슬로프
            Expanded(
              child: Column(
                children: [
                  Text(
                    card.mostRiddenSlope?.isNotEmpty == true
                        ? card.mostRiddenSlope!
                        : '-',
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 5,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if ((card.mostRiddenCount ?? 0) > 0)
                    Text(
                      '${card.mostRiddenCount}회',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 2,
                        color: Colors.white,
                      ),
                    ),
                  Text(
                    '최다 슬로프',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 2,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        // 라이딩 거리 & 평균 경사도 & 최고 속도 (3열)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 라이딩 거리
            Expanded(
              child: Column(
                children: [
                  Text(
                    (card.totalDistance ?? 0) == 0 ? '-' : (card.totalDistance ?? 0).toStringAsFixed(0),
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 4,
                      color: Colors.white,
                    ),
                  ),
                  if ((card.totalDistance ?? 0) != 0)
                    Text(
                      'km',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 2,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            // 평균 경사도
            Expanded(
              child: Column(
                children: [
                  Text(
                    (card.avgSlope ?? 0) == 0 ? '-' : (card.avgSlope ?? 0).toStringAsFixed(1),
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 4,
                      color: Colors.white,
                    ),
                  ),
                  if ((card.avgSlope ?? 0) != 0)
                    Text(
                      '°',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 2,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            // 최고 속도
            Expanded(
              child: Column(
                children: [
                  Text(
                    (card.topSpeed ?? 0) == 0 ? '-' : (card.topSpeed ?? 0).toStringAsFixed(0),
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 4,
                      color: Colors.white,
                    ),
                  ),
                  if ((card.topSpeed ?? 0) != 0)
                    Text(
                      'km/h',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 2,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 미니 카드용 카드 타입 1 컨텐츠: 첫 슬로프 이름
  Widget _buildMiniCardType1Content(DailyRidingCard card) {
    final slopeEntries = card.slopeCountsByName?.entries.toList() ?? [];
    final firstSlope = slopeEntries.isNotEmpty ? slopeEntries.first : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 오늘 총 라이딩 수
        Text(
          '${card.totalSlopeCount ?? 0}',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 10,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 3,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 2),
        // 첫 슬로프 이름
        Text(
          firstSlope?.key ?? '-',
          style: SDSTextStyle.bold.copyWith(
            fontSize: 5,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        // 라이딩 슬로프 라벨
        Text(
          '라이딩 슬로프',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 3,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  // 그리드용 카드 타입 0 컨텐츠: 최다 슬로프 & 라이딩 거리 & 평균 경사도 & 최고 속도
  Widget _buildGridCardType0Content(DailyRidingCard card) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 오늘 총 라이딩 & 최다 슬로프 (2열)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 오늘 총 라이딩
              Expanded(
                child: Column(
                  children: [
                    Text(
                      (card.totalSlopeCount ?? 0) == 0 ? '-' : '${card.totalSlopeCount}',
                      style: SDSTextStyle.extraBold.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      '총 라이딩',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // 최다 슬로프
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            card.mostRiddenSlope?.isNotEmpty == true
                                ? card.mostRiddenSlope!
                                : '-',
                            style: SDSTextStyle.extraBold.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          if ((card.mostRiddenCount ?? 0) > 0)
                            Padding(
                              padding: EdgeInsets.only(left: 1, top: 5),
                              child: Text(
                                '${card.mostRiddenCount}회',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '최다 슬로프',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 5,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        // 라이딩 거리 & 평균 경사도 & 최고 속도 (3열)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 라이딩 거리
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          (card.totalDistance ?? 0) == 0 ? '-' : (card.totalDistance ?? 0).toStringAsFixed(0),
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                        if ((card.totalDistance ?? 0) != 0)
                          Padding(
                            padding: EdgeInsets.only(left: 1, top: 3),
                            child: Text(
                              'km',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    Text(
                      '거리',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // 평균 경사도
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (card.avgSlope ?? 0) == 0 ? '-' : (card.avgSlope ?? 0).toStringAsFixed(1),
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                        if ((card.avgSlope ?? 0) != 0)
                          Padding(
                            padding: EdgeInsets.only(left: 1, top: 2),
                            child: Text(
                              '°',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '경사도',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // 최고 속도
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          (card.topSpeed ?? 0) == 0 ? '-' : (card.topSpeed ?? 0).toStringAsFixed(0),
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                        if ((card.topSpeed ?? 0) != 0)
                          Padding(
                            padding: EdgeInsets.only(left: 1, top: 3),
                            child: Text(
                              'km/h',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    Text(
                      '최고속도',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 그리드용 카드 타입 1 컨텐츠: 슬로프 리스트
  Widget _buildGridCardType1Content(DailyRidingCard card) {
    final slopeEntries = card.slopeCountsByName?.entries.toList() ?? [];
    final firstSlope = slopeEntries.isNotEmpty ? slopeEntries.first : null;
    final restSlopes = slopeEntries.length > 1 ? slopeEntries.sublist(1) : <MapEntry<String, int>>[];

    // 그리드에서는 최대 2개의 나머지 슬로프만 표시
    final displaySlopes = restSlopes.take(2).toList();
    final remainingCount = restSlopes.length - displaySlopes.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 오늘 총 라이딩 숫자
        Text(
          '${card.totalSlopeCount ?? 0}',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 14,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        SizedBox(height: 1),
        // 오늘 총 라이딩 라벨
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 5,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 6),
        // 첫 번째 슬로프 이름 (큰 글씨)
        Text(
          firstSlope?.key ?? '-',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 10,
            color: Colors.white,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // 나머지 슬로프들
        if (displaySlopes.isNotEmpty) ...[
          SizedBox(height: 2),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 1,
            children: [
              ...displaySlopes.map((entry) {
                return Text(
                  entry.key,
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 5,
                    color: Colors.white,
                  ),
                );
              }),
              if (remainingCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '+$remainingCount',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 5,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ],
        // 라이딩 슬로프 라벨
        SizedBox(height: 2),
        Text(
          '라이딩 슬로프',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 5,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  void _showSeasonCardDetail() {
    final seasonCard = _ridingCardViewModel.seasonRidingCard.value;
    if (seasonCard == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) {
        return SeasonCardDetailDialog(
          seasonCard: seasonCard,
          userViewModel: _userViewModel,
          ridingCardViewModel: _ridingCardViewModel,
        );
      },
    );
  }

  void _showDailyCardDetail(DailyRidingCard card) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) {
        return DailyCardDetailDialog(
          card: card,
          userViewModel: _userViewModel,
          ridingCardViewModel: _ridingCardViewModel,
        );
      },
    );
  }
}

/// 데일리 카드 상세 다이얼로그 (저장/공유 기능 포함) - LiveOffSummaryDialog와 동일한 구조
class DailyCardDetailDialog extends StatefulWidget {
  final DailyRidingCard card;
  final UserViewModel userViewModel;
  final RidingCardViewModel ridingCardViewModel;

  const DailyCardDetailDialog({
    Key? key,
    required this.card,
    required this.userViewModel,
    required this.ridingCardViewModel,
  }) : super(key: key);

  @override
  State<DailyCardDetailDialog> createState() => _DailyCardDetailDialogState();
}

class _DailyCardDetailDialogState extends State<DailyCardDetailDialog> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSaving = false;
  bool _isSaved = false;
  bool _isSharing = false;
  late int _cardType; // 0: 기본 카드, 1: 슬로프 리스트 카드

  @override
  void initState() {
    super.initState();
    // 저장된 카드 타입 불러오기
    _cardType = widget.ridingCardViewModel.getCardType(widget.card.cardId ?? 0);
  }

  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      bool hasAccess = await Gal.hasAccess(toAlbum: true);

      if (!hasAccess) {
        hasAccess = await Gal.requestAccess(toAlbum: true);

        if (!hasAccess) {
          _showPermissionSettingsDialog();
          setState(() {
            _isSaving = false;
          });
          return;
        }
      }

      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Get.snackbar('오류', '이미지 생성에 실패했습니다.');
        setState(() {
          _isSaving = false;
        });
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final fileName = 'snowlive_daily_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      await Gal.putImage(tempFile.path, album: 'Snowlive');
      await tempFile.delete();

      setState(() {
        _isSaved = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isSaved = false;
          });
        }
      });
    } catch (e) {
      debugPrint('이미지 저장 오류: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _shareImage() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Get.snackbar('오류', '이미지 생성에 실패했습니다.');
        if (mounted) {
          setState(() {
            _isSharing = false;
          });
        }
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final fileName = 'snowlive_daily_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      Share.shareXFiles(
        [XFile(tempFile.path)],
        text: '스노우라이브에서 ${widget.userViewModel.user.display_name}님의 라이딩 기록을 공유합니다!',
      );
    } catch (e) {
      debugPrint('이미지 공유 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  void _showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: SDSColor.snowliveWhite,
        contentPadding: const EdgeInsets.only(bottom: 28, left: 28, right: 28, top: 30),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '사진 접근 권한 필요',
              style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '이미지를 저장하려면 사진 접근 권한이\n필요합니다. 설정에서 권한을 허용해주세요.',
              style: SDSTextStyle.regular.copyWith(fontSize: 14, height: 1.4, color: SDSColor.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.gray200,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '설정으로 이동',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // 카드 타입 0: 오늘 총 라이딩 (기본 디자인)
  Widget _buildCardType0Content(DailyRidingCard card) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 오늘 총 라이딩 & 최다 슬로프 (2열)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 오늘 총 라이딩
              Expanded(
                child: Column(
                  children: [
                    Text(
                      (card.totalSlopeCount ?? 0) == 0 ? '-' : '${card.totalSlopeCount}',
                      style: SDSTextStyle.extraBold.copyWith(
                        fontSize: 30,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '오늘 총 라이딩',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // 최다 슬로프
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          card.mostRiddenSlope?.isNotEmpty == true
                              ? card.mostRiddenSlope!
                              : '-',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        if ((card.mostRiddenCount ?? 0) > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${card.mostRiddenCount}회',
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '최다 슬로프',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 라이딩 거리 & 평균 경사도 & 최고 속도
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 라이딩 거리
            Expanded(
              child: Column(
                children: [
                  (card.totalDistance ?? 0) == 0
                      ? Text(
                          '-',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              (card.totalDistance ?? 0).toStringAsFixed(0),
                              style: SDSTextStyle.extraBold.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'km',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 2),
                  Text(
                    '라이딩 거리',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // 평균 경사도
            Expanded(
              child: Column(
                children: [
                  (card.avgSlope ?? 0) == 0
                      ? Text(
                          '-',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              (card.avgSlope ?? 0).toStringAsFixed(1),
                              style: SDSTextStyle.extraBold.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '°',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 2),
                  Text(
                    '평균 경사도',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // 최고 속도
            Expanded(
              child: Column(
                children: [
                  (card.topSpeed ?? 0) == 0
                      ? Text(
                          '-',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              (card.topSpeed ?? 0).toStringAsFixed(0),
                              style: SDSTextStyle.extraBold.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'km/h',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 2),
                  Text(
                    '최고 속도',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 텍스트 너비 계산
  double _getTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  // 2줄에 맞는 슬로프 개수 계산 (+N 포함 고려)
  int _getSlopeCountForTwoLines(List<MapEntry<String, int>> slopes, double maxWidth, TextStyle style, double spacing) {
    double currentLineWidth = 0;
    int lineCount = 1;
    int count = 0;

    for (int i = 0; i < slopes.length; i++) {
      final textWidth = _getTextWidth(slopes[i].key, style);

      if (currentLineWidth + textWidth > maxWidth) {
        lineCount++;
        if (lineCount > 2) {
          final plusNWidth = _getTextWidth('+${slopes.length - count}', style);
          while (count > 0) {
            double lastLineWidth = 0;
            int tempLineCount = 1;
            for (int j = 0; j < count; j++) {
              final w = _getTextWidth(slopes[j].key, style);
              if (lastLineWidth + w > maxWidth) {
                tempLineCount++;
                lastLineWidth = w + spacing;
              } else {
                lastLineWidth += w + spacing;
              }
            }
            if (tempLineCount <= 2 && lastLineWidth + plusNWidth <= maxWidth) {
              break;
            }
            if (tempLineCount < 2) {
              break;
            }
            count--;
          }
          return count;
        }
        currentLineWidth = textWidth + spacing;
      } else {
        currentLineWidth += textWidth + spacing;
      }
      count++;
    }

    return slopes.length;
  }

  // 카드 타입 1: 라이딩 슬로프 리스트
  Widget _buildCardType1Content(DailyRidingCard card) {
    final slopeEntries = card.slopeCountsByName?.entries.toList() ?? [];
    final firstSlope = slopeEntries.isNotEmpty ? slopeEntries.first : null;
    final restSlopes = slopeEntries.length > 1 ? slopeEntries.sublist(1) : <MapEntry<String, int>>[];

    // 사용 가능한 너비 (카드 너비 320 - 좌우 패딩 24*2)
    const double availableWidth = 320 - 48;
    const double spacing = 8;
    final textStyle = SDSTextStyle.bold.copyWith(fontSize: 14, color: Colors.white);

    // 2줄에 맞는 슬로프 개수 계산
    final displayCount = _getSlopeCountForTwoLines(restSlopes, availableWidth, textStyle, spacing);
    final displaySlopes = restSlopes.take(displayCount).toList();
    final remainingCount = restSlopes.length - displayCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 오늘 총 라이딩 숫자
        Text(
          '${card.totalSlopeCount ?? 0}',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 40,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        // 오늘 총 라이딩 라벨
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 24),
        // 첫 번째 슬로프 이름 (큰 글씨)
        Text(
          firstSlope?.key ?? '-',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 24,
            color: Colors.white,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        // 나머지 슬로프들 (작은 텍스트, 최대 2줄)
        if (displaySlopes.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing,
            runSpacing: 2,
            children: [
              ...displaySlopes.map((entry) {
                return Text(
                  entry.key,
                  style: textStyle,
                );
              }),
              if (remainingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+$remainingCount',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        // 라이딩 슬로프 라벨
        Text(
          '라이딩 슬로프',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final user = widget.userViewModel.user;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Spacer(),
          // 캡처 영역
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: SizedBox(
              width: 320,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 960 / 1524,
                  child: Stack(
                    children: [
                      // 배경 이미지
                      Positioned.fill(
                        child: Image.asset(
                          _cardType == 0
                              ? 'assets/imgs/imgs/img_summury_bg.png'
                              : 'assets/imgs/imgs/img_summury_bg_2.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // 상단: 프로필 이미지, 닉네임, 날짜
                      Positioned(
                        top: 40,
                        left: 32,
                        right: 32,
                        child: Column(
                          children: [
                            // 프로필 이미지
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: (user.profile_image_url_user?.isNotEmpty ?? false)
                                    ? ExtendedImage.network(
                                        user.profile_image_url_user!,
                                        fit: BoxFit.cover,
                                        cache: true,
                                        loadStateChanged: (state) {
                                          if (state.extendedImageLoadState == LoadState.failed) {
                                            return Image.asset(
                                              'assets/imgs/profile/img_profile_default_circle.png',
                                              fit: BoxFit.cover,
                                            );
                                          }
                                          return null;
                                        },
                                      )
                                    : Image.asset(
                                        'assets/imgs/profile/img_profile_default_circle.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // 닉네임
                            Text(
                              user.display_name ?? '',
                              style: SDSTextStyle.bold.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            // 날짜
                            Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: Text(
                                '${card.date ?? ''} ${card.weekday ?? ''}',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // 라이더 타이틀
                            if (card.riderTitle != null && card.riderTitle!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _cardType == 0
                                      ? const Color(0xFF1B3A5C)
                                      : const Color(0xFFE2EDF8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  card.riderTitle!,
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 13,
                                    color: _cardType == 0
                                        ? Colors.white
                                        : const Color(0xFF000000),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // 중앙: 라이딩 정보
                      Positioned(
                        top: 236,
                        bottom: 80,
                        left: 24,
                        right: 24,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: _cardType == 0
                                ? _buildCardType0Content(card)
                                : _buildCardType1Content(card),
                          ),
                        ),
                      ),
                      // 하단: 스노우라이브 로고
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            'assets/imgs/logos/snowliveLogo_main_white.png',
                            height: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 닫기 버튼 + 카드 변경 버튼
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // X 버튼 (닫기)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.back(),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close,
                        size: 26,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 카드 변경 버튼
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _cardType = _cardType == 0 ? 1 : 0;
                      // ViewModel에 카드 타입 저장
                      widget.ridingCardViewModel.setCardType(
                        widget.card.cardId ?? 0,
                        _cardType,
                      );
                    });
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/imgs/icons/icon_summury_change.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 공유 + 이미지 저장 버튼 (하단 고정)
          Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 공유 버튼
                GestureDetector(
                  onTap: _isSharing ? null : _shareImage,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/imgs/icons/icon_summury_share.svg',
                        width: 26,
                        height: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 이미지 저장 버튼
                GestureDetector(
                  onTap: (_isSaving || _isSaved) ? null : _saveImage,
                  child: Container(
                    width: 160,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isSaved ? const Color(0xFF34C759) : SDSColor.snowliveBlue,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: _isSaving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : _isSaved
                              ? Icon(
                                  Icons.check,
                                  size: 28,
                                  color: Colors.white,
                                )
                              : Text(
                                  '이미지 저장',
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 시즌 카드 상세 다이얼로그 (저장/공유 기능 포함, 카드 교체 버튼 없음)
class SeasonCardDetailDialog extends StatefulWidget {
  final SeasonRidingCard seasonCard;
  final UserViewModel userViewModel;
  final RidingCardViewModel ridingCardViewModel;

  const SeasonCardDetailDialog({
    Key? key,
    required this.seasonCard,
    required this.userViewModel,
    required this.ridingCardViewModel,
  }) : super(key: key);

  @override
  State<SeasonCardDetailDialog> createState() => _SeasonCardDetailDialogState();
}

class _SeasonCardDetailDialogState extends State<SeasonCardDetailDialog> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSaving = false;
  bool _isSaved = false;
  bool _isSharing = false;

  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      bool hasAccess = await Gal.hasAccess(toAlbum: true);

      if (!hasAccess) {
        hasAccess = await Gal.requestAccess(toAlbum: true);

        if (!hasAccess) {
          _showPermissionSettingsDialog();
          setState(() {
            _isSaving = false;
          });
          return;
        }
      }

      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Get.snackbar('오류', '이미지 생성에 실패했습니다.');
        setState(() {
          _isSaving = false;
        });
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final fileName = 'snowlive_season_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      await Gal.putImage(tempFile.path, album: 'Snowlive');
      await tempFile.delete();

      setState(() {
        _isSaved = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isSaved = false;
          });
        }
      });
    } catch (e) {
      debugPrint('시즌 카드 이미지 저장 오류: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _shareImage() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Get.snackbar('오류', '이미지 생성에 실패했습니다.');
        if (mounted) {
          setState(() {
            _isSharing = false;
          });
        }
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final fileName = 'snowlive_season_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      Share.shareXFiles(
        [XFile(tempFile.path)],
        text: '스노우라이브에서 ${widget.userViewModel.user.display_name}님의 시즌 기록을 공유합니다!',
      );
    } catch (e) {
      debugPrint('시즌 카드 이미지 공유 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  void _showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: SDSColor.snowliveWhite,
        contentPadding: const EdgeInsets.only(bottom: 28, left: 28, right: 28, top: 30),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '사진 접근 권한 필요',
              style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '이미지를 저장하려면 사진 접근 권한이\n필요합니다. 설정에서 권한을 허용해주세요.',
              style: SDSTextStyle.regular.copyWith(fontSize: 14, height: 1.4, color: SDSColor.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.gray200,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '설정으로 이동',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final seasonCard = widget.seasonCard;
    final user = widget.userViewModel.user;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Spacer(),
          // 캡처 영역
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: SizedBox(
              width: 320,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 960 / 1524,
                  child: Stack(
                    children: [
                      // 배경 이미지
                      Positioned.fill(
                        child: Image.asset(
                          'assets/imgs/imgs/img_summury_bg_3.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // 상단: 프로필 이미지, 닉네임, 시즌
                      Positioned(
                        top: 40,
                        left: 32,
                        right: 32,
                        child: Column(
                          children: [
                            // 프로필 이미지
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: (user.profile_image_url_user?.isNotEmpty ?? false)
                                    ? ExtendedImage.network(
                                        user.profile_image_url_user!,
                                        fit: BoxFit.cover,
                                        cache: true,
                                        loadStateChanged: (state) {
                                          if (state.extendedImageLoadState == LoadState.failed) {
                                            return Image.asset(
                                              'assets/imgs/profile/img_profile_default_circle.png',
                                              fit: BoxFit.cover,
                                            );
                                          }
                                          return null;
                                        },
                                      )
                                    : Image.asset(
                                        'assets/imgs/profile/img_profile_default_circle.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // 닉네임
                            Text(
                              user.display_name ?? '',
                              style: SDSTextStyle.bold.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            // 시즌
                            Text(
                              widget.ridingCardViewModel.selectedSeason.value,
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 중앙: 라이딩 정보
                      Positioned(
                        top: 200,
                        bottom: 80,
                        left: 24,
                        right: 24,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 총 라이딩 숫자
                              Text(
                                (seasonCard.totalSlopeCount ?? 0) == 0 ? '-' : '${seasonCard.totalSlopeCount}',
                                style: SDSTextStyle.extraBold.copyWith(
                                  fontSize: 40,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // 시즌 총 라이딩 라벨
                              Text(
                                '시즌 총 라이딩',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // 총 거리 & 평균 경사도 & 최고 속도
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 총 거리
                                  Expanded(
                                    child: Column(
                                      children: [
                                        (seasonCard.totalDistance ?? 0) == 0
                                            ? Text(
                                                '-',
                                                style: SDSTextStyle.extraBold.copyWith(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                                textBaseline: TextBaseline.alphabetic,
                                                children: [
                                                  Text(
                                                    (seasonCard.totalDistance ?? 0).toStringAsFixed(0),
                                                    style: SDSTextStyle.extraBold.copyWith(
                                                      fontSize: 22,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    'km',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '총 거리',
                                          style: SDSTextStyle.regular.copyWith(
                                            fontSize: 12,
                                            color: Colors.white.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 평균 경사도
                                  Expanded(
                                    child: Column(
                                      children: [
                                        (seasonCard.avgSlope ?? 0) == 0
                                            ? Text(
                                                '-',
                                                style: SDSTextStyle.extraBold.copyWith(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                                textBaseline: TextBaseline.alphabetic,
                                                children: [
                                                  Text(
                                                    (seasonCard.avgSlope ?? 0).toStringAsFixed(1),
                                                    style: SDSTextStyle.extraBold.copyWith(
                                                      fontSize: 22,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    '°',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '평균 경사도',
                                          style: SDSTextStyle.regular.copyWith(
                                            fontSize: 12,
                                            color: Colors.white.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 최고 속도
                                  Expanded(
                                    child: Column(
                                      children: [
                                        (seasonCard.topSpeed ?? 0) == 0
                                            ? Text(
                                                '-',
                                                style: SDSTextStyle.extraBold.copyWith(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                                textBaseline: TextBaseline.alphabetic,
                                                children: [
                                                  Text(
                                                    (seasonCard.topSpeed ?? 0).toStringAsFixed(0),
                                                    style: SDSTextStyle.extraBold.copyWith(
                                                      fontSize: 22,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    'km/h',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '최고 속도',
                                          style: SDSTextStyle.regular.copyWith(
                                            fontSize: 12,
                                            color: Colors.white.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 하단: 스노우라이브 로고
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            'assets/imgs/logos/snowliveLogo_main_white.png',
                            height: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 닫기 버튼 (카드 변경 버튼 없음)
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.back(),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    size: 26,
                    color: SDSColor.gray900,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // 공유 + 이미지 저장 버튼 (하단 고정)
          Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 공유 버튼
                GestureDetector(
                  onTap: _isSharing ? null : _shareImage,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/imgs/icons/icon_summury_share.svg',
                        width: 26,
                        height: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 이미지 저장 버튼
                GestureDetector(
                  onTap: (_isSaving || _isSaved) ? null : _saveImage,
                  child: Container(
                    width: 160,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isSaved ? const Color(0xFF34C759) : SDSColor.snowliveBlue,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: _isSaving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : _isSaved
                              ? Icon(
                                  Icons.check,
                                  size: 28,
                                  color: Colors.white,
                                )
                              : Text(
                                  '이미지 저장',
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

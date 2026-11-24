import 'dart:math';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 눈송이 상점 애셋 경로(앱과 동일한 애셋을 그대로 사용).
String snowAsset(String name) => 'assets/imgs/imgs/snowballShop/$name';

const String kWhiteBall = 'icon_snowballshop_whiteball.png';
const String kGoldBall = 'icon_snowballshop_goldball.png';

/// 앱 상점은 세로(폰) 레이아웃이라, 웹에서도 동일한 세로 화면을 가운데에 띄운다.
const double kSnowballPhoneWidth = 480;

/// 눈송이 상점 공용 스캐폴드.
///
/// 상/하 그라데이션(#1D242E→#030C19) 배경 위에, 폰 폭([kSnowballPhoneWidth])으로
/// 제한된 세로 화면을 가운데 띄운다. [appBarColor]를 주면 상단 바 배경을 그 색으로
/// (상점별 테마색) 칠한다. [actions]로 잔량 pill 등을 우측에 붙일 수 있다.
class SnowballPhoneScaffold extends StatelessWidget {
  const SnowballPhoneScaffold({
    super.key,
    required this.child,
    this.title,
    this.appBarColor,
    this.scaffoldGradient,
    this.backgroundColor,
    this.actions,
    this.bottomBar,
    this.showBack = true,
  });

  final Widget child;
  final String? title;
  final Color? appBarColor;
  final Gradient? scaffoldGradient;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final gradient = scaffoldGradient ??
        const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1D242E), Color(0xFF030C19)],
        );

    return Container(
      decoration: BoxDecoration(
        gradient: backgroundColor == null ? gradient : null,
        color: backgroundColor,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kSnowballPhoneWidth),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: AppBar(
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                backgroundColor: appBarColor ?? Colors.transparent,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: showBack
                    ? IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new,
                            size: 20, color: Colors.white),
                        splashRadius: 20,
                      )
                    : null,
                title: title == null
                    ? null
                    : Text(title!,
                        style: SDSTextStyle.bold
                            .copyWith(color: Colors.white, fontSize: 16)),
                actions: actions,
              ),
            ),
            body: child,
            bottomNavigationBar: bottomBar,
          ),
        ),
      ),
    );
  }
}

/// 하얀/황금 눈송이 잔량 pill (홈 상단·상점 앱바 공용).
class SnowballBalancePills extends StatelessWidget {
  const SnowballBalancePills({
    super.key,
    required this.white,
    required this.gold,
    this.compact = false,
  });

  final int white;
  final int gold;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(snowAsset(kWhiteBall), height: 16),
          const SizedBox(width: 4),
          Text('$white',
              style: SDSTextStyle.regular
                  .copyWith(color: Colors.white, fontSize: 13)),
          const SizedBox(width: 8),
          Image.asset(snowAsset(kGoldBall), height: 16),
          const SizedBox(width: 4),
          Text('$gold',
              style: SDSTextStyle.regular
                  .copyWith(color: Colors.white, fontSize: 13)),
        ]),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pill(kWhiteBall, '하얀 눈송이', white),
        const SizedBox(width: 5),
        _pill(kGoldBall, '황금 눈송이', gold),
      ],
    );
  }

  Widget _pill(String icon, String label, int count) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Image.asset(snowAsset(icon), height: 16),
        const SizedBox(width: 4),
        Text(label,
            style: SDSTextStyle.regular
                .copyWith(color: Colors.white.withOpacity(0.7), fontSize: 13)),
        const SizedBox(width: 6),
        Text('$count',
            style: SDSTextStyle.regular.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
    );
  }
}

String snowballRandomString(int length) {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random.secure();
  return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
}

/// 눈송이 Pay QR(결제용). 데이터 포맷은 앱과 동일: `random#userId#eventDate`.
Future<void> showSnowballPayQrDialog(
  BuildContext context, {
  required int userId,
  required int eventDate,
}) {
  final data = '${snowballRandomString(12)}#$userId#$eventDate';
  return _showQrDialog(
    context,
    qrData: data,
    borderColor: const Color(0xFF073819),
    title: '눈송이 Pay QR 결제',
    desc: '경품 수령처에서 QR 코드를 스캔하고\n현장 이벤트에 참여해 보세요!',
  );
}

/// 상품 교환 QR(구매 기록용). 데이터는 recordId.
Future<void> showSnowballItemQrDialog(
  BuildContext context, {
  required String qrData,
  Widget? footer,
}) {
  return _showQrDialog(
    context,
    qrData: qrData,
    borderColor: const Color(0xFF073819),
    title: '상품 교환 QR',
    desc: '경품 수령처에서 QR 코드를 스캔하고\n경품을 수령해 주세요!',
    footer: footer,
  );
}

Future<void> _showQrDialog(
  BuildContext context, {
  required String qrData,
  required Color borderColor,
  required String title,
  required String desc,
  Widget? footer,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (ctx) {
      return Dialog(
        backgroundColor: const Color(0xFF3D83ED),
        insetPadding: const EdgeInsets.all(24),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: borderColor, width: 6)),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(desc,
                  style: TextStyle(
                      fontSize: 13, color: Colors.white.withOpacity(0.6)),
                  textAlign: TextAlign.center),
              if (footer != null) ...[const SizedBox(height: 24), footer],
            ],
          ),
        ),
      );
    },
  );
}

/// 공용 안내/결과 팝업(교환 완료·부족·실패·응모 완료 등).
Future<void> showSnowballInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonText = '확인',
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(title,
            textAlign: TextAlign.center,
            style:
                SDSTextStyle.bold.copyWith(color: SDSColor.gray900, fontSize: 16)),
        const SizedBox(height: 8),
        Text(message,
            textAlign: TextAlign.center,
            style: SDSTextStyle.regular
                .copyWith(color: SDSColor.gray500, fontSize: 14, height: 1.4)),
      ]),
      actionsPadding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF3D83ED),
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    ),
  );
}

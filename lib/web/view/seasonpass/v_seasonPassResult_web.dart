import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/toss_payment.dart';
import 'package:com.snowlive/web/viewmodel/seasonpass/vm_seasonPass_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 토스 결제 성공 리다이렉트 → 서버 승인 확정.
class SeasonPassSuccessViewWeb extends StatefulWidget {
  const SeasonPassSuccessViewWeb({super.key});

  @override
  State<SeasonPassSuccessViewWeb> createState() => _SeasonPassSuccessViewWebState();
}

class _SeasonPassSuccessViewWebState extends State<SeasonPassSuccessViewWeb> {
  bool _loading = true;
  bool _ok = false;

  @override
  void initState() {
    super.initState();
    _confirm();
  }

  Future<void> _confirm() async {
    final vm = Get.isRegistered<SeasonPassViewModelWeb>()
        ? Get.find<SeasonPassViewModelWeb>()
        : Get.put(SeasonPassViewModelWeb());
    final ok = await vm.confirmFromRedirect();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _ok = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ResultScaffold(
      child: _loading
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          : _ResultBody(
              title: _ok ? '결제가 완료되었습니다' : '결제 승인에 실패했습니다',
              desc: _ok
                  ? '시즌권이 활성화되었습니다. 이제 유료 기능을 이용할 수 있어요.'
                  : '결제가 정상적으로 확정되지 않았습니다. 시즌권 화면에서 다시 시도하거나 고객센터로 문의해주세요.',
              accent: _ok ? SDSColor.snowliveBlue : SDSColor.red,
            ),
    );
  }
}

/// 토스 결제 실패/취소 리다이렉트.
class SeasonPassFailViewWeb extends StatelessWidget {
  const SeasonPassFailViewWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final p = readTossFailParams();
    final msg = p['message'];
    return _ResultScaffold(
      child: _ResultBody(
        title: '결제가 완료되지 않았습니다',
        desc: (msg != null && msg.isNotEmpty)
            ? msg
            : '결제가 취소되었거나 승인되지 않았습니다. 시즌권 화면에서 다시 시도해주세요.',
        accent: SDSColor.red,
      ),
    );
  }
}

class _ResultScaffold extends StatelessWidget {
  final Widget child;
  const _ResultScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  final String title;
  final String desc;
  final Color accent;
  const _ResultBody(
      {required this.title, required this.desc, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title,
            style: SDSTextStyle.extraBold.copyWith(fontSize: 20, color: accent)),
        const SizedBox(height: SDSSpacing.md),
        Text(desc,
            style:
                SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray700)),
        const SizedBox(height: SDSSpacing.xl),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () => Get.offAllNamed(WebRoutes.seasonPass),
            style: ElevatedButton.styleFrom(
              backgroundColor: SDSColor.snowliveBlue,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('시즌권으로 돌아가기',
                style: SDSTextStyle.bold
                    .copyWith(fontSize: 15, color: SDSColor.snowliveWhite)),
          ),
        ),
      ],
    );
  }
}

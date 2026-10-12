import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/seasonpass/vm_seasonPass_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 시즌권 페이지 — 혜택 소개 / 구매 / 구매내역 / 환불 / 해금 혜택 바로가기.
/// 기존 웹 디자인 시스템(SDSColor/SDSTextStyle) 그대로, 이모지 없음.
class SeasonPassHomeViewWeb extends StatelessWidget {
  const SeasonPassHomeViewWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<SeasonPassViewModelWeb>();
    return Container(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('시즌권',
                    style: SDSTextStyle.extraBold
                        .copyWith(fontSize: 24, color: SDSColor.gray900)),
                const SizedBox(height: SDSSpacing.lg),
                Obx(() {
                  if (vm.isLoading.value && vm.season.value == null) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _benefitsCard(),
                      const SizedBox(height: SDSSpacing.md),
                      _statusOrPurchaseCard(context, vm),
                      const SizedBox(height: SDSSpacing.md),
                      _shortcutsCard(vm),
                      const SizedBox(height: SDSSpacing.md),
                      _historyCard(context, vm),
                      const SizedBox(height: SDSSpacing.md),
                      _messageBox(vm),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SDSColor.snowliveWhite,
          border: Border.all(color: SDSColor.gray200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );

  Widget _sectionTitle(String t) =>
      Text(t, style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900));

  Widget _benefitsCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('시즌권 혜택'),
            const SizedBox(height: SDSSpacing.md),
            _benefitRow('라이딩 궤적 · 애니메이션 · 상세 데이터',
                '내 라이딩 경로와 속도·고도·경사 데이터를 보고 이미지·영상으로 저장'),
            const SizedBox(height: SDSSpacing.sm),
            _benefitRow('친구 실시간 위치 공유',
                '서로 수락한 친구끼리 슬로프 지도 위에서 실시간 위치 확인'),
          ],
        ),
      );

  Widget _benefitRow(String title, String desc) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
          const SizedBox(height: 2),
          Text(desc,
              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray600)),
        ],
      );

  Widget _statusOrPurchaseCard(BuildContext context, SeasonPassViewModelWeb vm) {
    return Obx(() {
      if (vm.isPaid.value) {
        final until = vm.validUntil.value;
        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('이용 중'),
              const SizedBox(height: SDSSpacing.sm),
              Text(
                '${vm.seasonName.value ?? '시즌권'} 이용 중입니다.'
                '${until != null ? '  ($until 까지)' : ''}',
                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray700),
              ),
            ],
          ),
        );
      }
      final priceText = '${vm.price.value}원';
      final until = vm.validUntil.value ?? '시즌 종료일';
      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('구매'),
            const SizedBox(height: SDSSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(priceText,
                    style: SDSTextStyle.extraBold
                        .copyWith(fontSize: 22, color: SDSColor.snowliveBlue)),
                const SizedBox(width: 8),
                Text('/ $until 까지',
                    style:
                        SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500)),
              ],
            ),
            const SizedBox(height: SDSSpacing.md),
            _consentRow(
              value: vm.agreeTerms,
              text:
                  '본 시즌권은 $until까지 이용 가능하며, 결제 시점과 무관하게 종료일은 동일합니다.',
            ),
            const SizedBox(height: SDSSpacing.sm),
            _consentRow(
              value: vm.agreeRefund,
              text: '유료 기능 이용을 시작한 이후에는 환불이 제한됨에 동의합니다.',
            ),
            const SizedBox(height: SDSSpacing.md),
            SizedBox(
              height: 48,
              child: Obx(() => ElevatedButton(
                    onPressed: vm.canPurchase ? () => vm.purchase() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveBlue,
                      disabledBackgroundColor: SDSColor.gray200,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: vm.isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('구매하기',
                            style: SDSTextStyle.bold
                                .copyWith(fontSize: 15, color: SDSColor.snowliveWhite)),
                  )),
            ),
          ],
        ),
      );
    });
  }

  Widget _consentRow({required RxBool value, required String text}) {
    return Obx(() => InkWell(
          onTap: () => value.value = !value.value,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: value.value,
                  onChanged: (v) => value.value = v ?? false,
                  activeColor: SDSColor.snowliveBlue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(text,
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 13, color: SDSColor.gray700)),
              ),
            ],
          ),
        ));
  }

  Widget _shortcutsCard(SeasonPassViewModelWeb vm) => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('혜택 바로가기'),
            const SizedBox(height: SDSSpacing.sm),
            _shortcutRow(vm, '라이딩 궤적 · 상세 데이터', WebRoutes.rideList),
            Divider(height: 1, color: SDSColor.gray100),
            _shortcutRow(vm, '친구 실시간 위치', WebRoutes.liveMap),
          ],
        ),
      );

  Widget _shortcutRow(SeasonPassViewModelWeb vm, String title, String route) {
    return Obx(() {
      final paid = vm.isPaid.value;
      return InkWell(
        onTap: paid ? () => Get.toNamed(route) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(title,
                    style: SDSTextStyle.bold.copyWith(
                        fontSize: 14,
                        color: paid ? SDSColor.gray900 : SDSColor.gray400)),
              ),
              Text(
                paid ? '바로가기' : '프리미엄 전용',
                style: SDSTextStyle.regular.copyWith(
                    fontSize: 12,
                    color: paid ? SDSColor.snowliveBlue : SDSColor.gray400),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _historyCard(BuildContext context, SeasonPassViewModelWeb vm) => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('구매내역'),
            const SizedBox(height: SDSSpacing.sm),
            Obx(() {
              if (vm.history.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('구매내역이 없습니다.',
                      style: SDSTextStyle.regular
                          .copyWith(fontSize: 13, color: SDSColor.gray500)),
                );
              }
              return Column(
                children:
                    vm.history.map((h) => _historyRow(context, vm, h)).toList(),
              );
            }),
          ],
        ),
      );

  Widget _historyRow(
      BuildContext context, SeasonPassViewModelWeb vm, Map<String, dynamic> h) {
    final status = h['status']?.toString();
    final refundable = h['refund_status'] == null && h['refundable'] == true;
    final refundReq = h['refund_request']?.toString();
    String statusText;
    Color statusColor;
    if (status == 'REFUNDED') {
      statusText = '환불 완료';
      statusColor = SDSColor.gray500;
    } else if (refundReq == 'REQUESTED') {
      statusText = '환불 신청 접수';
      statusColor = SDSColor.snowliveBlue;
    } else {
      statusText = '결제 완료';
      statusColor = SDSColor.gray700;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${h['season'] ?? ''} 시즌권  ${h['amount'] ?? ''}원',
                    style: SDSTextStyle.bold
                        .copyWith(fontSize: 14, color: SDSColor.gray900)),
                const SizedBox(height: 2),
                Text(statusText,
                    style:
                        SDSTextStyle.regular.copyWith(fontSize: 12, color: statusColor)),
              ],
            ),
          ),
          if (refundable && refundReq == null)
            TextButton(
              onPressed: () => _confirmRefund(context, vm, h['order_id']?.toString() ?? ''),
              child: Text('환불 신청',
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: 13, color: SDSColor.red)),
            ),
        ],
      ),
    );
  }

  void _confirmRefund(
      BuildContext context, SeasonPassViewModelWeb vm, String orderId) {
    Get.dialog(AlertDialog(
      backgroundColor: SDSColor.snowliveWhite,
      title: Text('환불 신청',
          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
      content: Text(
        '환불을 신청하시겠어요? 신청 접수 후 영업일 기준 3일 이내에 안내드립니다.',
        style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray700),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('취소',
              style: SDSTextStyle.regular.copyWith(color: SDSColor.gray500)),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await vm.requestRefund(orderId);
          },
          child: Text('신청',
              style: SDSTextStyle.bold.copyWith(color: SDSColor.red)),
        ),
      ],
    ));
  }

  Widget _messageBox(SeasonPassViewModelWeb vm) => Obx(() {
        final m = vm.message.value;
        if (m == null || m.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SDSColor.blue50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(m,
              style:
                  SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray700)),
        );
      });
}

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_snowball.dart';
import 'package:com.snowlive/web/view/ranking/w_snowball_web_common.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_snowball_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// 웹 경품 교환 목록 — `#/snowball-market/buy-record`.
/// 구매 기록 리스트 + 상품 교환 QR(수령용). 앱 [SnowballMarketBuyRecordView]와 동일.
class SnowballMarketBuyRecordViewWeb extends StatelessWidget {
  SnowballMarketBuyRecordViewWeb({super.key});

  final SnowballShopViewModelWeb vm = Get.find<SnowballShopViewModelWeb>();

  String _formatDate(String? s) {
    if (s == null || s.isEmpty) return '날짜 정보 없음';
    try {
      return DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(s));
    } catch (_) {
      return '잘못된 날짜 형식';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SDSColor.snowliveWhite,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kSnowballPhoneWidth),
          child: Scaffold(
            backgroundColor: SDSColor.snowliveWhite,
            appBar: AppBar(
              backgroundColor: SDSColor.snowliveWhite,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                splashRadius: 20,
              ),
              title: Text('경품 교환 목록',
                  style: SDSTextStyle.bold.copyWith(color: SDSColor.gray900, fontSize: 16)),
            ),
            body: Obx(() {
              final list = vm.purchaseHistory;
              if (list.isEmpty) {
                return Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset('assets/imgs/icons/icon_nodata.png', width: 73, height: 73),
                    const SizedBox(height: 6),
                    Text('교환한 경품이 없어요',
                        style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray700)),
                  ]),
                );
              }
              return RefreshIndicator(
                onRefresh: () => vm.fetchPurchaseHistory(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _row(context, list[i]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, SnowballBuyRecord record) {
    final received = record.isReceived == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        WebNetworkImage(
          url: record.imageUrl,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          borderRadius: 8,
          fallback: Image.asset('assets/imgs/profile/img_profile_default_circle.png',
              width: 64, height: 64, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(record.itemName ?? '상품 이름',
                style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
            Text(
              '하얀 눈송이 : ${record.price?[0].snowballCount ?? 0}개 / 황금 눈송이 : ${record.price?[1].snowballCount ?? 0}개',
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
            ),
            Text(_formatDate(record.uploadTime),
                style: SDSTextStyle.regular.copyWith(fontSize: 11, color: const Color(0xFF3D83ED))),
          ]),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 32,
          child: ElevatedButton(
            onPressed: () {
              if (received) {
                Get.snackbar('이미 수령한 상품이에요', '새로운 상품을 교환 후 수령해주세요.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black.withOpacity(0.8),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    duration: const Duration(seconds: 1));
              } else {
                _showQr(context, record);
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: received ? const Color(0xFF222222) : const Color(0xFF3D83ED),
              side: BorderSide(color: SDSColor.gray100!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            ),
            child: Text(received ? '수령완료' : '수령하기',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  void _showQr(BuildContext context, SnowballBuyRecord record) {
    final footer = Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        WebNetworkImage(
            url: record.imageUrl, width: 48, height: 48, fit: BoxFit.cover, borderRadius: 4),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(record.itemName ?? '상품 이름',
                style: SDSTextStyle.bold.copyWith(fontSize: 15, color: Colors.white)),
            Text(
              '하얀 눈송이 ${record.price?[0].snowballCount ?? 0}개 / 황금 눈송이 ${record.price?[1].snowballCount ?? 0}개',
              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.5)),
            ),
          ]),
        ),
      ]),
    );
    showSnowballItemQrDialog(context, qrData: record.recordId.toString(), footer: footer);
  }
}

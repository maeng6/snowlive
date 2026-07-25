import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _priceFormat = NumberFormat('###,###,###,###');

/// 상태 배지 + 제목 + 부제(장소·카테고리 · 시간) + 가격(+가격제안가능) + 설명 + 물품명/거래방식.
class FleamarketDetailBodyWeb extends StatelessWidget {
  final FleamarketDetailModel detail;

  const FleamarketDetailBodyWeb({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final time = detail.uploadTime != null ? GetDatetime().getAgoString(detail.uploadTime!) : '';
    final isSoldOut = detail.status == FleamarketStatus.soldOut.korean;
    final isOnBooking = detail.status == FleamarketStatus.onBooking.korean;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSoldOut || isOnBooking) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isSoldOut ? SDSColor.gray900 : SDSColor.snowliveBlue,
            ),
            child: Text(
              detail.status ?? '',
              style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.snowliveWhite),
            ),
          ),
          const SizedBox(height: SDSSpacing.sm),
        ],
        Text(
          detail.title ?? '',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: SDSTextStyle.bold.copyWith(fontSize: 20, color: SDSColor.gray900),
        ),
        const SizedBox(height: SDSSpacing.xs),
        Row(
          children: [
            Text(
              '${detail.spot ?? ''} · ${detail.categoryMain ?? ''}',
              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
            ),
            const Spacer(),
            Text(time, style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500)),
          ],
        ),
        const SizedBox(height: SDSSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${_priceFormat.format(detail.price ?? 0)}원',
              style: SDSTextStyle.bold.copyWith(fontSize: 22, color: SDSColor.gray900),
            ),
            if (detail.negotiable == true) ...[
              const SizedBox(width: SDSSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: SDSColor.gray200),
                ),
                child: Text('가격 제안 가능', style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500)),
              ),
            ],
          ],
        ),
        const SizedBox(height: SDSSpacing.md),
        Divider(color: SDSColor.gray100),
        const SizedBox(height: SDSSpacing.md),
        Text(
          isSoldOut ? '거래가 완료된 물품입니다.' : (detail.description ?? ''),
          style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray700, height: 1.5),
        ),
        const SizedBox(height: SDSSpacing.md),
        Divider(color: SDSColor.gray100),
        const SizedBox(height: SDSSpacing.md),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('물품명', style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
                  const SizedBox(height: SDSSpacing.xs),
                  Text(detail.productName ?? '', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('거래방식', style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
                  const SizedBox(height: SDSSpacing.xs),
                  Text(detail.method ?? '', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

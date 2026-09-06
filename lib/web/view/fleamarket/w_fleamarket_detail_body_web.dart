import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _priceFormat = NumberFormat('###,###,###,###');

/// 제목 + 부제(장소·카테고리 · 시간) + 상태/가격제안 배지 + 가격 + 설명 + 물품명/거래방식.
class FleamarketDetailBodyWeb extends StatelessWidget {
  final FleamarketDetailModel detail;

  const FleamarketDetailBodyWeb({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final time = detail.uploadTime != null ? GetDatetime().getAgoString(detail.uploadTime!) : '';
    final isSoldOut = detail.status == FleamarketStatus.soldOut.korean;
    final isOnBooking = detail.status == FleamarketStatus.onBooking.korean;
    final isNegotiable = detail.negotiable == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.title ?? '',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: SDSTextStyle.bold.copyWith(fontSize: 20, color: SDSColor.gray900),
        ),
        const SizedBox(height: SDSSpacing.xs),
        // 목업: 올린 시간이 오른쪽 끝이 아니라 `장소 · 카테고리` 바로 뒤에 붙는다.
        Row(
          children: [
            Flexible(
              child: Text(
                '${detail.spot ?? ''} · ${detail.categoryMain ?? ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
              ),
            ),
            const SizedBox(width: SDSSpacing.md),
            Text(time, style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500)),
          ],
        ),
        // 목업: 상태·가격제안 배지가 제목 아래·가격 위에 한 줄로 나란히 온다.
        if (isSoldOut || isOnBooking || isNegotiable) ...[
          const SizedBox(height: SDSSpacing.sm),
          Row(
            children: [
              if (isSoldOut || isOnBooking) ...[
                _StatusBadge(
                  label: detail.status ?? '',
                  isFilled: true,
                  color: isSoldOut ? SDSColor.gray900 : SDSColor.snowliveBlue,
                ),
                const SizedBox(width: 6),
              ],
              if (isNegotiable)
                // 채워진 상태 배지와 짝이 되도록 테두리만 파란 배지로 그린다(목업).
                const _StatusBadge(
                  label: '가격 제안 가능',
                  isFilled: false,
                  color: SDSColor.snowliveBlue,
                ),
            ],
          ),
        ],
        const SizedBox(height: SDSSpacing.sm),
        Text(
          '${_priceFormat.format(detail.price ?? 0)}원',
          style: SDSTextStyle.bold.copyWith(fontSize: 22, color: SDSColor.gray900),
        ),
        // 목업에는 가격 아래 구분선이 없다.
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
            Expanded(child: _DetailField(label: '물품명', value: detail.productName ?? '')),
            Expanded(child: _DetailField(label: '거래방식', value: detail.method ?? '')),
          ],
        ),
      ],
    );
  }
}

/// 상태·가격제안 배지. 채운 배지(예약중·판매완료)와 테두리 배지(가격 제안 가능)를 같은
/// 모양·크기로 그린다(목업).
class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isFilled;
  final Color color;

  const _StatusBadge({required this.label, required this.isFilled, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isFilled ? color : SDSColor.snowliveWhite,
        border: isFilled ? null : Border.all(color: color),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(
          fontSize: 13,
          color: isFilled ? SDSColor.snowliveWhite : color,
        ),
      ),
    );
  }
}

/// `물품명` / `거래방식`. 목업의 값은 볼드가 아니다.
class _DetailField extends StatelessWidget {
  final String label;
  final String value;

  const _DetailField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
        const SizedBox(height: SDSSpacing.xs),
        Text(value, style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900)),
      ],
    );
  }
}

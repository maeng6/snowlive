import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

const String kFleamarketDefaultImage = 'assets/imgs/imgs/img_flea_default.png';
final _priceFormat = NumberFormat('###,###,###,###');

/// 중고거래 그리드 카드 1개: 정사각 이미지 + 제목/위치·시간/가격/조회수·댓글수.
class FleamarketCardWeb extends StatelessWidget {
  final Fleamarket data;
  final VoidCallback onTap;

  const FleamarketCardWeb({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final photos = data.photos ?? [];
    final time = data.uploadTime != null ? GetDatetime().getAgoString(data.uploadTime!) : '';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: SDSColor.gray100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: photos.isNotEmpty
                        ? Image.network(
                            photos.first.urlFleaPhoto!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Shimmer.fromColors(
                                baseColor: SDSColor.gray200,
                                highlightColor: SDSColor.gray50,
                                child: Container(color: Colors.white),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(kFleamarketDefaultImage, fit: BoxFit.cover),
                          )
                        : Image.asset(kFleamarketDefaultImage, fit: BoxFit.cover),
                  ),
                ),
                if (data.status == FleamarketStatus.soldOut.korean)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                if (data.status == FleamarketStatus.soldOut.korean || data.status == FleamarketStatus.onBooking.korean)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: data.status == FleamarketStatus.soldOut.korean
                            ? SDSColor.snowliveWhite
                            : SDSColor.snowliveBlue,
                      ),
                      child: Text(
                        data.status ?? '',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 11,
                          color: data.status == FleamarketStatus.soldOut.korean
                              ? SDSColor.snowliveBlack
                              : SDSColor.snowliveWhite,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.title ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
          ),
          const SizedBox(height: 2),
          Text(
            '${data.spot ?? ''} · $time',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
          ),
          const SizedBox(height: 4),
          Text(
            '${_priceFormat.format(data.price ?? 0)}원',
            style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if ((data.viewsCount ?? 0) != 0) ...[
                Image.asset('assets/imgs/icons/icon_list_view.png', width: 14, height: 14),
                const SizedBox(width: 3),
                Text('${data.viewsCount}', style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500)),
              ],
              if ((data.commentCount ?? 0) != 0) ...[
                const SizedBox(width: 8),
                Image.asset('assets/imgs/icons/icon_list_reply.png', width: 14, height: 14),
                const SizedBox(width: 3),
                Text('${data.commentCount}', style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

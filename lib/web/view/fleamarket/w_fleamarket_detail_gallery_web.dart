import 'package:carousel_slider/carousel_slider.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart' show kFleamarketDefaultImage;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_image_viewer_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 상세화면 상단 이미지 캐러셀 + 점 인디케이터.
class FleamarketDetailGalleryWeb extends StatelessWidget {
  final List<Photo> photos;

  const FleamarketDetailGalleryWeb({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    final detailVm = Get.find<FleamarketDetailViewModel>();

    if (photos.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(kFleamarketDefaultImage, fit: BoxFit.cover),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CarouselSlider.builder(
              options: CarouselOptions(
                viewportFraction: 1,
                aspectRatio: 1,
                enableInfiniteScroll: photos.length > 1,
                onPageChanged: (index, _) => detailVm.updateCurrentIndex(index),
              ),
              itemCount: photos.length,
              itemBuilder: (context, index, _) {
                final p = photos[index];
                return GestureDetector(
                  onTap: () => showFleamarketImageViewerWeb(context: context, photos: photos, initialIndex: index),
                  child: Image.network(
                    p.urlFleaPhoto ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Image.asset(kFleamarketDefaultImage, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ),
        if (photos.length > 1) ...[
          const SizedBox(height: SDSSpacing.sm),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < photos.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: detailVm.currentIndex == i ? SDSColor.gray900 : SDSColor.gray200,
                      ),
                    ),
                ],
              )),
        ],
      ],
    );
  }
}

import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_fleamarket.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketSearch.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FleaMarketListView_search extends StatelessWidget {
  FleaMarketListView_search({super.key});

  final f = NumberFormat('###,###,###,###');
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FleamarketSearchViewModel _fleamarketSearchViewModel =
  Get.find<FleamarketSearchViewModel>();
  final FleamarketDetailViewModel _fleamarketDetailViewModel =
  Get.find<FleamarketDetailViewModel>();

  final FocusNode textFocus = FocusNode();

  // ✅ status 기반 완료 판단 (서버 status 값 확정되면 여기만 정리하면 됨)
  bool _isTradeDone(Fleamarket data) {
    final s = (data.status ?? '').trim().toLowerCase();
    return s == 'done' ||
        s == 'sold' ||
        s == 'completed' ||
        s == 'complete' ||
        s == 'soldout' ||
        s == 'sold_out' ||
        s == 'deal_done' ||
        s == 'dealdone' ||
        s == '판매완료' ||
        s == '거래완료';
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        textFocus.unfocus();
        FocusScope.of(context).unfocus();
      },
      child: Obx(
            () => Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: AppBar(
              backgroundColor: SDSColor.snowliveWhite,
              foregroundColor: SDSColor.snowliveWhite,
              surfaceTintColor: SDSColor.snowliveWhite,
              leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26),
            highlightColor: Colors.transparent,
          ),
        ),
              elevation: 0.0,
              titleSpacing: 0,
              centerTitle: true,
              title: Text(
                '상품 검색',
                style: SDSTextStyle.extraBold.copyWith(
                  color: SDSColor.gray900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 검색창 + 상단 텍스트
                Obx(
                      () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Form(
                          key: _fleamarketSearchViewModel.formKey,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 10),
                            child: Stack(
                              children: [
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: TextFormField(
                                    focusNode: textFocus,
                                    autofocus: true,
                                    onFieldSubmitted: (val) async {
                                      if (val.isNotEmpty) {
                                        _fleamarketSearchViewModel
                                            .showRecentSearch.value = false;

                                        await _fleamarketSearchViewModel
                                            .fetchFleamarketData_search(
                                          userId: _userViewModel.user.user_id,
                                          search_query: _fleamarketSearchViewModel
                                              .textEditingController.text,
                                        );

                                        await _fleamarketSearchViewModel
                                            .saveRecentSearch(
                                          _fleamarketSearchViewModel
                                              .textEditingController.text,
                                        );
                                      }
                                    },
                                    textAlignVertical: TextAlignVertical.center,
                                    cursorColor: SDSColor.snowliveBlue,
                                    cursorHeight: 16,
                                    cursorWidth: 2,
                                    style: SDSTextStyle.regular.copyWith(
                                      fontSize: 14,
                                    ),
                                    controller: _fleamarketSearchViewModel
                                        .textEditingController,
                                    decoration: InputDecoration(
                                      errorMaxLines: 1,
                                      errorStyle: SDSTextStyle.regular.copyWith(
                                        fontSize: 0,
                                        color: SDSColor.red,
                                      ),
                                      labelStyle: SDSTextStyle.regular.copyWith(
                                        color: SDSColor.gray400,
                                        fontSize: 14,
                                      ),
                                      hintStyle: SDSTextStyle.regular.copyWith(
                                        color: SDSColor.gray400,
                                        fontSize: 14,
                                      ),
                                      hintText: '상품 검색',
                                      contentPadding: const EdgeInsets.only(
                                        top: 8,
                                        bottom: 8,
                                        left: 36,
                                        right: 12,
                                      ),
                                      fillColor: SDSColor.gray50,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: SDSColor.gray50),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: SDSColor.snowliveBlue,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return '검색어를 입력해주세요.';
                                      }
                                      if (val.length <= 40 && val.length >= 1) {
                                        return null;
                                      }
                                      return '최대 입력 가능한 글자 수를 초과했습니다.';
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Image.asset(
                                      'assets/imgs/icons/icon_search.png',
                                      width: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_fleamarketSearchViewModel.showRecentSearch.value)
                          Row(
                            children: [
                              Text(
                                '최근 검색어',
                                style: SDSTextStyle.bold.copyWith(
                                  fontSize: 14,
                                  color: SDSColor.gray900,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              GestureDetector(
                                onTap: () async {
                                  textFocus.unfocus();
                                  await _fleamarketSearchViewModel
                                      .deleteAllRecentSearches();
                                },
                                child: Text(
                                  '전체삭제',
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 14,
                                    color: SDSColor.gray500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (!_fleamarketSearchViewModel.showRecentSearch.value)
                          Text(
                            '검색 결과',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 14,
                              color: SDSColor.gray900,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 최근 검색어 리스트
                if (!_fleamarketSearchViewModel.isSearching &&
                    _fleamarketSearchViewModel.recentSearches.isNotEmpty &&
                    _fleamarketSearchViewModel.showRecentSearch.value)
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                      _fleamarketSearchViewModel.recentSearches.length,
                      itemBuilder: (context, index) {
                        String recentSearch =
                        _fleamarketSearchViewModel.recentSearches[index];
                        return GestureDetector(
                          onTap: () async {
                            textFocus.unfocus();
                            _fleamarketSearchViewModel.textEditingController
                                .text = recentSearch;
                            _fleamarketSearchViewModel.showRecentSearch.value =
                            false;

                            await _fleamarketSearchViewModel
                                .fetchFleamarketData_search(
                              userId: _userViewModel.user.user_id,
                              search_query: recentSearch,
                            );

                            await _fleamarketSearchViewModel
                                .saveRecentSearch(recentSearch);
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 16, right: 8),
                                child: Image.asset(
                                  'assets/imgs/icons/icon_search.png',
                                  color: SDSColor.gray400,
                                  width: 16,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  recentSearch,
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 16,
                                    color: SDSColor.gray900,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: SDSColor.gray500,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _fleamarketSearchViewModel
                                      .deleteRecentSearch(recentSearch);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 20),

                // 검색 결과 리스트
                Expanded(
                  child: Obx(() {
                    if (_fleamarketSearchViewModel.isLoading == true) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              backgroundColor: SDSColor.gray100,
                              color: SDSColor.gray300.withOpacity(0.6),
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _fleamarketSearchViewModel.scrollController,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount:
                      _fleamarketSearchViewModel.fleamarketListSearch.length +
                          1,
                      itemBuilder: (context, index) {
                        // 검색 결과 없음
                        if (_fleamarketSearchViewModel.fleamarketListSearch.isEmpty &&
                            _fleamarketSearchViewModel.showRecentSearch.value ==
                                false) {
                          return SizedBox(
                            height: _size.height - 400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/imgs/icons/icon_nodata.png',
                                    scale: 4,
                                    width: 73,
                                    height: 73,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '"${_fleamarketSearchViewModel.textEditingController.text}"에 대한 검색 결과가 없습니다.',
                                    style: SDSTextStyle.regular.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.gray600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    '다른 검색어를 입력해 보세요',
                                    style: SDSTextStyle.regular.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // 다음 페이지 로딩 인디케이터
                        if (index ==
                            _fleamarketSearchViewModel.fleamarketListSearch.length) {
                          return Obx(
                                () => _fleamarketSearchViewModel.isLoadingNextList ==
                                true
                                ? Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    backgroundColor: SDSColor.gray100,
                                    color: SDSColor.gray300
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ),
                            )
                                : const SizedBox.shrink(),
                          );
                        }

                        // 아이템
                        final Fleamarket data =
                        _fleamarketSearchViewModel.fleamarketListSearch[index];
                        final String _time =
                        GetDatetime().getAgoString(data.uploadTime!);

                        final bool isDone = _isTradeDone(data);

                        return GestureDetector(
                          onTap: () async {
                            textFocus.unfocus();

                            _fleamarketDetailViewModel
                                .fetchFleamarketDetailFromList(
                              fleamarketResponse: _fleamarketSearchViewModel
                                  .fleamarketListSearch[index],
                            );

                            Get.toNamed(AppRoutes.fleamarketDetail);

                            await _fleamarketDetailViewModel.addViewerFleamarket(
                              fleamarketId: data.fleaId!,
                              userId: _userViewModel.user.user_id,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.white,
                                  height: 110,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ✅ 썸네일 + 딤드
                                      Stack(
                                        children: [
                                          if (data.photos?.isNotEmpty == true)
                                            ExtendedImage.network(
                                              data.photos!.first.urlFleaPhoto!,
                                              cache: true,
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                width: 0.5,
                                                color: SDSColor.gray100,
                                              ),
                                              width: 110,
                                              height: 110,
                                              cacheHeight: 400,
                                              fit: BoxFit.cover,
                                              loadStateChanged:
                                                  (ExtendedImageState state) {
                                                switch (state
                                                    .extendedImageLoadState) {
                                                  case LoadState.loading:
                                                    return Shimmer.fromColors(
                                                      baseColor: SDSColor.gray200!,
                                                      highlightColor:
                                                      SDSColor.gray50!,
                                                      child: Container(
                                                        width: 110,
                                                        height: 110,
                                                        decoration:
                                                        BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                        ),
                                                      ),
                                                    );
                                                  case LoadState.completed:
                                                    return state.completedWidget;
                                                  case LoadState.failed:
                                                    return ClipRRect(
                                                      borderRadius:
                                                      BorderRadius.circular(8),
                                                      child: Image.asset(
                                                        'assets/imgs/imgs/img_flea_default.png',
                                                        width: 110,
                                                        height: 110,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                }
                                              },
                                            )
                                          else
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.asset(
                                                'assets/imgs/imgs/img_flea_default.png',
                                                width: 110,
                                                height: 110,
                                                fit: BoxFit.cover,
                                              ),
                                            ),

                                          // ✅ 딤드 오버레이
                                          if (isDone)
                                            Positioned.fill(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Container(
                                                  color: Colors.black.withOpacity(0.35),
                                                ),
                                              ),
                                            ),

                                          // ✅ 거래완료 배지(선택)
                                          if (isDone)
                                            Positioned(
                                              top: 8,
                                              left: 8,  // 좌측 상단에 위치하도록 설정
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),  // 패딩을 추가하여 뱃지 모양을 만듦
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),  // 모서리를 둥글게 처리
                                                  color: SDSColor.snowliveWhite,  // 배경색과 투명도 설정
                                                ),
                                                child: Text(
                                                  '거래완료',
                                                  style: SDSTextStyle.bold.copyWith(
                                                    color: SDSColor.snowliveBlack,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(width: 16),

                                      SizedBox(
                                        width: _size.width - 158,
                                        height: 91,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data.title ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 15,
                                                color: SDSColor.gray900,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Text(
                                                  '${data.spot ?? ''} · ',
                                                  style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 13,
                                                    color: SDSColor.gray500,
                                                  ),
                                                ),
                                                Text(
                                                  _time,
                                                  style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 13,
                                                    color: SDSColor.gray500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${f.format(data.price)}원',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: SDSTextStyle.bold.copyWith(
                                                color: SDSColor.gray900,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_fleamarketSearchViewModel
                                    .fleamarketListSearch.length !=
                                    index + 1)
                                  Divider(
                                    color: SDSColor.gray100,
                                    height: 32,
                                    thickness: 1,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

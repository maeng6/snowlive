import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_fleamarket.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketSearch.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FleaMarketListView_search extends StatelessWidget {

  final f = NumberFormat('###,###,###,###');

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  final FleamarketSearchViewModel _fleamarketSearchViewModel = Get.find<FleamarketSearchViewModel>();
  final FleamarketDetailViewModel _fleamarketDetailViewModel = Get.find<FleamarketDetailViewModel>();

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: AppBar(
            backgroundColor: SDSColor.snowliveWhite,
            foregroundColor: SDSColor.snowliveWhite,
            surfaceTintColor: SDSColor.snowliveWhite,
            leading: GestureDetector(
              child: Image.asset(
                'assets/imgs/icons/icon_snowLive_back.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
              onTap: () {
                Get.back();
              },
            ),
            elevation: 0.0,
            titleSpacing: 0,
            centerTitle: true,
            title: Text('상품 검색',
              style: SDSTextStyle.extraBold.copyWith(
                  color: SDSColor.gray900,
                  fontSize: 18),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Obx(()=>Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Form(
                        key: _fleamarketSearchViewModel.formKey,
                        child: Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 10),
                          child: Stack(
                            children: [
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextFormField(
                                  onFieldSubmitted: (val) async {
                                    _fleamarketSearchViewModel.changeShowRecentSearch();
                                    await _fleamarketSearchViewModel.fetchFleamarketData_total(
                                        userId: _userViewModel.user.user_id,
                                        search_query: _fleamarketSearchViewModel.textEditingController.text
                                    );
                                    await _fleamarketSearchViewModel.saveRecentSearch(_fleamarketSearchViewModel.textEditingController.text);
                                  },
                                  autofocus: true,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: SDSColor.snowliveBlue,
                                  cursorHeight: 16,
                                  cursorWidth: 2,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  style: SDSTextStyle.regular.copyWith(fontSize: 14),
                                  strutStyle: StrutStyle(fontSize: 14, leading: 0),
                                  controller: _fleamarketSearchViewModel.textEditingController,
                                  decoration: InputDecoration(
                                    errorMaxLines: 1,
                                    errorStyle: SDSTextStyle.regular.copyWith(fontSize: 0, color: SDSColor.red),
                                    labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                    hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                    hintText: '상품 검색',
                                    contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 36, right: 12),
                                    fillColor: SDSColor.gray50,
                                    hoverColor: SDSColor.snowliveBlue,
                                    filled: true,
                                    focusColor: SDSColor.snowliveBlue,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: SDSColor.gray50),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val!.length <= 40 && val.length >= 1) {
                                      return null;
                                    } else if (val.length == 0) {
                                      return '검색어를 입력해주세요.';
                                    } else {
                                      return '최대 입력 가능한 글자 수를 초과했습니다.';
                                    }
                                  },
                                ),
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Image.asset('assets/imgs/icons/icon_search.png',
                                    width: 16,),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if(_fleamarketSearchViewModel.showRecentSearch)
                        Row(
                          children: [
                            Text('최근 검색어',
                              style: SDSTextStyle.bold.copyWith(
                                  fontSize: 14,
                                  color: SDSColor.gray900
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            GestureDetector(
                                onTap: () async{
                                  await _fleamarketSearchViewModel.deleteAllRecentSearches();
                                },
                                child: Text('전체삭제',
                                  style: SDSTextStyle.regular.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.gray500
                                  ),
                                )),
                          ],
                        ),
                      if(!_fleamarketSearchViewModel.showRecentSearch)
                        Text('검색 결과',
                          style: SDSTextStyle.bold.copyWith(
                              fontSize: 14,
                              color: SDSColor.gray900
                          ),
                        )
                    ],
                  ),
                ),),
                SizedBox(height: 20),
                Obx(() => !_fleamarketSearchViewModel.isSearching && _fleamarketSearchViewModel.recentSearches.isNotEmpty
                    && _fleamarketSearchViewModel.showRecentSearch
                    ? ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _fleamarketSearchViewModel.recentSearches.length,
                  itemBuilder: (context, index) {
                    String recentSearch = _fleamarketSearchViewModel.recentSearches[index];
                    return Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 8), // 좌우 padding 조절
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
                            _fleamarketSearchViewModel.deleteRecentSearch(recentSearch);
                          },
                        ),
                      ],
                    );
                  },
                )
                    : Container(),
                ),
                Obx(() => (_fleamarketSearchViewModel.fleamarketListSearch.isNotEmpty)
                    ? Scrollbar(
                  controller: _fleamarketSearchViewModel.scrollController,
                  child: Container(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _fleamarketSearchViewModel.scrollController, // ScrollController 연결
                      itemCount: _fleamarketSearchViewModel.fleamarketListSearch.length,
                      itemBuilder: (context, index) {
                        Fleamarket data = _fleamarketSearchViewModel.fleamarketListSearch[index];
                        String _time = GetDatetime().getAgoString(data.uploadTime!);

                        return GestureDetector(
                            onTap: () async {
                              _fleamarketDetailViewModel.fetchFleamarketDetailFromList(fleamarketResponse: _fleamarketSearchViewModel.fleamarketListSearch[index]);
                              Get.toNamed(AppRoutes.fleamarketDetail);
                              await _fleamarketDetailViewModel.fetchFleamarketComments(
                                  fleaId: _fleamarketSearchViewModel.fleamarketListSearch[index].fleaId!,
                                  userId: _userViewModel.user.user_id,
                                  isLoading_indi: true);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    height: 110,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              children: [
                                                if (data.photos!.length != 0)
                                                  ExtendedImage.network(
                                                    data.photos!.first.urlFleaPhoto!,
                                                    cache: true,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(width: 0.5, color: SDSColor.gray100),
                                                    width: 110,
                                                    height: 110,
                                                    cacheHeight: 250,
                                                    fit: BoxFit.cover,
                                                    handleLoadingProgress: true,
                                                    loadStateChanged: (ExtendedImageState state) {
                                                      switch (state.extendedImageLoadState) {
                                                        case LoadState.loading:
                                                        // 로딩 중일 때 로딩 인디케이터를 표시
                                                          return Center(child: CircularProgressIndicator());
                                                        case LoadState.completed:
                                                        // 로딩이 완료되었을 때 이미지 반환
                                                          return state.completedWidget;
                                                        case LoadState.failed:
                                                        // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                                          return Image.asset(
                                                            'assets/imgs/imgs/img_flea_default.png', // 대체 이미지 경로
                                                            width: 110,
                                                            height: 110,
                                                            fit: BoxFit.cover,
                                                          );
                                                      }
                                                    },
                                                  ),
                                                if (data.photos!.length == 0)
                                                  ExtendedImage.asset(
                                                    'assets/imgs/imgs/img_flea_default.png',
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(8),
                                                    width: 110,
                                                    height: 110,
                                                    fit: BoxFit.cover,
                                                  ),
                                                if (data.status == FleamarketStatus.soldOut.korean)
                                                  Container(
                                                    width: 110, // 이미지와 동일한 너비
                                                    height: 110, // 이미지와 동일한 높이
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.6),  // 반투명한 검정색 오버레이
                                                      borderRadius: BorderRadius.circular(8),  // 이미지와 동일한 둥근 모서리
                                                    ),
                                                  ),
                                                if (data.status == FleamarketStatus.soldOut.korean)
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
                                                        '${FleamarketStatus.soldOut.korean}',
                                                        style: SDSTextStyle.bold.copyWith(
                                                          color: SDSColor.snowliveBlack,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (data.status == FleamarketStatus.onBooking.korean)
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,  // 좌측 상단에 위치하도록 설정
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),  // 패딩을 추가하여 뱃지 모양을 만듦
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),  // 모서리를 둥글게 처리
                                                        color: SDSColor.snowliveBlue,  // 배경색과 투명도 설정
                                                      ),
                                                      child: Text(
                                                        '${FleamarketStatus.onBooking.korean}',
                                                        style: SDSTextStyle.bold.copyWith(
                                                          color: SDSColor.snowliveWhite,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: _size.width - 158,
                                                  height: 91,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      //TODO: 타이틀
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            constraints: BoxConstraints(maxWidth: _size.width - 158),
                                                            child: Text(
                                                              data.title!,
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: SDSTextStyle.regular.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      //TODO: 장소, 시간
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 2),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              '${data.spot!} · ',
                                                              style: SDSTextStyle.regular.copyWith(
                                                                  fontSize: 13,
                                                                  color: SDSColor.gray500
                                                              ),
                                                            ),
                                                            Text(
                                                              '$_time',
                                                              style: SDSTextStyle.regular.copyWith(
                                                                  fontSize: 13,
                                                                  color: SDSColor.gray500
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      //TODO: 가격
                                                      Row(
                                                        children: [
                                                          Container(
                                                              constraints: BoxConstraints(maxWidth: _size.width - 106),
                                                              child: Text(
                                                                f.format(data.price) + '원',
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    color: SDSColor.gray900,
                                                                    fontSize: 17),
                                                              )
                                                          ),
                                                        ],
                                                      ),

                                                    ],
                                                  ),
                                                ),
                                                //TODO: 조회수, 찜수, 댓글수
                                                Row(
                                                  children: [
                                                    //TODO: 조회수
                                                    if(data.viewsCount!.toInt() != 0)
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          ExtendedImage.asset(
                                                            'assets/imgs/icons/icon_list_view.png',
                                                            shape: BoxShape.rectangle,
                                                            borderRadius: BorderRadius.circular(8),
                                                            width: 16,
                                                            height: 16,
                                                            fit: BoxFit.cover,
                                                          ),
                                                          SizedBox(width: 2,),
                                                          Text(
                                                              '${data.viewsCount}',
                                                              style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 13,
                                                                color: SDSColor.gray500,
                                                              )
                                                          )
                                                        ],
                                                      ),
                                                    //TODO: 찜수
                                                    if(data.favoriteCount!.toInt() != 0)
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 6),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            (data.isFavorite == false)
                                                                ? ExtendedImage.asset(
                                                              'assets/imgs/icons/icon_list_scrap.png',
                                                              shape: BoxShape.rectangle,
                                                              borderRadius: BorderRadius.circular(8),
                                                              width: 16,
                                                              height: 16,
                                                              fit: BoxFit.cover,
                                                            )
                                                                : ExtendedImage.asset(
                                                              'assets/imgs/icons/icon_list_scrap_my.png',
                                                              shape: BoxShape.rectangle,
                                                              borderRadius: BorderRadius.circular(8),
                                                              width: 16,
                                                              height: 16,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            SizedBox(width: 2,),
                                                            Text(
                                                                '${data.favoriteCount.toString()}',
                                                                style: SDSTextStyle.regular.copyWith(
                                                                  fontSize: 13,
                                                                  color: SDSColor.gray500,
                                                                )
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    //TODO: 댓글수
                                                    if(data.commentCount!.toInt() != 0)
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 6),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            ExtendedImage.asset(
                                                              'assets/imgs/icons/icon_list_reply.png',
                                                              shape: BoxShape.rectangle,
                                                              borderRadius: BorderRadius.circular(8),
                                                              width: 16,
                                                              height: 16,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            SizedBox(width: 2,),
                                                            Text(
                                                                '${data.commentCount.toString()}',
                                                                style: SDSTextStyle.regular.copyWith(
                                                                  fontSize: 13,
                                                                  color: SDSColor.gray500,
                                                                )
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_fleamarketSearchViewModel.fleamarketListSearch.length != index + 1)
                                    Divider(
                                      color: SDSColor.gray100,
                                      height: 32,
                                      thickness: 1,
                                    ),
                                ],
                              ),
                            )
                        );
                      },
                      padding: EdgeInsets.only(bottom: 80),
                    ),
                  ),
                )
                    : Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

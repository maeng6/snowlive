import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_fleamarket.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketSearch.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FleaMarketListView_search extends StatelessWidget {
  final f = NumberFormat('###,###,###,###');
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FleamarketSearchViewModel _fleamarketSearchViewModel = Get.find<FleamarketSearchViewModel>();
  final FleamarketDetailViewModel _fleamarketDetailViewModel = Get.find<FleamarketDetailViewModel>();
  FocusNode textFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        textFocus.unfocus();
        FocusScope.of(context).unfocus();
      },
      child: Obx(()=>Scaffold(
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
              Obx(
                    () => Padding(
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
                                  focusNode: textFocus,
                                  onFieldSubmitted: (val) async {
                                    if (val.isNotEmpty) {
                                      _fleamarketSearchViewModel.showRecentSearch.value = false;
                                      await _fleamarketSearchViewModel.fetchFleamarketData_search(
                                        userId: _userViewModel.user.user_id,
                                        search_query: _fleamarketSearchViewModel.textEditingController.text,
                                      );
                                      await _fleamarketSearchViewModel.saveRecentSearch(_fleamarketSearchViewModel.textEditingController.text);
                                    }
                                  },
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: SDSColor.snowliveBlue,
                                  cursorHeight: 16,
                                  cursorWidth: 2,
                                  style: SDSTextStyle.regular.copyWith(fontSize: 14),
                                  controller: _fleamarketSearchViewModel.textEditingController,
                                  decoration: InputDecoration(
                                    errorMaxLines: 1,
                                    errorStyle: SDSTextStyle.regular.copyWith(fontSize: 0, color: SDSColor.red),
                                    labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                    hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                    hintText: '상품 검색',
                                    contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 36, right: 12),
                                    fillColor: SDSColor.gray50,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: SDSColor.gray50),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: SDSColor.snowliveBlue, width: 1.5),
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
                      SizedBox(height: 20),
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
                            Expanded(child: SizedBox()),
                            GestureDetector(
                              onTap: () async {
                                textFocus.unfocus();
                                await _fleamarketSearchViewModel.deleteAllRecentSearches();
                              },
                              child: Text(
                                '전체삭제',
                                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                              ),
                            ),
                          ],
                        ),
                      if (!_fleamarketSearchViewModel.showRecentSearch.value)
                        Text(
                          '검색 결과',
                          style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              (_fleamarketSearchViewModel.isLoading ==true)
                  ? Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        backgroundColor: SDSColor.snowliveWhite,
                        color: SDSColor.snowliveBlue,
                      ),
                    ),
                  ],
                ),
              )
                  :Expanded(
                child: Obx(
                      () => SingleChildScrollView(
                    child: Column(
                      children: [
                        if (!_fleamarketSearchViewModel.isSearching &&
                            _fleamarketSearchViewModel.recentSearches.isNotEmpty &&
                            _fleamarketSearchViewModel.showRecentSearch.value)
                          Column(
                            children: List.generate(
                              _fleamarketSearchViewModel.recentSearches.length,
                                  (index) {
                                String recentSearch = _fleamarketSearchViewModel.recentSearches[index];
                                return GestureDetector(
                                  onTap: () async {
                                    textFocus.unfocus();
                                    _fleamarketSearchViewModel.textEditingController.text = recentSearch;
                                    _fleamarketSearchViewModel.showRecentSearch.value = false;
                                    await _fleamarketSearchViewModel.fetchFleamarketData_search(
                                      userId: _userViewModel.user.user_id,
                                      search_query: recentSearch,
                                    );
                                    await _fleamarketSearchViewModel.saveRecentSearch(recentSearch);
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 16, right: 8),
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
                                  ),
                                );
                              },
                            ),
                          ),
                        if (_fleamarketSearchViewModel.fleamarketListSearch.isNotEmpty)
                          ConstrainedBox(
                            constraints: BoxConstraints(minHeight: _size.height),
                            child: Scrollbar(
                              controller: _fleamarketSearchViewModel.scrollController,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                controller: _fleamarketSearchViewModel.scrollController,
                                itemCount: _fleamarketSearchViewModel.fleamarketListSearch.length,
                                itemBuilder: (context, index) {
                                  Fleamarket data = _fleamarketSearchViewModel.fleamarketListSearch[index];
                                  String _time = GetDatetime().getAgoString(data.uploadTime!);

                                  return GestureDetector(
                                    onTap: () async {
                                      textFocus.unfocus();
                                      _fleamarketDetailViewModel.fetchFleamarketDetailFromList(
                                          fleamarketResponse: _fleamarketSearchViewModel.fleamarketListSearch[index]);
                                      Get.toNamed(AppRoutes.fleamarketDetail);
                                      await _fleamarketDetailViewModel.addViewerFleamarket(fleamarketId: data.fleaId!, userId: _userViewModel.user.user_id);
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
                                                              Text(
                                                                data.title!,
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: SDSTextStyle.regular.copyWith(
                                                                    fontSize: 15, color: SDSColor.gray900),
                                                              ),
                                                              SizedBox(height: 2),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    '${data.spot!} · ',
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                        fontSize: 13, color: SDSColor.gray500),
                                                                  ),
                                                                  Text(
                                                                    '$_time',
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                        fontSize: 13, color: SDSColor.gray500),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(height: 2),
                                                              Text(
                                                                f.format(data.price) + '원',
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    color: SDSColor.gray900, fontSize: 17),
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
                                                                  Container(
                                                                    width: 16,
                                                                    height: 16,
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.circular(8),
                                                                      image: DecorationImage(
                                                                        image: AssetImage('assets/imgs/icons/icon_list_view.png'),
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    ),
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
                                                                        ? Container(
                                                                      width: 16,
                                                                      height: 16,
                                                                      decoration: BoxDecoration(
                                                                        shape: BoxShape.rectangle,
                                                                        borderRadius: BorderRadius.circular(8),
                                                                        image: DecorationImage(
                                                                          image: AssetImage('assets/imgs/icons/icon_list_scrap.png'),
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    )
                                                                        : Container(
                                                                      width: 16,
                                                                      height: 16,
                                                                      decoration: BoxDecoration(
                                                                        shape: BoxShape.rectangle,
                                                                        borderRadius: BorderRadius.circular(8),
                                                                        image: DecorationImage(
                                                                          image: AssetImage('assets/imgs/icons/icon_list_scrap_my.png'),
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    )
                                                                    ,
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
                                                                    Container(
                                                                      width: 16,
                                                                      height: 16,
                                                                      decoration: BoxDecoration(
                                                                        shape: BoxShape.rectangle,
                                                                        borderRadius: BorderRadius.circular(8),
                                                                        image: DecorationImage(
                                                                          image: AssetImage('assets/imgs/icons/icon_list_reply.png'),
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
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
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        if (_fleamarketSearchViewModel.fleamarketListSearch.isEmpty
                            && _fleamarketSearchViewModel.showRecentSearch.value == false)
                          ConstrainedBox(
                            constraints: BoxConstraints(minHeight: _size.height),
                            child: Scrollbar(
                              controller: _fleamarketSearchViewModel.scrollController,
                              child: Container(child: Text('검색 결과가 없습니다.'),)
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

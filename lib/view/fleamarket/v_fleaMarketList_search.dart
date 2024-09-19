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
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
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
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            body: Column(
              children: [
                Obx(()=>Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Form(
                        key: _fleamarketSearchViewModel.formKey,
                        child: Container(
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
                            cursorColor: Color(0xff949494),
                            cursorHeight: 18,
                            cursorWidth: 2,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: _fleamarketSearchViewModel.textEditingController,
                            decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                prefixIcon: Icon(Icons.search, color: Color(0xFF666666)),
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                ),
                                labelStyle: TextStyle(color: Color(0xff666666), fontSize: 15),
                                hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                hintText: '상품 검색',
                                labelText: '상품 검색',
                                contentPadding: EdgeInsets.symmetric(vertical: 6),
                                fillColor: Color(0xFFEFEFEF),
                                hoverColor: Colors.transparent,
                                filled: true,
                                focusColor: Colors.transparent,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(6),
                                )),
                            validator: (val) {
                              if (val!.length <= 20 && val.length >= 1) {
                                return null;
                              } else if (val.length == 0) {
                                return '검색어를 입력해주세요.';
                              } else {
                                return '최대 입력 가능한 글자 수를 초과했습니다.';
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 25,),
                      if(_fleamarketSearchViewModel.showRecentSearch)
                        Row(
                          children: [
                            Text('최근 검색',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            GestureDetector(
                                onTap: () async{
                                  await _fleamarketSearchViewModel.deleteAllRecentSearches();
                                },
                                child: Text('전체삭제',
                                  style: TextStyle(
                                      color: SDSColor.gray500
                                  ),
                                )),
                          ],
                        ),
                      if(!_fleamarketSearchViewModel.showRecentSearch)
                        Text('검색 결과',
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        )
                    ],
                  ),
                ),),

                SizedBox(height: 20),
                Obx(
                      () => !_fleamarketSearchViewModel.isSearching && _fleamarketSearchViewModel.recentSearches.isNotEmpty
                      && _fleamarketSearchViewModel.showRecentSearch
                      ? Expanded(
                    child: ListView.builder(
                      itemCount: _fleamarketSearchViewModel.recentSearches.length,
                      itemBuilder: (context, index) {
                        String recentSearch = _fleamarketSearchViewModel.recentSearches[index];
                        return ListTile(
                          title: Text(recentSearch),
                          trailing: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _fleamarketSearchViewModel.deleteRecentSearch(recentSearch);
                            },
                          ),
                          onTap: () {
                            _fleamarketSearchViewModel.textEditingController.text = recentSearch;
                            _fleamarketSearchViewModel.search(recentSearch);
                            _fleamarketSearchViewModel.fetchFleamarketData_total(
                              userId: _userViewModel.user.user_id,
                              search_query: recentSearch,
                            );
                            _fleamarketSearchViewModel.changeShowRecentSearch();

                          },
                        );
                      },
                    ),
                  )
                      : Container(),
                ),

                Expanded(
                  child: Obx(
                        () => (_fleamarketSearchViewModel.fleamarketListSearch.isNotEmpty)
                        ? Scrollbar(
                      controller: _fleamarketSearchViewModel.scrollController,
                      child: ListView.builder(
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
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              children: [
                                                if (data.photos!.length != 0)
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                                    child: ExtendedImage.network(data.photos!.first.urlFleaPhoto!,
                                                      cache: true,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(width: 0.5, color: Color(0xFFdedede)),
                                                      width: 100,
                                                      height: 100,
                                                      cacheHeight: 250,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                if (data.photos!.length == 0)
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                                    child: ExtendedImage.asset(
                                                      'assets/imgs/profile/img_profile_default_.png',
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.circular(8),
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                if (data.status == FleamarketStatus.soldOut.korean)
                                                  Positioned(
                                                    top: 8,
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(8),
                                                            color: Color(0xFF000000).withOpacity(0.6),
                                                          ),
                                                          width: 100,
                                                          height: 100,
                                                        ),
                                                        Positioned(
                                                          top: 40,
                                                          left: 20,
                                                          child: Text('${FleamarketStatus.soldOut.korean}',
                                                            style: TextStyle(
                                                                color: Color(0xFFFFFFFF),
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16
                                                            ),),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (data.status == FleamarketStatus.forSale.korean)
                                                  Positioned(
                                                    top: 20,
                                                    left: 20,
                                                    child: Text('${FleamarketStatus.forSale.korean}',
                                                      style: TextStyle(
                                                          color: Color(0xFFFFFFFF),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16
                                                      ),),
                                                  ),
                                                if (data.status == FleamarketStatus.onBooking.korean)
                                                  Positioned(
                                                    top: 20,
                                                    left: 20,
                                                    child: Text('${FleamarketStatus.onBooking.korean}',
                                                      style: TextStyle(
                                                          color: Color(0xFFFFFFFF),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16
                                                      ),),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(width: 16),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 6),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        constraints: BoxConstraints(maxWidth: _size.width - 170),
                                                        child: Text(
                                                          data.title!,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.normal,
                                                              fontSize: 15,
                                                              color: Color(0xFF555555)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '$_time',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Color(0xFF949494),
                                                            fontWeight: FontWeight.normal),
                                                      ),
                                                      SizedBox(width: 10),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                          constraints: BoxConstraints(maxWidth: _size.width - 106),
                                                          child: Text(
                                                            f.format(data.price) + ' 원',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                color: Color(0xFF111111),
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16),
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3),
                                                      color: Color(0xFFD5F7E0),
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                    child: Text(
                                                      data.spot!,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                          color: Color(0xFF17AD4A)),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      if (data.viewsCount!.toInt() != 0)
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 2),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.remove_red_eye_rounded,
                                                                color: Color(0xFFc8c8c8),
                                                                size: 15,
                                                              ),
                                                              SizedBox(width: 4),
                                                              Text(
                                                                  '${data.viewsCount}',
                                                                  style: TextStyle(
                                                                      fontSize: 13,
                                                                      color: Color(0xFF949494),
                                                                      fontWeight: FontWeight.normal)
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      if (data.favoriteCount!.toInt() != 0)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: Color(0xFFD5F7E0),
                                                          ),
                                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                          child: Text(
                                                            data.favoriteCount.toString()!,
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                                color: Color(0xFF17AD4A)),
                                                          ),
                                                        ),
                                                      if (data.commentCount!.toInt() != 0)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: Color(0xFFD5F7E0),
                                                          ),
                                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                          child: Text(
                                                            data.commentCount.toString(),
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                                color: Color(0xFF17AD4A)),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_fleamarketSearchViewModel.fleamarketListSearch.length != index + 1)
                                    Divider(
                                      color: Color(0xFFDEDEDE),
                                      height: 16,
                                      thickness: 0.5,
                                    ),
                                ],
                              )
                          );
                        },
                        padding: EdgeInsets.only(bottom: 80),
                      ),
                    )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

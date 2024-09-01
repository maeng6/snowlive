import 'package:com.snowlive/viewmodel/vm_fleamarketList.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/m_fleamarket.dart';
import '../util/util_1.dart';
import '../viewmodel/vm_user.dart';

class FleaMarketListView_my extends StatelessWidget {

  final f = NumberFormat('###,###,###,###');

  final FleamarketListViewModel _fleamarketViewModel = Get.find<FleamarketListViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          floatingActionButton: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: _size.height - 308),
                  child: Visibility(
                    visible: _fleamarketViewModel.isVisible,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Container(
                        width: 106,
                        child: FloatingActionButton(
                          heroTag: 'fleamarketList',
                          mini: true,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)
                          ),
                          backgroundColor: Color(0xFF000000).withOpacity(0.8),
                          foregroundColor: Colors.white,
                          onPressed: () {
                            _fleamarketViewModel.scrollController.jumpTo(0);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_upward_rounded,
                                  color: Color(0xFFffffff),
                                  size: 16),
                              Padding(
                                padding: const EdgeInsets.only(left: 2, right: 3),
                                child: Text('최신글 보기',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFffffff).withOpacity(0.8),
                                      letterSpacing: 0
                                  ),),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                child: Transform.translate(
                  offset: Offset(18, 0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: AnimatedContainer(
                      width: _fleamarketViewModel.showAddButton ? 104 : 52,
                      height: 52,
                      duration: Duration(milliseconds: 200),
                      child: FloatingActionButton.extended(
                        elevation: 4,
                        heroTag: 'fleaListScreen',
                        onPressed: () async {

                        },
                        icon: Transform.translate(
                            offset: Offset(6,0),
                            child: Center(child: Icon(Icons.add))),
                        label: _fleamarketViewModel.showAddButton
                            ? Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text('글쓰기',
                            style: TextStyle(
                                letterSpacing: 0.5,
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis),
                          ),
                        )
                            : SizedBox.shrink(), // Hide the text when _showAddButton is false
                        backgroundColor: Color(0xFF3D6FED),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          backgroundColor: Colors.white,
          body: Obx(()=>Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Column(
              children: [
                //TODO: 리스트
                Expanded(
                    child: (_fleamarketViewModel.fleamarketListMy.length == 0)
                        ? Transform.translate(
                      offset: Offset(0, -40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/imgs/icons/icon_nodata.png',
                            scale: 4,
                            width: 73,
                            height: 73,
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text('게시판에 글이 없습니다.',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF949494)
                            ),
                          ),
                        ],
                      ),
                    )
                        : Scrollbar(
                      controller: _fleamarketViewModel.scrollController,
                      child: ListView.builder(
                        controller: _fleamarketViewModel.scrollController, // ScrollController 연결
                        itemCount: _fleamarketViewModel.fleamarketListMy.length,
                        itemBuilder: (context, index) {
                          Fleamarket data = _fleamarketViewModel.fleamarketListMy[index] ;
                          String _time = GetDatetime().getAgoString(data.uploadTime!);

                          return GestureDetector(
                              onTap: () async {

                              },
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                                    child: ExtendedImage
                                                        .asset(
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
                                              padding:
                                              const EdgeInsets.symmetric(vertical: 6),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  //TODO: 타이틀
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
                                                  //TODO: 시간
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '$_time',
                                                        style: TextStyle(
                                                            fontSize:
                                                            14,
                                                            color: Color(
                                                                0xFF949494),
                                                            fontWeight:
                                                            FontWeight
                                                                .normal),
                                                      ),
                                                      SizedBox(width: 10,),
                                                    ],
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
                                                            f.format(data.price) + ' 원',
                                                            maxLines:
                                                            1,
                                                            overflow:
                                                            TextOverflow.ellipsis,
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
                                                  //TODO: 거래장소
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3),
                                                      color: Color(0xFFD5F7E0),
                                                    ),
                                                    padding: EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 3),
                                                    child: Text(
                                                      data.spot!,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                          color: Color(0xFF17AD4A)),
                                                    ),
                                                  ),
                                                  //TODO: 조회수, 찜수, 댓글수
                                                  Row(
                                                    children: [
                                                      //TODO: 조회수
                                                      if(data.viewsCount!.toInt() != 0)
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
                                                              SizedBox(width: 4,),
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
                                                      //TODO: 찜수
                                                      if(data.favoriteCount!.toInt() != 0)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: Color(0xFFD5F7E0),
                                                          ),
                                                          padding: EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 3),
                                                          child: Text(
                                                            data.favoriteCount.toString()!,
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                                color: Color(0xFF17AD4A)),
                                                          ),
                                                        ),
                                                      //TODO: 댓글수
                                                      if(data.commentCount!.toInt() != 0)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: Color(0xFFD5F7E0),
                                                          ),
                                                          padding: EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 3),
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
                                  if (_fleamarketViewModel.fleamarketListMy.length != index + 1)
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
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}

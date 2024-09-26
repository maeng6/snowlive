import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_communityList.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityBulletinList.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CommunityBulletinRoomListView extends StatelessWidget {

  final CommunityBulletinListViewModel _communityBulletinListViewModel = Get.find<CommunityBulletinListViewModel>();
  final CommunityDetailViewModel _communityDetailViewModel = Get.find<CommunityDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Obx(()=>Container(
        color: Colors.white,
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Stack(
            children: [
              //최신글보기
              Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: _communityBulletinListViewModel.isVisible_room,
                  child: Container(
                    width: 106,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      heroTag: 'bulletin_room_recent',
                      mini: true,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                        side: BorderSide(color: SDSColor.gray200),
                      ),
                      backgroundColor: SDSColor.snowliveWhite,
                      foregroundColor: SDSColor.snowliveWhite,
                      onPressed: () {
                        _communityBulletinListViewModel.scrollController_room.jumpTo(0);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward_rounded,
                              color: SDSColor.gray900,
                              size: 16),
                          Padding(
                            padding: const EdgeInsets.only(left: 2, right: 3),
                            child: Text('최신글 보기',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: SDSColor.gray900,
                                  letterSpacing: 0
                              ),),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //글쓰기 버튼
              Positioned(
                child: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: AnimatedContainer(
                      width: _communityBulletinListViewModel.showAddButton_room ? 104 : 52,
                      height: 52,
                      duration: Duration(milliseconds: 200),
                      child: FloatingActionButton.extended(
                        heroTag: 'bulletin_room',
                        elevation: 4,
                        onPressed: () async {
                          Get.toNamed(AppRoutes.bulletinUpload);
                        },
                        icon: Transform.translate(
                          offset: Offset(6, 0),
                          child: Center(child: Icon(Icons.add,
                            color: SDSColor.snowliveWhite,)),
                        ),
                        label: _communityBulletinListViewModel.showAddButton_room
                            ? Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            '글쓰기',
                            style: SDSTextStyle.bold.copyWith(
                                letterSpacing: 0.5,
                                fontSize: 15,
                                color: SDSColor.snowliveWhite,
                                overflow: TextOverflow.ellipsis),
                          ),
                        )
                            : SizedBox.shrink(),
                        backgroundColor: SDSColor.snowliveBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body:
          (_communityBulletinListViewModel.isLoadingList_room==true)
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
              : RefreshIndicator(
            strokeWidth: 2,
            edgeOffset: 20,
            backgroundColor: SDSColor.snowliveWhite,
            color: SDSColor.snowliveBlue,
            onRefresh: _communityBulletinListViewModel.onRefresh_bulletin_room,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _communityBulletinListViewModel.scrollController_room,
              child: Column(
                children: [
                  Column(
                    children: [
                      (_communityBulletinListViewModel.communityList_room.length == 0)
                          ? Container(
                        height: _size.height-380,
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
                              SizedBox(
                                height: 6,
                              ),
                              Text('게시판에 글이 없습니다.',
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 14,
                                    color: SDSColor.gray700
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _communityBulletinListViewModel.communityList_room.length,
                          itemBuilder: (context, index) {
                            Community communityData = _communityBulletinListViewModel.communityList_room[index];
                            // 필드가 없을 경우 기본값 설정
                            String _time = GetDatetime().yyyymmddFormatFromString(communityData.uploadTime!);
                            String? profileUrl = communityData.userInfo!.profileImageUrlUser;
                            String? displayName = communityData.userInfo!.displayName;
                            return GestureDetector(
                              onTap: () async {
                                _communityDetailViewModel.fetchCommunityDetailFromList(community: _communityBulletinListViewModel.communityList_room[index]);
                                Get.toNamed(AppRoutes.bulletinDetail);
                                await _communityDetailViewModel.addViewerCommunity(
                                    _communityDetailViewModel.communityDetail.communityId!,
                                    {
                                  "user_id":_userViewModel.user.user_id.toString()
                                });
                              },
                              child: Obx(() => Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Container(
                                      color: Colors.white,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: _size.width - 32,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 6, bottom: 8),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 6),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          //시즌방 하위카테고리 뱃지 디자인
                                                                          if (communityData.categorySub == Community_Category_sub_bulletin.room.korean)
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(right: 6),
                                                                              child: Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                                                                decoration: BoxDecoration(
                                                                                  color: SDSColor.gray50,
                                                                                  borderRadius: BorderRadius.circular(4),
                                                                                ),
                                                                                child: Text('${communityData.categorySub2}',
                                                                                  style: SDSTextStyle.regular.copyWith(
                                                                                      fontSize: 11,
                                                                                      color: SDSColor.gray700),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          // 게시글 타이틀
                                                                          Expanded(
                                                                            child: Container(
                                                                              child: Text(
                                                                                '${communityData.title}',
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text('$displayName',
                                                              style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 12,
                                                                color: SDSColor.gray700,
                                                              ),
                                                            ),
                                                            Text(' · $_time',
                                                              style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 12,
                                                                color: SDSColor.gray700,
                                                              ),
                                                            ),
                                                            Text('  |  ',
                                                              style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 12,
                                                                color: SDSColor.gray300,
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Image.asset('assets/imgs/icons/icon_eye_rounded.png',
                                                                  width: 14,
                                                                  height: 14,),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 2),
                                                                  child: Text(
                                                                    '${communityData.viewsCount}',
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 12,
                                                                      color: SDSColor.gray700,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 6),
                                                                Image.asset('assets/imgs/icons/icon_reply_rounded.png',
                                                                  width: 14,
                                                                  height: 14,),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 2),
                                                                  child: Text('${communityData.commentCount}',
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 12,
                                                                      color: SDSColor.gray700,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                (communityData.thumbImg != null)
                                                    ? Padding(
                                                  padding: const EdgeInsets.only(left: 16),
                                                  child: ExtendedImage.network(communityData.thumbImg!,
                                                    cache: true,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(width: 0.5, color: Color(0xFFdedede)),
                                                    width: 50,
                                                    height: 50,
                                                    cacheHeight: 250,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                                    : Container()
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if(_communityBulletinListViewModel.communityList_room.length != index + 1)
                                    Divider(
                                      color: SDSColor.gray50,
                                      height: 16,
                                      thickness: 1,
                                    ),
                                ],
                              )),
                            );
                          },
                          padding: EdgeInsets.only(bottom: 80),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}
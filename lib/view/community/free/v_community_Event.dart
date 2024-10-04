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
import 'package:shimmer/shimmer.dart';

class CommunityEventListView extends StatelessWidget {

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
          floatingActionButton: Obx(()=>Stack(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Obx(()=> Visibility(
                  visible: _communityBulletinListViewModel.isVisible_event,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 64, right: 16),
                    child: Container(
                      width: 52,
                      height: 52,
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
                        heroTag: 'bulletin_event_recent',
                        mini: true,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                          side: BorderSide(color: SDSColor.gray200),
                        ),
                        backgroundColor: SDSColor.snowliveWhite,
                        foregroundColor: SDSColor.snowliveWhite,
                        onPressed: () {
                          _communityBulletinListViewModel.scrollController_event.jumpTo(0);
                        },
                        child: Image.asset( 'assets/imgs/icons/icon_top_page.png',
                          fit: BoxFit.cover,
                          width: 16,
                          height: 16,),
                      ),
                    ),
                  ),
                )),
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: AnimatedContainer(
                      width: _communityBulletinListViewModel.showAddButton_event ? 104 : 52,
                      height: 52,
                      duration: Duration(milliseconds: 200),
                      child: FloatingActionButton.extended(
                        elevation: 4,
                        heroTag: 'bulletin_total',
                        onPressed: () {
                          Get.toNamed(AppRoutes.bulletinUpload);
                        },
                        icon: Transform.translate(
                            offset: Offset(6,0),
                            child: Center(child: Icon(Icons.add,
                              color: SDSColor.snowliveWhite,
                            ))),
                        label: _communityBulletinListViewModel.showAddButton_event
                            ? Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text('글쓰기',
                            style: SDSTextStyle.bold.copyWith(
                                letterSpacing: 0.5,
                                fontSize: 15,
                                color: SDSColor.snowliveWhite,
                                overflow: TextOverflow.ellipsis),
                          ),
                        )
                            : SizedBox.shrink(), // Hide the text when _showAddButton is false
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
          )),
          backgroundColor: Colors.white,
          body:
          (_communityBulletinListViewModel.isLoadingList_event==true)
              ? Container(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            backgroundColor: SDSColor.gray100,
                            color: SDSColor.gray300.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            strokeWidth: 2,
            edgeOffset: -100,
            displacement: 100,
            backgroundColor: SDSColor.snowliveBlue,
            color: SDSColor.snowliveWhite,
            onRefresh: _communityBulletinListViewModel.onRefresh_bulletin_event,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _communityBulletinListViewModel.scrollController_event,
              child: Column(
                children: [
                  Column(
                    children: [
                      (_communityBulletinListViewModel.communityList_event.length == 0)
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
                        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _communityBulletinListViewModel.communityList_event.length + 1,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 20,
                            childAspectRatio: 1 / 1.73,
                          ),
                          itemBuilder: (context, index) {


                            if(index == _communityBulletinListViewModel.communityList_event.length){
                              return Obx(() => _communityBulletinListViewModel.isLoadingNextList_event == true // 여기서 Obx 사용
                                  ? Container(
                                height: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          backgroundColor: SDSColor.gray100,
                                          color: SDSColor.gray300.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : SizedBox.shrink());
                            }else{
                              Community communityData = _communityBulletinListViewModel.communityList_event[index];
                              // 필드가 없을 경우 기본값 설정
                              String _time = GetDatetime().yyyymmddFormatFromString(communityData.uploadTime!);
                              String? profileUrl = communityData.userInfo!.profileImageUrlUser;
                              String? displayName = communityData.userInfo!.displayName;
                              return GestureDetector(
                                onTap: () async {
                                  _communityDetailViewModel.fetchCommunityDetailFromList(community: _communityBulletinListViewModel.communityList_event[index]);
                                  Get.toNamed(AppRoutes.bulletinDetail);
                                  await _communityDetailViewModel.addViewerCommunity(
                                      _communityDetailViewModel.communityDetail.communityId!,
                                      {
                                        "user_id":_userViewModel.user.user_id.toString()
                                      });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: _size.width /2 - 27 ,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                (communityData.thumbImg != null)
                                                    ? ExtendedImage.network(communityData.thumbImg!,
                                                  cache: true,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(width: 1, color: SDSColor.gray100),
                                                  width: _size.width /2 - 27,
                                                  height: _size.width /2 - 27,
                                                  cacheHeight: 1000,
                                                  fit: BoxFit.cover,
                                                  loadStateChanged: (ExtendedImageState state) {
                                                    switch (state.extendedImageLoadState) {
                                                      case LoadState.loading:
                                                      // 로딩 중일 때 로딩 인디케이터를 표시
                                                        return Shimmer.fromColors(
                                                          baseColor: SDSColor.gray200!,
                                                          highlightColor: SDSColor.gray50!,
                                                          child: Container(
                                                            width: 32,
                                                            height: 32,
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                        );
                                                      case LoadState.completed:
                                                      // 로딩이 완료되었을 때 이미지 반환
                                                        return state.completedWidget;
                                                      case LoadState.failed:
                                                      // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                                        return ExtendedImage.network(
                                                          'https://i.esdrop.com/d/f/yytYSNBROy/kVsZwVhd1f.png',
                                                          shape: BoxShape.rectangle,
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(width: 0.5, color: Color(0xFFdedede)),
                                                          width: 32,
                                                          height: 32,
                                                          cacheHeight: 100,
                                                          cache: true,
                                                          fit: BoxFit.cover,
                                                        );
                                                    }
                                                  },
                                                )
                                                    : Container(
                                                  width: _size.width /2 - 27,
                                                  height: _size.width /2 - 27,
                                                  decoration: BoxDecoration(
                                                    color: SDSColor.blue50,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Image.asset(
                                                        'assets/imgs/logos/snowlive_logo_new.png',
                                                        width: 120,
                                                        color: SDSColor.blue100,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Padding(
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
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      // 게시글 타이틀
                                                                      Padding(
                                                                        padding: EdgeInsets.only(top: 6, bottom: 4),
                                                                        child: Container(
                                                                          width: _size.width /2 - 27,
                                                                          child: Text(
                                                                            '${communityData.title}',
                                                                            maxLines: 2,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style: SDSTextStyle.bold.copyWith(
                                                                                fontSize: 15,
                                                                                color: SDSColor.gray900
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      //카테고리 뱃지 디자인
                                                                      Padding(
                                                                        padding: EdgeInsets.only(top: 2),
                                                                        child: Container(
                                                                          width: _size.width /2 - 27,
                                                                          child: Row(
                                                                            children: [
                                                                              Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                                                decoration: BoxDecoration(
                                                                                  color: SDSColor.blue50,
                                                                                  borderRadius: BorderRadius.circular(4),
                                                                                ),
                                                                                child: Text(
                                                                                  '${communityData.categorySub}',
                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                      fontSize: 11,
                                                                                      color: SDSColor.snowliveBlue),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.only(left: 6),
                                                                                child: Text(
                                                                                  '$displayName',
                                                                                  style: SDSTextStyle.regular.copyWith(
                                                                                    fontSize: 13,
                                                                                    color: SDSColor.gray900,
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),


                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text('$_time',
                                                        style: SDSTextStyle.regular.copyWith(
                                                          fontSize: 12,
                                                          color: SDSColor.gray500,
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
                                  ],
                                ),
                              );
                            }


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
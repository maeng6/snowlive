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

class CommunityBulletinFreeListView extends StatelessWidget {

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
                  visible: _communityBulletinListViewModel.isVisible_free,
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
                        heroTag: 'bulletin_free_recent',
                        mini: true,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                          side: BorderSide(color: SDSColor.gray200),
                        ),
                        backgroundColor: SDSColor.snowliveWhite,
                        foregroundColor: SDSColor.snowliveWhite,
                        onPressed: () {
                          _communityBulletinListViewModel.scrollController_free.jumpTo(0);
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
                      width: _communityBulletinListViewModel.showAddButton_free ? 104 : 52,
                      height: 52,
                      duration: Duration(milliseconds: 200),
                      child: FloatingActionButton.extended(
                        elevation: 4,
                        heroTag: 'bulletin_free',
                        onPressed: () {
                          Get.toNamed(AppRoutes.bulletinUpload);
                        },
                        icon: Transform.translate(
                            offset: Offset(6,0),
                            child: Center(child: Icon(Icons.add,
                              color: SDSColor.snowliveWhite,
                            ))),
                        label: _communityBulletinListViewModel.showAddButton_free
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
          (_communityBulletinListViewModel.isLoadingList_free==true)
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
            onRefresh: _communityBulletinListViewModel.onRefresh_bulletin_free,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _communityBulletinListViewModel.scrollController_free,
              child: Column(
                children: [
                  Column(
                    children: [
                      (_communityBulletinListViewModel.communityList_free.length == 0)
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
                          itemCount: _communityBulletinListViewModel.communityList_free.length + 1,
                          itemBuilder: (context, index) {

                            if(index == _communityBulletinListViewModel.communityList_free.length){
                              return Obx(() => _communityBulletinListViewModel.isLoadingNextList_free == true // 여기서 Obx 사용
                                  ? Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 24),
                                  child: Container(
                                    width: 24,
                                    height: 24,
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
                                ),
                              )
                                  : SizedBox.shrink());
                            }else{
                              Community communityData = _communityBulletinListViewModel.communityList_free[index];
                              // 필드가 없을 경우 기본값 설정
                              String _time = GetDatetime().yyyymmddFormatFromString(communityData.uploadTime!);
                              String? profileUrl = communityData.userInfo!.profileImageUrlUser;
                              String? displayName = communityData.userInfo!.displayName;
                              return GestureDetector(
                                onTap: () async {
                                  _communityDetailViewModel.fetchCommunityDetailFromList(community: _communityBulletinListViewModel.communityList_free[index]);
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
                                                      loadStateChanged: (ExtendedImageState state) {
                                                        switch (state.extendedImageLoadState) {
                                                          case LoadState.loading:
                                                            return SizedBox.shrink();
                                                          case LoadState.completed:
                                                            return state.completedWidget;
                                                          case LoadState.failed:
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
                                                          default:
                                                            return null;
                                                        }
                                                      },
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
                                    if(_communityBulletinListViewModel.communityList_free.length != index + 1)
                                      Divider(
                                        color: SDSColor.gray50,
                                        height: 16,
                                        thickness: 1,
                                      ),
                                  ],
                                )),
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
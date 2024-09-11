import 'package:com.snowlive/controller/public/vm_limitController.dart';
import 'package:com.snowlive/controller/bulletin/vm_streamController_bulletin.dart';
import 'package:com.snowlive/screens/bulletin/Free/v_bulletin_Free_List_Detail.dart';
import 'package:com.snowlive/screens/bulletin/Free/v_bulletin_Free_Upload.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/user/vm_allUserDocsController.dart';
import '../../../controller/bulletin/vm_bulletinFreeController.dart';
import '../../../controller/public/vm_timeStampController.dart';
import '../../../controller/user/vm_userModelController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../model/m_communityList.dart';
import '../../../model_2/m_bulletinFreeModel.dart';
import '../../../screens/snowliveDesignStyle.dart';
import '../../../util/util_1.dart';
import '../../../viewmodel/vm_communityFreeList.dart';
import '../../../widget/w_fullScreenDialog.dart';

class CommunityBulletinTotalListView extends StatefulWidget {
  const CommunityBulletinTotalListView({Key? key}) : super(key: key);

  @override
  State<CommunityBulletinTotalListView> createState() => _CommunityBulletinTotalListViewState();

}

class _CommunityBulletinTotalListViewState extends State<CommunityBulletinTotalListView> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  BulletinFreeModelController _bulletinFreeModelController = Get.find<BulletinFreeModelController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  limitController _seasonController = Get.find<limitController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  StreamController_Bulletin _streamController_Bulletin = Get.find<StreamController_Bulletin>();
  //TODO: Dependency Injection**************************************************

  final CommunityBulletinListViewModel _communityBulletinListViewModel = Get.find<CommunityBulletinListViewModel>();

  bool _isVisible = false;
  bool _orderbyLike = false;
  bool _orderbyView = false;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _bulletinFreeStream;

  var f = NumberFormat('###,###,###,###');

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    _seasonController.getBulletinFreeLimit();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: _size.height - 292),
                  child: Visibility(
                    visible: _communityBulletinListViewModel.isVisible_total,
                    child: Container(
                      width: 106,
                      child: FloatingActionButton(
                        heroTag: 'bulletin_total',
                        mini: true,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)
                        ),
                        backgroundColor: Color(0xFF000000).withOpacity(0.8),
                        foregroundColor: Colors.white,
                        onPressed: () {
                          _communityBulletinListViewModel.scrollController_total.jumpTo(0);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward_rounded,
                                color: Color(0xFFffffff),
                                size: 18),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 3),
                              child: Text('최신글 보기',
                                style: SDSTextStyle.bold.copyWith(
                                    fontSize: 13,
                                    color: SDSColor.snowliveWhite.withOpacity(0.8),
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
              Positioned(
                bottom: 0, // Adjust the position as needed
                right: 16, // Adjust the position as needed
                child: AnimatedContainer(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: SDSColor.snowliveBlack.withOpacity(0.2),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ]
                  ),
                  width: _communityBulletinListViewModel.showAddButton_total ? 104 : 52,
                  height: 52,
                  duration: Duration(milliseconds: 200),
                  child: FloatingActionButton.extended(
                    heroTag: 'bulletin_total',
                    elevation: 0,
                    onPressed: () async {
                      // Get.to(() => Bulletin_Free_Upload());
                    },
                    icon: Transform.translate(
                      offset: Offset(6, 0),
                      child: Center(child: Icon(Icons.add,
                      size: 24,)),
                    ),
                    label: _communityBulletinListViewModel.showAddButton_total
                        ? Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        '글쓰기',
                        style: SDSTextStyle.bold.copyWith(
                          letterSpacing: 0.5,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    )
                        : SizedBox.shrink(),
                    backgroundColor: SDSColor.snowliveBlue,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: _communityBulletinListViewModel.onRefresh_flea_total,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _communityBulletinListViewModel.scrollController_total,
              child: Column(
                children: [
                  Column(
                    children: [
                      (_communityBulletinListViewModel.communityList_total.length == 0)
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
                          itemCount: _communityBulletinListViewModel.communityList_total.length,
                          itemBuilder: (context, index) {
                            Community communityData = _communityBulletinListViewModel.communityList_total[index];
                            // 필드가 없을 경우 기본값 설정
                            String _time = GetDatetime().yyyymmddFormat(communityData.uploadTime!);
                            String? profileUrl = communityData.userInfo!.profileImageUrlUser;
                            String? displayName = communityData.userInfo!.displayName;
                            return GestureDetector(
                              onTap: () async {

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
                                                                          //자유게시판 카테고리 뱃지 디자인
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(right: 6),
                                                                            child: Container(
                                                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                                                              decoration: BoxDecoration(
                                                                                color: SDSColor.blue50,
                                                                                borderRadius: BorderRadius.circular(4),
                                                                              ),
                                                                              child: Text(
                                                                                '${communityData.categorySub}',
                                                                                style: SDSTextStyle.regular.copyWith(
                                                                                    fontSize: 11,
                                                                                    color: SDSColor.snowliveBlue),
                                                                              ),
                                                                            ),
                                                                          ),
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
                                                (index == 5 || index == 2 || index == 6)
                                                    ? Padding(
                                                  padding: const EdgeInsets.only(left: 16),
                                                  child: Image.asset('assets/imgs/imgs/img_bulletin_thumbnail.png',
                                                    width: 50,
                                                    height: 50,),
                                                )
                                                    : Container()
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if(_communityBulletinListViewModel.communityList_total.length != index + 1)
                                    Divider(
                                      color: SDSColor.gray50,
                                      height: 16,
                                      thickness: 1,
                                    ),
                                ],
                              )),
                            );
                          },
                          padding: EdgeInsets.only(bottom: 90),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
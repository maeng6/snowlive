import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/ranking/v_rankingListBeta_crew.dart';
import 'package:com.snowlive/view/ranking/v_rankingListBeta_indiv.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList_beta.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:com.snowlive/widget/w_verticalDivider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RankingBetaView extends StatelessWidget {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final RankingListBetaViewModel _rankingListBetaViewModel = Get.find<RankingListBetaViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _statusBarSize = MediaQuery.of(context).padding.top;

    return Obx(()=>Container(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          children: [
            (_rankingListBetaViewModel.isLoadingBeta_crew==true
                && _rankingListBetaViewModel.isLoadingBeta_indiv==true)
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
                onRefresh: () async {
                  //리프레쉬처리
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      child: Column(
                        children: [
                          //필터
                          Container(
                            height: 60,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 16, bottom: 8),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Stack(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  _rankingListBetaViewModel.changeCrewOrIndiv('크루');
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.only(
                                                        right: 12, left: 12, top: 2, bottom: 2),
                                                    side: BorderSide(
                                                      width: 1,
                                                      color: (_rankingListBetaViewModel.crewOrIndiv=='크루') ? SDSColor.gray900 : SDSColor.gray100,
                                                    ),
                                                    backgroundColor: (_rankingListBetaViewModel.crewOrIndiv=='크루') ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(50))),
                                                child:
                                                Text('크루',
                                                    style: SDSTextStyle.bold.copyWith(
                                                        fontSize: 13,
                                                        color: (_rankingListBetaViewModel.crewOrIndiv=='크루') ? Color(0xFFFFFFFF) : Color(0xFF111111)))
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 16, bottom: 8),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Stack(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  _rankingListBetaViewModel.changeCrewOrIndiv('개인');
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.only(
                                                        right: 12, left: 12, top: 2, bottom: 2),
                                                    side: BorderSide(
                                                      width: 1,
                                                      color: (_rankingListBetaViewModel.crewOrIndiv=='개인') ? SDSColor.gray900 : SDSColor.gray100,
                                                    ),
                                                    backgroundColor: (_rankingListBetaViewModel.crewOrIndiv=='개인') ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(50))),
                                                child:
                                                Text('개인',
                                                    style: SDSTextStyle.bold.copyWith(
                                                        fontSize: 13,
                                                        color: (_rankingListBetaViewModel.crewOrIndiv=='개인') ? Color(0xFFFFFFFF) : Color(0xFF111111)))
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
                          SizedBox(height: 16),


                          (_rankingListBetaViewModel.crewOrIndiv == '크루' )
                              ? RankingListBetaCrew()
                              : RankingListBetaIndiv()
                        ],
                      ),
                    ),
                  ),
                )

            )
          ],
        ),
      ),
    ));
  }
}

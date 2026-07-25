import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/view/friend/history/v_rankingIndiv_history.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RankingIndivHistoryHomeView extends StatelessWidget {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  final RankingListViewModel _rankingListViewModel = Get.find<RankingListViewModel>();

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 상태바 투명하게
      statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 밝기
    ));

    return Scaffold(

      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26),
            highlightColor: Colors.transparent,
          ),
        ),
          title: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              children: [
                Text(
                  '개인 시즌 기록실',
                  style: SDSTextStyle.extraBold.copyWith(
                      color: SDSColor.gray900,
                      fontSize: 18),
                ),
              ],
            ),
          ),
          centerTitle: true,
          titleSpacing: 0,
          backgroundColor: SDSColor.snowliveWhite,
          foregroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: RankingIndivHistoryView()),
          ],
        ),
      ),
    );
  }
}



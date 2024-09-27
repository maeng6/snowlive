import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewNotice.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewRecordRoom.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:com.snowlive/widget/w_verticalDivider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CrewHomeView extends StatelessWidget {
  CrewHomeView({Key? key}) : super(key: key);

  // 뷰모델 선언
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final CrewRecordRoomViewModel _crewRecordRoomViewModel = Get.find<CrewRecordRoomViewModel>();
  final CrewApplyViewModel _crewApplyViewModel = Get.find<CrewApplyViewModel>();
  final CrewNoticeViewModel _crewNoticeViewModel = Get.find<CrewNoticeViewModel>();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
      extendBodyBehindAppBar: true,
      body: Obx(() => Stack(
        children: [
          Container(
            width: _size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  if(_crewNoticeViewModel.noticeList.isNotEmpty
                      && _userViewModel.user.crew_id == _crewDetailViewModel.crewDetailInfo.crewId)
                    GestureDetector(
                      onTap: () async{
                        Get.toNamed(AppRoutes.crewNoticeList);
                        await _crewNoticeViewModel.fetchCrewNotices();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ExtendedImage.asset(
                                  'assets/imgs/icons/icon_liveCrew_notice.png',
                                  width: 22,
                                  height: 22,
                                ),
                                SizedBox(width: 4),
                                Container(
                                  width: _size.width - 70,
                                  child: Text(
                                    _crewNoticeViewModel.noticeList.first.notice!,
                                    style: SDSTextStyle.regular.copyWith(
                                        fontSize: 14,
                                        color: SDSColor.gray900,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: Color(int.parse(_crewDetailViewModel.color.replaceFirst('0X', ''), radix: 16)),
                        padding: const EdgeInsets.only(top: 20, bottom: 20, left: 24, right: 24),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (_crewDetailViewModel.crewLogoUrl.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                spreadRadius: 0,
                                                blurRadius: 16,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          width: 48,
                                          height: 48,
                                          child: ExtendedImage.network(
                                            _crewDetailViewModel.crewLogoUrl,
                                            enableMemoryCache: true,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(10),
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    else
                                      GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                spreadRadius: 0,
                                                blurRadius: 16,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          width: 48,
                                          height: 48,
                                          child: ExtendedImage.network(
                                            '${crewDefaultLogoUrl['${_crewDetailViewModel.color}']}',
                                            enableMemoryCache: true,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(10),
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          ),

                                        ),
                                      ),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _crewDetailViewModel.crewName,
                                          style: SDSTextStyle.bold.copyWith(
                                            fontSize: 16,
                                            color: SDSColor.snowliveWhite,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${_crewMemberListViewModel.crewLeaderName} • ${_crewDetailViewModel.resortName}',
                                              style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 13,
                                                  color: SDSColor.snowliveWhite),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Expanded(child: SizedBox()),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${_crewMemberListViewModel.totalMemberCount}',
                                            style: GoogleFonts.bebasNeue(
                                              color: SDSColor.snowliveWhite,
                                              fontSize: 36,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' 명',
                                            style: GoogleFonts.bebasNeue(
                                              color: SDSColor.snowliveWhite.withOpacity(0.6),
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (_crewDetailViewModel.description.isNotEmpty)
                                  Column(
                                    children: [
                                      Divider(
                                        color: SDSColor.snowliveBlack.withOpacity(0.1),
                                        thickness: 1.0,
                                        height: 40,
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          _crewDetailViewModel.toggleExpandCrewIntro();
                                        },
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: _size.width - 110,
                                              child:
                                              (_crewDetailViewModel.isCrewIntroExpanded == false)
                                              ? Text(
                                                _crewDetailViewModel.description,
                                                style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 14,
                                                  color: SDSColor.snowliveWhite,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              )
                                                  : Text(
                                                _crewDetailViewModel.description,
                                                style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 14,
                                                  color: SDSColor.snowliveWhite,
                                                ),
                                              )
                                            ),
                                            (_crewDetailViewModel.isCrewIntroExpanded == false)
                                            ? ExtendedImage.asset(
                                              'assets/imgs/icons/icon_plus_round.png',
                                              width: 20,
                                              height: 20,
                                            )
                                            : ExtendedImage.asset(
                                              'assets/imgs/icons/icon_minus_round.png',
                                              width: 20,
                                              height: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 16, right: 16),
                  //   child: Row(
                  //     children: [
                  //       Text(
                  //         '라이브ON ${_crewMemberListViewModel.liveMemberCount}명',
                  //         style: TextStyle(
                  //           fontSize: 16,
                  //           color: Color(0xFF111111),
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      children: [
                        Text(
                          '크루 라이딩 통계',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 15,
                            color: SDSColor.gray900,
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        TextButton(
                          onPressed: () async{
                            Get.toNamed(AppRoutes.crewRecordRoom);
                            await _crewRecordRoomViewModel.fetchCrewRidingRecords(
                                _crewDetailViewModel.crewDetailInfo.crewId!,
                                '${DateTime.now().year}'
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            minimumSize: Size(36, 32),
                            backgroundColor: SDSColor.snowliveWhite,
                            side: BorderSide(
                                color: SDSColor.gray200
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          ),
                          child: Text(
                            '기록실',
                            style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),

                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: _size.width - 32,
                          height: 76,
                          decoration: BoxDecoration(
                            color: SDSColor.gray50, // 선택된 옵션의 배경을 흰색으로 설정
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${_crewDetailViewModel.overallRank}',
                                      style: SDSTextStyle.bold.copyWith(
                                          fontSize: 18,
                                        color: SDSColor.gray900
                                      ),
                                    ),
                                    Text(
                                      '통합 랭킹',
                                      style: SDSTextStyle.regular.copyWith(
                                        color: SDSColor.gray900.withOpacity(0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              buildVerticalDivider_ranking_indi_Screen(),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${_crewDetailViewModel.overallTotalScore.toStringAsFixed(0)}',
                                      style: SDSTextStyle.bold.copyWith(
                                          fontSize: 18,
                                          color: SDSColor.gray900
                                      ),
                                    ),
                                    Text(
                                      '총 점수',
                                      style: SDSTextStyle.regular.copyWith(
                                        color: SDSColor.gray900.withOpacity(0.5),
                                        fontSize: 13,
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
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Container(
                      padding: const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: SDSColor.blue50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 슬로프별, 시간대별 버튼
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFD2DFF4).withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          _crewDetailViewModel.toggleGraph();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _crewDetailViewModel.isSlopeGraph.value
                                                ? SDSColor.snowliveWhite
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '슬로프별',
                                            style: SDSTextStyle.regular.copyWith(
                                              color: _crewDetailViewModel.isSlopeGraph.value
                                                  ? SDSColor.gray900
                                                  : Color(0xFF809FCF).withOpacity(0.8),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          _crewDetailViewModel.toggleGraph();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: !_crewDetailViewModel.isSlopeGraph.value
                                                ? SDSColor.snowliveWhite
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '시간대별',
                                            style: SDSTextStyle.regular.copyWith(
                                              color: !_crewDetailViewModel.isSlopeGraph.value
                                                  ? SDSColor.gray900
                                                  : Color(0xFF809FCF).withOpacity(0.8),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                '총 라이딩 횟수',
                                style: SDSTextStyle.regular.copyWith(
                                    color: SDSColor.gray900.withOpacity(0.5),
                                    fontSize: 14
                                ),
                              ),
                              Text(
                                '${_crewDetailViewModel.totalSlopeCount}',
                                style: SDSTextStyle.extraBold.copyWith(
                                    color: SDSColor.gray900,
                                    fontSize: 30
                                ),
                              ),
                              SizedBox(height: 10),
                              if (_crewDetailViewModel.totalSlopeCount == 0)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 30),
                                    child: Column(
                                      children: [
                                        ExtendedImage.asset(
                                          'assets/imgs/imgs/img_resoreHome_nodata.png',
                                          fit: BoxFit.cover,
                                          width: 72,
                                          height: 72,
                                        ),
                                        Text(
                                          '라이딩 기록이 없어요',
                                          style: SDSTextStyle.regular.copyWith(
                                            fontSize: 14,
                                            color: SDSColor.gray600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Obx(() => _crewDetailViewModel.isSlopeGraph.value
                                    ? Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _crewDetailViewModel.countInfo.map<Widget>((slopeData) {
                                      String slopeName = slopeData.slope ?? '';
                                      int passCount = slopeData.count ?? 0;

                                      double barWidthRatio = (passCount / (_crewDetailViewModel.countInfo.map((e) => e.count ?? 0).reduce((a, b) => a > b ? a : b)));

                                      return Padding(
                                        padding: (slopeData != _crewDetailViewModel.countInfo.last)
                                            ? EdgeInsets.only(bottom: 8, top: 4)
                                            : EdgeInsets.only(bottom: 0, top: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              child: Text(
                                                slopeName,
                                                style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 11,
                                                  color: SDSColor.sBlue600,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 14,
                                              width: (_size.width - 166) * barWidthRatio,
                                              decoration: BoxDecoration(
                                                color: (slopeData == _crewDetailViewModel.countInfo.first)
                                                    ? SDSColor.snowliveBlue
                                                    : SDSColor.blue200,
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(4),
                                                  bottomRight: Radius.circular(4),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: (slopeData == _crewDetailViewModel.countInfo.first)
                                                  ? EdgeInsets.only(left: 6)
                                                  : EdgeInsets.only(left: 2),
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        color: (slopeData == _crewDetailViewModel.countInfo.first)
                                                            ? SDSColor.gray900
                                                            : Colors.transparent,
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      child: Text(
                                                        '$passCount',
                                                        style: SDSTextStyle.extraBold.copyWith(
                                                          fontSize: 12,
                                                          fontWeight: (slopeData == _crewDetailViewModel.countInfo.first)
                                                              ? FontWeight.w900
                                                              : FontWeight.w300,
                                                          color: (slopeData == _crewDetailViewModel.countInfo.first)
                                                              ? SDSColor.snowliveWhite
                                                              : SDSColor.gray900
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                                    : Container(
                                  child: _crewDetailViewModel.seasonRankingInfo.timeCountInfo != null
                                      ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: _crewDetailViewModel.seasonRankingInfo.timeCountInfo!.entries.map<Widget>((entry) {
                                      String slotName = entry.key; // 시간대 이름 (ex: "00-08", "08-10")
                                      int passCount = entry.value; // 시간대별 횟수
                                      int maxCount = _crewDetailViewModel.seasonRankingInfo.timeCountInfo!.values.reduce((a, b) => a > b ? a : b); // 최대 값 계산
                                      double barHeightRatio = passCount / maxCount; // 비율 계산

                                      return Container(
                                        width: 30,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            // 횟수가 0이 아닐 때만 표시
                                            AutoSizeText(
                                              passCount != 0 ? '$passCount' : '',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 12,
                                                color: SDSColor.gray900,
                                              ),
                                              minFontSize: 6,
                                              maxLines: 1,
                                              overflow: TextOverflow.visible,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 4),
                                              child: Container(
                                                width: 16,
                                                height: 140 * barHeightRatio,
                                                decoration: BoxDecoration(
                                                    color: SDSColor.blue200,
                                                    borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(4), topLeft: Radius.circular(4)
                                                    )
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Container(
                                                width: 20,
                                                child: Text(
                                                  slotName, // 시간대 텍스트
                                                  style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 11,
                                                      color: SDSColor.sBlue600,
                                                      height: 1.2
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )
                                      : Center(child: Text('No data available')), // null일 때 표시할 기본 값
                                ),
                                ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  (_userViewModel.user.crew_id == null)
                  ? SizedBox(height: 100)
                  : SizedBox(height: 50),
                ],
              ),
            ),
          ),
          if(_userViewModel.user.crew_id == null)
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: SafeArea(
                child: Container(
                  color: SDSColor.snowliveWhite,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return WillPopScope(
                            onWillPop: () async{
                              _crewApplyViewModel.textEditingController_crewHome.clear(); // 텍스트 클리어
                              _crewApplyViewModel.isSubmitButtonEnabled_crewHome.value = false;
                              return true;
                            },
                            child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    title: Text('해당 크루에\n가입 신청을 하시겠어요?',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Obx(()=>
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                              controller: _crewApplyViewModel.textEditingController_crewHome,
                                              onChanged: (value) {
                                                _crewApplyViewModel.isSubmitButtonEnabled_crewHome.value = value.isNotEmpty; // 입력 여부에 따라 버튼 활성화 여부 결정
                                              },
                                              decoration: InputDecoration(
                                                hintText: '인사말을 남겨주세요.',
                                                hintStyle: TextStyle(color: SDSColor.gray500),
                                                filled: true,
                                                fillColor: SDSColor.gray100,
                                                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                              maxLength: 50, // 최대 100자 제한
                                            ),
                                            SizedBox(height: 30),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      _crewApplyViewModel.textEditingController_crewHome.clear();
                                                      _crewApplyViewModel.isSubmitButtonEnabled_crewHome.value = false;
                                                      Navigator.pop(context); // 팝업 닫기
                                                    },
                                                    child: Text(
                                                      '돌아가기',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                      ),
                                                      elevation: 0,
                                                      splashFactory: InkRipple.splashFactory,
                                                      backgroundColor: Color(0xff7C899D),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: _crewApplyViewModel.isSubmitButtonEnabled_crewHome.value
                                                        ? () async {
                                                      Navigator.pop(context);
                                                      CustomFullScreenDialog.showDialog();
                                                      await _crewApplyViewModel.applyForCrew(
                                                        _crewDetailViewModel.crewDetailInfo.crewId!,
                                                        _userViewModel.user.user_id,
                                                        _crewApplyViewModel.textEditingController_crewHome.text,
                                                      );
                                                      _crewApplyViewModel.textEditingController_crewHome.clear();
                                                      _crewApplyViewModel.isSubmitButtonEnabled_crewHome.value = false;
                                                    }
                                                        : null, // 버튼 비활성화 시 null
                                                    child: Text(
                                                      '신청하기',
                                                      style: TextStyle(
                                                        color: SDSColor.snowliveWhite,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                      ),
                                                      elevation: 0,
                                                      backgroundColor: _crewApplyViewModel.isSubmitButtonEnabled_crewHome.value
                                                          ? SDSColor.snowliveBlue // 입력이 있을 때 버튼 활성화
                                                          : SDSColor.gray300, // 입력이 없을 때 버튼 비활성화
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),)
                                );
                              },
                            ),
                          );
                        },
                      );

                    },
                    child: Text(
                      '가입 신청하기',
                      style: SDSTextStyle.bold.copyWith(
                          color: SDSColor.snowliveWhite, fontSize: 16),
                    ),
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      elevation: 0,
                      splashFactory: InkRipple.splashFactory,
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: SDSColor.snowliveBlue,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

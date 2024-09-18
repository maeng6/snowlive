import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_crewDetail.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewTodayPage.dart';
import 'package:com.snowlive/viewmodel/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/vm_crewRecordRoom.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.snowlive/screens/common/v_profileImageScreen.dart';
import '../../widget/w_verticalDivider.dart';

class CrewHomeView extends StatelessWidget {
  CrewHomeView({Key? key}) : super(key: key);

  // 뷰모델 선언
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final CrewRecordRoomViewModel _crewRecordRoomViewModel = Get.find<CrewRecordRoomViewModel>();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      extendBodyBehindAppBar: true,
      body: Obx(() => Container(
          width: _size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                if(_crewDetailViewModel.notice.isNotEmpty)
                GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ExtendedImage.asset(
                              'assets/imgs/icons/icon_liveCrew_notice.png',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _crewDetailViewModel.notice,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF111111)),
                            ),
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
                      color: Color(int.parse(_crewDetailViewModel.color, radix: 16) + 0xFF000000),
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 24, right: 24),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          width: 56,
                                          height: 56,
                                          child: ExtendedImage.network(
                                            _crewDetailViewModel.crewLogoUrl,
                                            enableMemoryCache: true,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(10),
                                            width: 56,
                                            height: 56,
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
                                          width: 56,
                                          height: 56,
                                          child: Image.asset(
                                            'assets/imgs/liveCrew/img_liveCrew_logo_setCrewImage.png',
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _crewDetailViewModel.crewName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              _userViewModel.user.display_name,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF5DDEBF)),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(width: 5),
                                            const Text(
                                              '•', // 점 추가
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF5DDEBF),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              _crewDetailViewModel.resortName,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF5DDEBF)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Expanded(child: SizedBox()),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${_crewDetailViewModel.crewMemberTotal}',
                                            style: GoogleFonts.bebasNeue(
                                              color: const Color(0xFFFFFFFF),
                                              fontSize: 35,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' 명',
                                            style: GoogleFonts.bebasNeue(
                                              color: const Color(0xFF5DDEBF),
                                              fontSize: 12, // 숫자보다 작은 폰트 크기
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
                                        color: const Color(0xFF111111).withOpacity(0.2),
                                        thickness: 1.0,
                                        height: 30,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4), // 텍스트와 박스 간의 간격 설정
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF000000).withOpacity(0.2), // 배경 색상과 투명도 설정
                                              borderRadius: BorderRadius.circular(8), // 모서리 둥글게 설정
                                            ),
                                            child: const Text(
                                              '크루소개',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            _crewDetailViewModel.description,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF111111),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    children: [
                      Text(
                        '라이브ON ${_crewMemberListViewModel.liveMemberCount}명',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      OutlinedButton(
                        onPressed: () async{
                          Get.toNamed(AppRoutes.crewRecordRoom);
                          await _crewRecordRoomViewModel.fetchCrewRidingRecords(
                              _crewDetailViewModel.crewDetailInfo.crewId!,
                              '${DateTime.now().year}'
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: SDSColor.snowliveWhite,
                          side: BorderSide(color: SDSColor.gray300), // 회색 테두리
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5), // 모서리를 둥글게 설정
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          minimumSize: const Size(0, 0),
                        ),
                        child: Text(
                          '기록실',
                          style: TextStyle(
                            color: SDSColor.snowliveBlack, // 텍스트 색상
                            fontSize: 13, // 텍스트 크기
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  width: _size.width,
                  height: 10,
                  color: SDSColor.gray50,
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    '크루 라이딩 통계',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      '통합 랭킹',
                                      style: SDSTextStyle.regular.copyWith(
                                        color: const Color(0xFF111111).withOpacity(0.5),
                                        fontSize: 13,
                                      ),
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
                                    '${_crewDetailViewModel.overallTotalScore}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      '총 점수',
                                      style: SDSTextStyle.regular.copyWith(
                                        color: const Color(0xFF111111).withOpacity(0.5),
                                        fontSize: 13,
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
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Container(
                    padding: const EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
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
                            Text(
                              '총 라이딩 횟수',
                              style: SDSTextStyle.regular.copyWith(
                                color: SDSColor.snowliveBlack,
                                fontSize: 14,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 10),
                              child: Text(
                                '${_crewDetailViewModel.totalSlopeCount}회',
                                style: SDSTextStyle.extraBold.copyWith(
                                  color: SDSColor.snowliveBlack,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            Divider(
                              color: Color(0xFFCBE0FF),
                              thickness: 1,
                            ),
                            SizedBox(height: 10),
                            Text(
                              '라이딩 횟수',
                              style: SDSTextStyle.regular.copyWith(
                                  color: SDSColor.snowliveBlack,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
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
                                          ? EdgeInsets.only(bottom: 8, top: 10)
                                          : EdgeInsets.only(bottom: 0, top: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            child: Text(
                                              slopeName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.black, // 텍스트 색상 지정
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 16,
                                            width: (_size.width - 152) * barWidthRatio,
                                            decoration: BoxDecoration(
                                              color: (slopeData == _crewDetailViewModel.countInfo.first)
                                                  ? Colors.blue // 첫 번째 막대의 색상
                                                  : Colors.blueAccent, // 다른 막대들의 색상
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
                                              width: 30,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      color: (slopeData == _crewDetailViewModel.countInfo.first)
                                                          ? Colors.black // 첫 번째 데이터의 배경 색
                                                          : Colors.transparent,
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                    child: Text(
                                                      '$passCount',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: (slopeData == _crewDetailViewModel.countInfo.first)
                                                            ? FontWeight.w900
                                                            : FontWeight.w300,
                                                        color: (slopeData == _crewDetailViewModel.countInfo.first)
                                                            ? Colors.white
                                                            : Colors.black.withOpacity(0.4),
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
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: passCount == maxCount ? SDSColor.snowliveBlack : SDSColor.gray500,
                                              fontWeight: passCount == maxCount ? FontWeight.bold : FontWeight.w300, // 가장 높은 값은 볼드체
                                            ),
                                            minFontSize: 6,
                                            maxLines: 1,
                                            overflow: TextOverflow.visible,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: passCount == maxCount ? 6 : 0),
                                            child: Container(
                                              width: 16,
                                              height: 140 * barHeightRatio, // 막대 높이를 비율에 따라 설정
                                              decoration: BoxDecoration(
                                                color: passCount == maxCount ? SDSColor.blue500 : SDSColor.blue200, // 가장 높은 값은 다른 색상
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(4),
                                                  topLeft: Radius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Container(
                                              width: 20,
                                              child: Text(
                                                slotName, // 시간대 텍스트
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black,
                                                  height: 1.2,
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
                        SizedBox(height: 20),
                        //TODO: 슬로프별, 시간대별 버튼
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD2DFF4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
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
                                            : SDSColor.gray600,
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
                                            : SDSColor.gray600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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

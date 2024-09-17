import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_crewDetail.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewTodayPage.dart';
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
                              '크루공지사항입니다요',
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
                                if (_crewDetailViewModel.description != '')
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
                      const Text(
                        '라이브ON 11',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      OutlinedButton(
                        onPressed: () {
                          Get.to(() => CrewTodayPage());
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
                        child: const Text(
                          '오늘의 현황',
                          style: TextStyle(
                            color: SDSColor.snowliveBlack, // 텍스트 색상
                            fontSize: 13, // 텍스트 크기
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: _size.width,
                  height: 10,
                  color: SDSColor.gray50,
                ),
                const SizedBox(height: 30),
                const Padding(
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
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
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
                                //TODO: 슬로프별 그래프
                                  child: Column(
                                    children: _crewDetailViewModel.countInfo.map((slopeData) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          children: [
                                            Text(slopeData.slope ?? '', style: TextStyle(fontSize: 14)),
                                            SizedBox(width: 8),
                                            Text('${slopeData.count ?? 0}회', style: TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),)
                                    : Container(
                                //TODO: 시간대별 그래프
                              child: Column(
                                    children: _crewDetailViewModel.timeInfo.map((timeData) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          children: [
                                            Text('시간대 $timeData', style: TextStyle(fontSize: 14)),
                                            SizedBox(width: 8),
                                            Text('${timeData}회', style: TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
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

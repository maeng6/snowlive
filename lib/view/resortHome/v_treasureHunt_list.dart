import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_treasure_record.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TreasureHuntMyPageView extends StatelessWidget {
  final ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  TreasureHuntMyPageView({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('내가 찾은 보물',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
          ),
        ),
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () {
            Get.back();
          },
        ),
        titleSpacing: 0,
        backgroundColor: SDSColor.snowliveWhite,
        foregroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Obx(() {
        if (_resortHomeViewModel.isLoadingTreasureRecords.value) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: Container(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  backgroundColor: SDSColor.gray100,
                  color: SDSColor.gray300.withOpacity(0.6),
                ),
              ),
            ),
          );
        }

        if (_resortHomeViewModel.treasureRecordList.isEmpty) {
          return Transform.translate(
            offset: Offset(0, -40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/icons/icon_nodata_treasure.png',
                    scale: 4,
                    width: 73,
                    height: 73,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text('찾은 보물이 아직 없어요',
                    style: SDSTextStyle.regular.copyWith(
                        fontSize: 14,
                        color: SDSColor.gray600
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: _resortHomeViewModel.treasureRecordList.length,
          itemBuilder: (context, index) {
            final record = _resortHomeViewModel.treasureRecordList[index];
            final received = !record.active; // active가 false면 '수령완료'

            return ListTile(
              leading: ExtendedImage.asset(
                'assets/imgs/icons/icon_treasure_gold.png',
                        width: 32,
                        fit: BoxFit.cover,
                      ),
              title: Text(
                record.prize,
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 15,
                  color: SDSColor.snowliveBlack,
                ),
              ),
              subtitle: Text(
                '${record.passTime.year}.${record.passTime.month}.${record.passTime.day} ${record.passTime.hour}:${record.passTime.minute}:${record.passTime.second}',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: SDSColor.gray500
                  ),
              ),
              trailing: received
                  ? Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: SDSColor.snowliveBlack,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  '수령완료',
                  style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.snowliveWhite),
                )
              )
                  : GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return
                      AlertDialog(
                        backgroundColor: SDSColor.snowliveWhite,
                        contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        buttonPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                        content:
                        Container(
                          width: 288,
                          height: 154,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/imgs/icons/icon_treasure_gold.png',
                                width: 60,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20, bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${record.prize} 수령하기',
                                      style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '경품 수령처로 이동하여 스태프에게 화면을 보여주고 경품을 수령하세요!',
                                style: SDSTextStyle.regular.copyWith(fontSize: 14, height: 1.4, color: SDSColor.gray600),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: _size.width,
                                  height: 48,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: SDSColor.snowliveBlack
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await _resortHomeViewModel.updateTreasureRecord(
                                        treasureRecordId: record.treasureRecordId,
                                        active: false, // 수령 완료로 상태 변경
                                        userId: _userViewModel.user.user_id,
                                      );
                                      await _resortHomeViewModel.fetchTreasureRecords(
                                        userId: _userViewModel.user.user_id,
                                      );
                                    },
                                    child: Text(
                                      '수령하기(스태프용)',
                                      style: SDSTextStyle.bold.copyWith(
                                        fontSize: 16,
                                        color: SDSColor.snowliveWhite,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Container(
                                    width: _size.width,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: SDSColor.snowliveWhite
                                    ),
                                    child: TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text(
                                        '돌아가기',
                                        style: SDSTextStyle.bold.copyWith(
                                          fontSize: 16,
                                          color: SDSColor.gray900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                          ),
                        ],
                      );
                  },
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: SDSColor.gray200
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    '수령확인',
                    style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

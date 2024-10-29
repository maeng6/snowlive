import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_treasure_record.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TreasureHuntMyPageView extends StatelessWidget {
  final ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  TreasureHuntMyPageView({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          return Center(child: CircularProgressIndicator());
        }

        if (_resortHomeViewModel.treasureRecordList.isEmpty) {
          return Center(child: Text('No treasures found'));
        }

        return ListView.builder(
          itemCount: _resortHomeViewModel.treasureRecordList.length,
          itemBuilder: (context, index) {
            final record = _resortHomeViewModel.treasureRecordList[index];
            final received = !record.active; // active가 false면 '수령완료'

            return ListTile(
              title: Text(
                record.prize,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                '${record.passTime.year}-${record.passTime.month}-${record.passTime.day} ${record.passTime.hour}:${record.passTime.minute}:${record.passTime.second}',
              ),
              trailing: received
                  ? Text(
                '수령완료',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )
                  : GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('${record.prize} 수령하기'),
                      content: Text('경품 수령처로 이동하여\n스태프에게 화면을 보여주고\n경품을 수령하세요!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('돌아가기'),
                        ),
                        TextButton(
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
                          child: Text('수령완료(스태프용)'),
                        ),
                      ],
                    );
                  },
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '수령확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}


import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendBlockListView extends StatelessWidget {

  final FriendListViewModel _friendListViewModel = Get.find<FriendListViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        toolbarHeight: 44,
      ),
      body: Obx(() {
        return _friendListViewModel.blockUserList.isEmpty
            ? Center(
          child: Transform.translate(
            offset: Offset(0, -40),
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
                Text('차단목록이 비어있습니다',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF949494)
                  ),
                ),
              ],
            ),
          ),
        )
            : ListView.builder(
          itemCount: _friendListViewModel.blockUserList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              minVerticalPadding: 20,
              title: Text(
                _friendListViewModel.blockUserList[index].blockUserInfo.displayName,
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 15,
                  color: SDSColor.gray900,
                ),
              ),
              trailing:
              ElevatedButton(
                onPressed: () {

                  Get.dialog(
                      AlertDialog(
                        backgroundColor: SDSColor.snowliveWhite,
                        contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        content: Container(
                          height: 40,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '차단을 해제하시겠어요?',
                                textAlign: TextAlign.center,
                                style: SDSTextStyle.bold.copyWith(
                                    color: SDSColor.gray900,
                                    fontSize: 16
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          Padding(
                            padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent, // 배경색 투명
                                          splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                        ),
                                        child: Text('취소',
                                          style: SDSTextStyle.bold.copyWith(
                                            fontSize: 17,
                                            color: SDSColor.gray500,
                                          ),
                                        )
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(
                                    child: TextButton(
                                        onPressed: () async {

                                          Navigator.pop(context);
                                          CustomFullScreenDialog.showDialog();
                                          await _friendDetailViewModel.unblockUser(
                                              {
                                                "user_id": _userViewModel.user.user_id,    //필수 - 차단을 해제하는 사람(나)
                                                "block_user_id": _friendListViewModel.blockUserList[index].blockUserInfo.userId   //필수 - 해제 당하는 사람
                                              }
                                          );
                                          await _friendListViewModel.fetchBlockUserList();
                                          CustomFullScreenDialog.cancelDialog();

                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent, // 배경색 투명
                                          splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                        ),
                                        child: Text('해제하기',
                                          style: SDSTextStyle.bold.copyWith(
                                            fontSize: 17,
                                            color: SDSColor.red,
                                          ),
                                        )),
                                  ),
                                )
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                          )
                        ],
                      )
                  );

                },
                child: Text('차단해제',
                  style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                  minimumSize: Size(36, 32),
                  backgroundColor: SDSColor.snowliveWhite,
                  side: BorderSide(
                      color: SDSColor.gray200
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),),
            );
          },
        );
      }),
    );
  }
}


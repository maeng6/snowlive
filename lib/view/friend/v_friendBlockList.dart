
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF111111),
                ),
              ),
              trailing:
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          color: Colors.white,
                          height: 180,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  '차단을 해제하시겠습니까?',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111111)),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          '취소',
                                          style: TextStyle(
                                              color: Color(0xFF3D83ED),
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                        style: TextButton.styleFrom(
                                            splashFactory: InkRipple
                                                .splashFactory,
                                            elevation: 0,
                                            minimumSize:
                                            Size(100, 56),
                                            backgroundColor:
                                            Color(0xFF3D83ED).withOpacity(0.2),
                                            padding:
                                            EdgeInsets.symmetric(
                                                horizontal: 0)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _friendDetailViewModel.unblockUser(
                                              {
                                                "user_id": _userViewModel.user.user_id,    //필수 - 차단을 해제하는 사람(나)
                                                "block_user_id": _friendListViewModel.blockUserList[index].blockUserInfo.userId   //필수 - 해제 당하는 사람
                                              }
                                          );
                                          await _friendListViewModel.fetchBlockUserList();
                                        },
                                        child: Text(
                                          '확인',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                        style: TextButton.styleFrom(
                                            splashFactory: InkRipple
                                                .splashFactory,
                                            elevation: 0,
                                            minimumSize:
                                            Size(100, 56),
                                            backgroundColor:
                                            Color(0xFF3D83ED),
                                            padding:
                                            EdgeInsets.symmetric(
                                                horizontal: 0)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: Text('차단해제',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF949494)),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(
                        color: Color(0xFFDEDEDE)
                    )
                ),
              ),
            );
          },
        );
      }),
    );
  }
}


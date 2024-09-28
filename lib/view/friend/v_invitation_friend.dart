import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/view/friend/v_invitation_receive_friend.dart';
import 'package:com.snowlive/view/friend/v_invitation_send_friend.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class InvitationFriendView extends StatefulWidget {
  InvitationFriendView({Key? key}) : super(key: key);

  @override
  State<InvitationFriendView> createState() => _InvitationFriendViewState();
}

class _InvitationFriendViewState extends State<InvitationFriendView> {
  int counter = 0;
  List<bool> isTap = [
    true,
    false,
  ];

  FriendListViewModel _friendListViewModel = Get.find<FriendListViewModel>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              _friendListViewModel.fetchFriendList();
              Get.back();
            },
          ),
          centerTitle: true,
          titleSpacing: 0,
          title: Text(
            '친구추가',
            style: SDSTextStyle.extraBold.copyWith(
                color: SDSColor.gray900,
                fontSize: 18),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      body:
      SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 44,
              child: Container(
                width: _size.width,
                height: 1,
                color: SDSColor.gray100,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: RefreshIndicator(
                strokeWidth: 2,
                edgeOffset: 20,
                backgroundColor: SDSColor.snowliveWhite,
                color: SDSColor.snowliveBlue,
                onRefresh: () async{
                  await _friendListViewModel.fetchFriendRequestList(
                      _userViewModel.user.user_id
                  );
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                width: (_size.width - 40) / 2 ,
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '받은 요청',
                                    style: TextStyle(
                                        color: (isTap[0])
                                            ? SDSColor.gray900
                                            : SDSColor.gray900.withOpacity(0.2),
                                        fontWeight: (isTap[0])
                                            ? FontWeight.bold
                                        : FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  onPressed: () async{
                                    HapticFeedback.lightImpact();
                                    print('요청받은 목록으로 전환');
                                    setState(() {
                                      isTap[0] = true;
                                      isTap[1] = false;
                                    });
                                    print(isTap);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: SDSColor.snowliveWhite,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    overlayColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: 3,
                              color:
                              (isTap[0]) ? Color(0xFF111111) : Colors.transparent,
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                width: (_size.width - 40) / 2 ,
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '보낸 요청',
                                    style: TextStyle(
                                        color: (isTap[1])
                                            ? SDSColor.gray900
                                            : SDSColor.gray900.withOpacity(0.2),
                                        fontWeight:
                                        (isTap[1])
                                            ? FontWeight.bold
                                        : FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    print('요청중인 목록으로 전환');
                                    setState(() {
                                      isTap[0] = false;
                                      isTap[1] = true;
                                    });
                                    print(isTap);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    splashFactory: NoSplash.splashFactory,
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: SDSColor.snowliveWhite,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    overlayColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: 3,
                              color:
                              (isTap[1]) ? Color(0xFF111111) : Colors.transparent,
                            )
                          ],
                        ),
                      ],
                    ),
                    if(isTap[0]==true)
                      Expanded(child: ReceiveFriendRequestView()),
                    if(isTap[1]==true)
                      Expanded(child: SendFriendRequestView()),
                  ],
                ),
              ),
            ),
          ],
        ),
      )


    );
  }
}


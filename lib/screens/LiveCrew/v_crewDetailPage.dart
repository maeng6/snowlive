import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snowlive3/controller/vm_DialogController_resortHome.dart';
import 'package:snowlive3/controller/vm_friendsCommentController.dart';
import 'package:snowlive3/screens/LiveCrew/v_setting_crewDetail.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../widget/w_fullScreenDialog.dart';

class CrewDetailPage extends StatefulWidget {
  CrewDetailPage({Key? key, required this.crewID,}) : super(key: key);

  String? crewID;

  @override
  State<CrewDetailPage> createState() => _CrewDetailPageState();
}

class _CrewDetailPageState extends State<CrewDetailPage> {

  var _stream;
  final _formKeyProfile = GlobalKey<FormState>();
  final _formKeyProfile2 = GlobalKey<FormState>();
  final _formKeyProfile3 = GlobalKey<FormState>();
  final _stateMsgController = TextEditingController();
  final _displayNameController = TextEditingController();
  var _newComment = '';
  bool edit= false;
  String _initStateMsg='';
  String _initialDisplayName='';

  @override
  void initState() {
    _stream = newStream();
    // TODO: implement initState
    super.initState();
    _stateMsgController.text = '';
    _initStateMsg = _userModelController.stateMsg!;
    _initialDisplayName = _userModelController.displayName!;
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('liveCrew')
        .doc('${widget.crewID}')
        .collection('friendsComment')
        .snapshots();
  }

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            leading: GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(top: _statusBarSize - 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/imgs/icons/icon_snowLive_back.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                    ),
                  ],
                ),
              ),
              onTap: () {
                // Navigator.popUntil(context, (route) => route.isFirst);
                // Navigator.push(context, MaterialPageRoute(builder: (context) => FriendListPage()));
                Get.back();
              },
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: IconButton(
                  onPressed: (){
                    Get.to(()=>Setting_crewDetail(crewID: widget.crewID,));
                  },
                  icon: Image.asset(
                    'assets/imgs/icons/icon_settings.png',
                    scale: 4,
                    width: 26,
                    height: 26,
                  ),
                ),
              )
            ],
            elevation: 0.0,
            titleSpacing: 0,
            centerTitle: true,
            toolbarHeight: 58.0, // 이 부분은 AppBar의 높이를 조절합니다.
          ),
          body: StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewID', isEqualTo: widget.crewID )
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (!snapshot.hasData || snapshot.data == null) {}
      else if (snapshot.data!.docs.isNotEmpty) {
        final crewDocs = snapshot.data!.docs;
        final List memberUidList = crewDocs[0]['memberUidList'];
      return Padding(
        padding: EdgeInsets.only(top: _statusBarSize + 58),
        child: Stack(
          children: [
            Container(
              height: _size.height - 160,
              width: _size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFEEEEF5)
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.only(top: 30, bottom: 16),
                      child: Column(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                (crewDocs[0]['profileImageUrl'].isNotEmpty)
                                    ? GestureDetector(
                                  onTap: () {
                                    Get.to(() => ProfileImagePage(
                                        CommentProfileUrl: crewDocs[0]['profileImageUrl']));
                                  },
                                  child: Container(
                                      width: 100,
                                      height: 100,
                                      child: ExtendedImage.network(
                                        crewDocs[0]['profileImageUrl'],
                                        enableMemoryCache: true,
                                        shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(8),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )),
                                )
                                    : GestureDetector(
                                  onTap: () {
                                    Get.to(() => ProfileImagePage(
                                        CommentProfileUrl: ''));
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    child: ExtendedImage.asset(
                                      'assets/imgs/profile/img_profile_default_circle.png',
                                      enableMemoryCache: true,
                                      shape: BoxShape.circle,
                                      borderRadius: BorderRadius.circular(8),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '크루 이름 : ${crewDocs[0]['crewName']}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111111)
                                      ),),
                                  ],
                                ), //활동명//상태메시지
                                SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '크루 마스터 : ${crewDocs[0]['crewLeader']}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111111)
                                      ),),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 26),
                                  child: Text('크루 소개 : ${crewDocs[0]['description']}',
                                    style: TextStyle(fontSize: 14,
                                        color: Color(0xFF949494)),),
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
            ),
          ],
        ),
      );
      }
      else if (snapshot.connectionState == ConnectionState.waiting) {}
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    ),
        )
      );
  }
}

// if (!snapshot.hasData || snapshot.data == null) {}
// else if (snapshot.data!.docs.isNotEmpty) {
// Column(
// children: [
//
// ],
// );
// }
// else if (snapshot.connectionState == ConnectionState.waiting) {}
// return Center(
// child: CircularProgressIndicator(),
// );


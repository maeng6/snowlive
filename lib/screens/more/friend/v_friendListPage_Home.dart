import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/screens/more/friend/v_friendDetailPage.dart';
import '../../../controller/vm_userModelController.dart';

class FriendListPage_Home extends StatefulWidget {
  const FriendListPage_Home({Key? key}) : super(key: key);

  @override
  State<FriendListPage_Home> createState() => _FriendListPage_HomeState();
}

class _FriendListPage_HomeState extends State<FriendListPage_Home> {

  var _friendStream;

  @override
  void initState() {
    // TODO: implement initState
    _friendStream = friendStream();

  }

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************


  Stream<QuerySnapshot> friendStream() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('whoResistMe', arrayContains: _userModelController.uid!)
        .orderBy('displayName', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _friendStream,
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: Colors.white,
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final friendDocs = snapshot.data!.docs;
          Size _size = MediaQuery.of(context).size;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (friendDocs.isEmpty)
                  ? SizedBox.shrink()
                  : Container(
                color: Color(0xFFF1F1F3),
                height: 100,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('user')
                          .where('whoResistMeBF', arrayContains: _userModelController.uid!)
                          .orderBy('isOnLive', descending: true)
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>snapshot) {
                        try {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return SizedBox.shrink();
                          }
                          else if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox.shrink();
                          }
                          else if (snapshot.data!.docs.isNotEmpty) {
                            final bestfriendDocs = snapshot.data!.docs;
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: bestfriendDocs.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index < bestfriendDocs.length) {
                                var BFdoc = bestfriendDocs[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => FriendDetailPage(uid: BFdoc.get('uid'), favoriteResort: BFdoc.get('favoriteResort'),));
                                        },
                                        child: Container(
                                          width: 72,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Stack(
                                                fit: StackFit.loose,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    child: BFdoc.get('profileImageUrl').isNotEmpty
                                                        ? ExtendedImage.network(
                                                      BFdoc.get('profileImageUrl'),
                                                      enableMemoryCache: true,
                                                      shape: BoxShape.circle,
                                                      borderRadius: BorderRadius.circular(8),
                                                      width: 56,
                                                      height: 56,
                                                      fit: BoxFit.cover,
                                                      loadStateChanged: (ExtendedImageState state) {
                                                        switch (state.extendedImageLoadState) {
                                                          case LoadState.loading:
                                                            return SizedBox.shrink();
                                                          case LoadState.completed:
                                                            return state.completedWidget;
                                                          case LoadState.failed:
                                                            return ExtendedImage.asset(
                                                              'assets/imgs/profile/img_profile_default_circle.png',
                                                              shape: BoxShape.circle,
                                                              borderRadius: BorderRadius.circular(8),
                                                              width: 56,
                                                              height: 56,
                                                              fit: BoxFit.cover,
                                                            );
                                                          default:
                                                            return null;
                                                        }
                                                      },
                                                    )
                                                        : ExtendedImage.asset(
                                                      'assets/imgs/profile/img_profile_default_circle.png',
                                                      enableMemoryCache: true,
                                                      shape: BoxShape.circle,
                                                      borderRadius: BorderRadius.circular(8),
                                                      width: 56,
                                                      height: 56,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  BFdoc.get('isOnLive') == true
                                                      ? Positioned(
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Image.asset(
                                                      'assets/imgs/icons/icon_badge_live.png',
                                                      width: 32,
                                                    ),
                                                  )
                                                      : Container()
                                                ],
                                              ),
                                              SizedBox(height: 6),
                                              Container(
                                                width: 72,
                                                child: Text(
                                                  BFdoc.get('displayName'),
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.normal,
                                                      color: Color(0xFF111111)
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                            return Container(
                            width: 72,
                            height: 72,
                            color: Colors.red,
                            );
                            }
                          }
                          );
                          }
                          return SizedBox.shrink();
                        } catch (e) {
                          SizedBox.shrink();
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

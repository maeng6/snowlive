import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_streamController_friend.dart';
import '../../../controller/vm_userModelController.dart';

class RepoList extends StatefulWidget {
  const RepoList({Key? key}) : super(key: key);

  @override
  State<RepoList> createState() => _RepoListState();
}

class _RepoListState extends State<RepoList> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  StreamController_Friend _streamController_Friend = Get.find<StreamController_Friend>();
  //TODO: Dependency Injection**************************************************

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
      body: StreamBuilder(
        stream: _streamController_Friend.setupStreams_repoList(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
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
            );
          }
          else if (snapshot.data!.docs.isNotEmpty) {
            final repoDocs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: repoDocs.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  title: Text(
                    repoDocs[index]['displayName'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111),
                    ),
                  ),
                  trailing:
                  ElevatedButton(
                    onPressed: (){
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
                                              try{
                                                Navigator.pop(context);
                                                CustomFullScreenDialog.showDialog();
                                                await _userModelController.deleteRepoUid(repoDocs[index]['uid']);
                                                CustomFullScreenDialog.cancelDialog();
                                              }catch(e){
                                                Navigator.pop(context);
                                              }

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
                    }, child: Text('차단해제', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF949494)),),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFFFFF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(
                            color: Color(0xFFDEDEDE)
                        )
                    ),),
                );
              },
            );
          }
          else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Center(
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
          );
        },
      )

    );
  }
}

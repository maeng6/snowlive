import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';
import '../../controller/vm_commentController.dart';
import '../../controller/vm_resortModelController.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';


class CommentTile_resortHome extends StatefulWidget {
  const CommentTile_resortHome({Key? key}) : super(key: key);

  @override
  State<CommentTile_resortHome> createState() => _CommentTile_resortHomeState();
}

class _CommentTile_resortHomeState extends State<CommentTile_resortHome> {


  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection**************************************************
    UserModelController _userModelController = Get.find<UserModelController>();
    ResortModelController _resortModelController =
    Get.find<ResortModelController>();
    Get.put(CommentModelController(), permanent: true);
    CommentModelController _commentModelController =
    Get.find<CommentModelController>();
    GetDateTimeController _getDateTimeController =
    Get.find<GetDateTimeController>();
//TODO: Dependency Injection**************************************************


    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('comment')
          .doc('resort')
          .collection('${_userModelController.instantResort.toString()}')
          .orderBy('timeStamp', descending: true)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.white,
          );
        }
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          reverse: false,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            String _time = _commentModelController.getAgoTime(chatDocs[index].get('timeStamp'));
            return Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(chatDocs[index]['profileImageUrl'] != "")
                        CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(
                                chatDocs[index]['profileImageUrl'])),
                      if(chatDocs[index]['profileImageUrl'] == "")
                        CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage('assets/imgs/profile/img_profile_default_circle.png')),
                      SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                chatDocs[index].get('displayName'),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5),
                              Text(
                                '$_time',
                                style: TextStyle(fontSize: 10),
                              ),
                              if (chatDocs[index].get('uid') == _userModelController.uid)
                                SizedBox(

                                  width: 20,
                                  height: 20,
                                  child: IconButton(
                                    onPressed: () async {
                                      showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              color: Colors.white,
                                              height: 180,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                    Text('삭제하시겠습니까?',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF111111)),),
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
                                                            child: Text('취소',
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.bold),),
                                                            style: TextButton.styleFrom(
                                                                splashFactory:
                                                                InkRipple.splashFactory,
                                                                elevation: 0,
                                                                minimumSize: Size(100, 56),
                                                                backgroundColor:
                                                                Color(0xff555555),
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal: 0)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () async{
                                                              CustomFullScreenDialog.showDialog();
                                                              await FirebaseFirestore.instance
                                                                  .collection('comment')
                                                                  .doc('resort')
                                                                  .collection(
                                                                  '${_userModelController.instantResort.toString()}')
                                                                  .doc(_userModelController.uid)
                                                                  .delete();
                                                              print('댓글 삭제 완료');
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            child: Text('확인',
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.bold),),
                                                            style: TextButton.styleFrom(
                                                                splashFactory:
                                                                InkRipple.splashFactory,
                                                                elevation: 0,
                                                                minimumSize: Size(100, 56),
                                                                backgroundColor:
                                                                Color(0xff2C97FB),
                                                                padding: EdgeInsets.symmetric(
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
                                    icon: Icon(Icons.cancel,
                                      size:10 ,),
                                  ),
                                )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth: 250
                                ),
                                child: Text(chatDocs[index].get('comment'),
                                  maxLines:2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Divider(
                    color: Color(0xFFF5F5F5),
                    thickness: 1,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

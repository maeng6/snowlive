import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../../../controller/vm_userModelController.dart';

class InviteListPage_friend extends StatefulWidget {
  const InviteListPage_friend({Key? key}) : super(key: key);

  @override
  State<InviteListPage_friend> createState() => _InviteListPage_friendState();
}

class _InviteListPage_friendState extends State<InviteListPage_friend> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('user')
              .where('whoInviteMe', arrayContains: _userModelController.uid!)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              print(_userModelController.uid);
              print('null');
              return Center();
            } else if (snapshot.data!.docs.isNotEmpty) {
              final inviDocs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: inviDocs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Container(
                        height: 64,
                        child: Center(
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            onTap: () {},
                            title: Text(
                              inviDocs[index]['displayName'],
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Color(0xFF111111),
                              ),
                            ),
                            trailing: ElevatedButton(
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
                                                '요청을 취소하시겠습니까?',
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
                                                          Color(0xff555555),
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
                                                          await _userModelController.deleteInvitation(friendUid:inviDocs[index]['uid']);
                                                          await _userModelController.deleteInvitationAlarm(uid:inviDocs[index]['uid']);
                                                          await _userModelController.getCurrentUser(_userModelController.uid);
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
                                                          Color(0xff2C97FB),
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
                              }, child: Text('요청취소', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF949494)),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFffffff),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                side: BorderSide(
                                    color: Color(0xFFDEDEDE))
                              ),),
                          ),
                        ),
                      ),
                      if (index != inviDocs.length - 1)
                        Container(
                          color: Color(0xFFF5F5F5),
                          height: 1,
                          width: _size.width -32,
                        )
                    ],
                  );
                },
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Container();
          },
        )

    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_liveCrewModelController.dart';
import '../../../controller/vm_userModelController.dart';

class InviteListPage_crew extends StatefulWidget {
  const InviteListPage_crew({Key? key}) : super(key: key);

  @override
  State<InviteListPage_crew> createState() => _InviteListPage_crewState();
}

class _InviteListPage_crewState extends State<InviteListPage_crew> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('liveCrew')
              .where('applyUidList', arrayContains: _userModelController.uid!)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
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
                            title: Row(
                              children: [
                                (inviDocs[index]['profileImageUrl'].isNotEmpty)
                                    ? GestureDetector(
                                  onTap: () async{
                                    CustomFullScreenDialog.showDialog();
                                    await _liveCrewModelController.getCurrnetCrew(inviDocs[index]['crewID']);
                                    CustomFullScreenDialog.cancelDialog();
                                    Get.to(()=>CrewDetailPage_screen());
                                  },
                                  child: Container(
                                      width: 50,
                                      height: 50,
                                      child: ExtendedImage.network(
                                        inviDocs[index]['profileImageUrl'],
                                        enableMemoryCache: true,
                                        shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(8),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )),
                                )
                                    : GestureDetector(
                                  onTap: () async{
                                    CustomFullScreenDialog.showDialog();
                                    await _liveCrewModelController.getCurrnetCrew(inviDocs[index]['crewID']);
                                    CustomFullScreenDialog.cancelDialog();
                                    Get.to(()=>CrewDetailPage_screen());
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    child: ExtendedImage.asset(
                                      'assets/imgs/profile/img_profile_default_circle.png',
                                      enableMemoryCache: true,
                                      shape: BoxShape.circle,
                                      borderRadius: BorderRadius.circular(8),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Text(
                                  inviDocs[index]['crewName'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: Color(inviDocs[index]['crewColor']),
                                )
                              ],
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
                                                          await _liveCrewModelController.deleteInvitation_crew(crewID: inviDocs[index]['crewID'], applyUid: _userModelController.uid);
                                                          await _liveCrewModelController.getCurrnetCrew(inviDocs[index]['crewID']);
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

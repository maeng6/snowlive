import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/model/m_crewLogoModel.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
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

  var assetBases;

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

                  for (var crewLogo in crewLogoList) {
                    if (crewLogo.crewColor == inviDocs[index]['crewColor']) {
                      assetBases = crewLogo.crewLogoAsset;
                      break;
                    }
                  }

                  return Column(
                    children: [
                      Container(
                        height: 72,
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
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Color(inviDocs[index]['crewColor']),
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: ExtendedImage.network(
                                          inviDocs[index]['profileImageUrl'],
                                          enableMemoryCache: true,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                          BorderRadius.circular(6),
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
                                                  borderRadius: BorderRadius.circular(20),
                                                  width: 24,
                                                  height: 24,
                                                  fit: BoxFit.cover,
                                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                              default:
                                                return null;
                                            }
                                          },
                                        ),
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
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        color: Color(inviDocs[index]['crewColor']),
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: ExtendedImage.asset(
                                        assetBases,
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius:
                                        BorderRadius.circular(6),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  inviDocs[index]['crewName'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15,
                                    color: Color(0xFF111111),
                                  ),
                                ),
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
                                              horizontal: 16),
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
                                                          Size(60, 56),
                                                          backgroundColor:
                                                          Color(0xffD8E7FD),
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
                                                          Size(60, 56),
                                                          backgroundColor:
                                                          Color(0xff3D83ED),
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

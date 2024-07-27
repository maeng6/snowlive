import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/public/vm_timeStampController.dart';
import '../../controller/liveCrew/vm_streamController_liveCrew.dart';
import '../snowliveDesignStyle.dart';


class CrewNoticePage extends StatefulWidget {
  const CrewNoticePage({Key? key}) : super(key: key);

  @override
  State<CrewNoticePage> createState() => _CrewNoticePageState();
}

class _CrewNoticePageState extends State<CrewNoticePage> {

  //TODO: Dependency Injection**************************************************
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  StreamController_liveCrew _streamController_liveCrew = Get.find<StreamController_liveCrew>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text('공지사항',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: StreamBuilder(
        stream: _streamController_liveCrew.setupStreams_liveCrew_crewDetailPage_home_currentCrew(),
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

          final noticeDocs = snapshot.data!.docs;
          Size _size = MediaQuery.of(context).size;

          return ListView.builder(
            itemCount: noticeDocs.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                color: Colors.transparent,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(maxWidth: _size.width - 80),
                              child: Text(
                                '${noticeDocs[index]['notice']}',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF111111)
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              children: [
                                if(index == 0)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: SDSColor.blue500,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      '최신공지',
                                      style: SDSTextStyle.bold.copyWith(
                                        color: SDSColor.snowliveWhite,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 10,),
                                Text('2024.12.21',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal, color: Color(0xFF949494), fontSize: 14
                                ),),
                                SizedBox(width: 10,),
                                Text('올두맹(크루장)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal, color: Color(0xFF949494), fontSize: 14
                                  ),),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (noticeDocs.length != index+1)
                      Divider(
                        height: 50,
                        thickness: 0.5,
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

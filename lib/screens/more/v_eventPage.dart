import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/vm_streamController_moreTab.dart';
import '../../controller/vm_timeStampController.dart';
import '../../controller/vm_urlLauncherController.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {


  //TODO: Dependency Injection**************************************************
  UrlLauncherController _urlLauncherController = Get.find<UrlLauncherController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  StreamController_MoreTab _streamController_MoreTab = Get.find<StreamController_MoreTab>();
  //TODO: Dependency Injection**************************************************


  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          title: Text('이벤트',
            style: TextStyle(
                color: Color(0xFF111111),
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
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
          elevation: 0.0,
          centerTitle: true,
          titleSpacing: 0,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _streamController_MoreTab.setupStreams_moreTab_event(),
          builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return SizedBox.shrink();
            }
            else if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox.shrink();
            }
            else if (snapshot.data!.docs.isNotEmpty) {
              final eventDocs = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 16),
                child: Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: eventDocs.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFFCBE0FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('${eventDocs[index]['category']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF3D83ED)
                                ),
                              ),),
                            SizedBox(
                              height: 16,
                            ),
                            Text('${eventDocs[index]['title']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Color(0xFF111111)
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            ExtendedImage.network(eventDocs[index]['imageUrl'],
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12),
                              fit: BoxFit.cover,
                              width: _size.width,
                              height: _size.width,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SelectableText('${eventDocs[index]['description']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                  color: Color(0xFF111111)
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text('${_timeStampController.yyyymmddFormat(eventDocs[index]['timeStamp'])}',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                  color: Color(0xFF949494)
                              ),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            if(eventDocs[index]['buttonUrl'] != null || eventDocs[index]['buttonUrl'] != '')
                              Container(
                                width: _size.width,
                                height: 58,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.only(top: 0),
                                      backgroundColor: Color(0xFF3D83ED),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                    onPressed: (){
                                     _urlLauncherController.otherShare(contents: '${eventDocs[index]['buttonUrl']}');
                                    },
                                    child: Text('${eventDocs[index]['buttonTitle']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFFffffff)
                                      ),
                                    )
                                ),
                              ),
                            if (eventDocs.length != index+1)
                              Divider(
                                height: 100,
                                thickness: 0.5,
                              ),
                          ],
                        );
                      }
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }
      ),
    );
  }
}

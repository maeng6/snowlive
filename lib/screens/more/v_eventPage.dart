import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/vm_urlLauncherController.dart';
import '../v_webPage.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {

  var _eventStream;

  //TODO: Dependency Injection**************************************************
  UrlLauncherController _urlLauncherController = Get.find<UrlLauncherController>();
  //TODO: Dependency Injection**************************************************

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _eventStream = getEventStream();
  }

  Stream<QuerySnapshot> getEventStream() {
    return FirebaseFirestore.instance
        .collection('event')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '라이브톡',
              style: TextStyle(
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w700,
                  fontSize: 20),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _eventStream,
          builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return SizedBox.shrink();
            }
            else if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox.shrink();
            }
            else if (snapshot.data!.docs.isNotEmpty) {
              final eventDocs = snapshot.data!.docs;

              return Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: eventDocs.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Text('${eventDocs[index]['category']}'),
                          Text('${eventDocs[index]['title']}'),
                          ExtendedImage.network(
                            eventDocs[index]['imageUrl']
                          ),
                          Text('${eventDocs[index]['description']}'),
                          if(eventDocs[index]['buttonUrl'] != null || eventDocs[index]['buttonUrl'] != '')
                            ElevatedButton(
                                onPressed: (){
                                  Get.to(() => WebPage(
                                    url:
                                    '${eventDocs[index]['buttonUrl']}',
                                  ));
                                },
                                child: Text( '${eventDocs[index]['buttonTitle']}')
                            )
                        ],
                      );
                    }
                ),
              );
            }
            return SizedBox.shrink();
          }
      ),
    );
  }
}

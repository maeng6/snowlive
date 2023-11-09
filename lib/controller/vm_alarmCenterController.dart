import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AlarmCenterController extends GetxController {
  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> sendAlarm({
    required receiverUid,
    required alarmCount,
    required senderUid,
    required senderDisplayName,
    required timeStamp,
    required category,
    required msg,
    required content,
    required docName,
    required liveTalk_uid,
    required liveTalk_commentCount,
    required bulletinRoomUid,
    required bulletinRoomCount,
    required bulletinCrewUid,
    required bulletinCrewCount,
  })
  async {

      await ref.collection('alarmCenter')
          .doc('$receiverUid')
          .collection('alarmCenter')
          .doc('${senderUid}#${category}#${alarmCount}')
          .set({
        'receiverUid': receiverUid,
        'senderUid': senderUid,
        'senderDisplayName': senderDisplayName,
        'timeStamp': timeStamp,
        'category': category,
        'msg': msg,
        'content': content,
        'docName': docName,
        'liveTalk_uid' : liveTalk_uid,
        'liveTalk_commentCount' : liveTalk_commentCount,
        'bulletinRoomUid' : bulletinRoomUid,
        'bulletinRoomCount' : bulletinRoomCount,
        'bulletinCrewUid' : bulletinCrewUid,
        'bulletinCrewCount' : bulletinCrewCount,
        'alarmCount' : alarmCount,
      });

      await alarmCenterOn(receiverUid: receiverUid);

  }

  Future<void> deleteAlarm({
    required receiverUid,
    required senderUid,
    required category,
    required alarmCount,
  })
  async {

    await ref.collection('alarmCenter')
        .doc('$receiverUid')
        .collection('alarmCenter')
        .doc('${senderUid}#${category}#${alarmCount}')
        .delete();

    await alarmCenterOff(receiverUid: receiverUid);

  }

  Future<void> deleteAlarm_All({required receiverUid,}) async {
    final collectionRef = FirebaseFirestore.instance
        .collection('alarmCenter')
        .doc(receiverUid)
        .collection('alarmCenter');

    final snapshot = await collectionRef.get();

    // 개별 문서를 순회하면서 삭제합니다.
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }



  Future<void> alarmCenterOn({required receiverUid}) async{

    await ref.collection('newAlarm')
        .doc('$receiverUid')
        .update({
      'alarmCenter': true,
    });

  }

  Future<void> alarmCenterOff({required receiverUid}) async{

    await ref.collection('newAlarm')
        .doc('$receiverUid')
        .update({
      'alarmCenter': false,
    });

  }






}

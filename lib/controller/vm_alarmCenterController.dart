import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_commentModel.dart';
import 'package:com.snowlive/model/m_fleaMarketModel.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AlarmCenterController extends GetxController {
  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;



  Future<void> sendAlarm({
    required receiverUid,
    required senderUid,
    required senderDisplayName,
    required timeStamp,
    required category,
    required msg,
    required content,
    required docName,
    required liveTalk_replyUid,
    required liveTalk_replyCount,
    required liveTalk_replyImage,
    required liveTalk_replyDisplayName,
    required liveTalk_replyResortNickname,
    required liveTalk_comment,
    required liveTalk_commentTime,
    required liveTalk_livetalkImageUrl,
    required liveTalk_kusbf,
    required bulletinRoomUid,
    required bulletinRoomCount,
    required bulletinCrewUid,
    required bulletinCrewCount,
  })
  async {

      await ref.collection('alarmCenter')
          .doc('$receiverUid')
          .collection('alarmCenter')
          .doc('$senderUid$category')
          .set({
        'receiverUid': receiverUid,
        'senderUid': senderUid,
        'senderDisplayName': senderDisplayName,
        'timeStamp': timeStamp,
        'category': category,
        'msg': msg,
        'content': content,
        'docName': docName,
        'liveTalk_replyUid' : liveTalk_replyUid,
        'liveTalk_replyCount' : liveTalk_replyCount,
        'liveTalk_replyImage' : liveTalk_replyImage,
        'liveTalk_replyDisplayName' : liveTalk_replyDisplayName,
        'liveTalk_replyResortNickname' : liveTalk_replyResortNickname,
        'liveTalk_comment' : liveTalk_comment,
        'liveTalk_commentTime' : liveTalk_commentTime,
        'liveTalk_kusbf' : liveTalk_kusbf,
        'liveTalk_livetalkImageUrl' : liveTalk_livetalkImageUrl,
        'bulletinRoomUid' : bulletinRoomUid,
        'bulletinRoomCount' : bulletinRoomCount,
        'bulletinCrewUid' : bulletinCrewUid,
        'bulletinCrewCount' : bulletinCrewCount,
      });

      await alarmCenterOn(receiverUid: receiverUid);

  }

  Future<void> deleteAlarm({
    required receiverUid,
    required senderUid,
    required category
  })
  async {

    await ref.collection('alarmCenter')
        .doc('$receiverUid')
        .collection('alarmCenter')
        .doc('$senderUid$category')
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

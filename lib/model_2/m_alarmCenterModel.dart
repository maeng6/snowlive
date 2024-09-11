import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlarmCenterModel {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;

  static const String friendRequestKey = 'friendRequest';
  static const String crewApplyKey = 'crewApplyKey';
  static const String friendTalkKey = 'friendTalk';
  static const String liveTalkReplyKey = 'liveTalkReply';
  static const String communityReplyKey_room = 'communityReply_room';
  static const String communityReplyKey_crew = 'communityReply_crew';
  static const String communityReplyKey_free = 'communityReply_free';
  static const String communityReplyKey_event = 'communityReply_event';
  static const String communityReplyKey_lost = 'communityReply_lost';

  Map<String, String> alarmCategory = {
    friendRequestKey: '친구요청',
    crewApplyKey: '크루 가입신청',
    friendTalkKey: '친구톡',
    liveTalkReplyKey: '라이브톡',
    communityReplyKey_room: '시즌방 게시글',
    communityReplyKey_crew: '단톡방·동호회 글',
    communityReplyKey_free: '자유게시판 글',
    communityReplyKey_event: '클리닉사행사 글',
    communityReplyKey_lost: '분실물 글',
  };



}

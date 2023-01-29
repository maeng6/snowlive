import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:snowlive3/model/m_commentModel.dart';
import 'package:snowlive3/model/m_fleaChatModel.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class FleaChatModelController extends GetxController {
  RxString? _myDisplayName = ''.obs;
  RxString? _myProfileImageUrl = ''.obs;
  RxString? _comment = ''.obs;
  Timestamp? _timeStamp;
  RxString? _agoTime = ''.obs;
  RxString? _myResortNickname = ''.obs;
  RxString? _otherUid = ''.obs;
  RxString? _otherProfileImageUrl = ''.obs;
  RxString? _otherResortNickname = ''.obs;
  RxString? _otherDisplayName = ''.obs;
  RxString? _myUid = ''.obs;
  RxList? _chatUidList = [].obs;
  RxList? _chatUidSumList = [].obs;
  RxString? _chatRoomName = ''.obs;
  RxInt? _chatCount = 0.obs;

  String? get myDisplayName => _myDisplayName!.value;
  String? get myProfileImageUrl => _myProfileImageUrl!.value;
  String? get comment => _comment!.value;
  Timestamp? get timeStamp => _timeStamp;
  String? get agoTime => _agoTime!.value;
  String? get myResortNickname => _myResortNickname!.value;
  String? get otherUid => _otherUid!.value;
  String? get otherProfileImageUrl => _otherProfileImageUrl!.value;
  String? get otherResortNickname => _otherResortNickname!.value;
  String? get otherDisplayName => _otherDisplayName!.value;
  List? get chatUidList => _chatUidList;
  List? get chatUidSumList => _chatUidSumList;
  String? get myUid => _myUid!.value;
  String? get chatRoomName => _chatRoomName!.value;
  int? get chatCount => _chatCount!.value;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> getCurrentFleaChat({required myUid, required otherUid}) async {
    FleaChatModel fleaChatModel = await FleaChatModel().getCuyrrentFleaChatInfo('$myUid#$otherUid');
    this._myUid!.value = fleaChatModel.myUid!;
    this._timeStamp = fleaChatModel.timeStamp!;
    this._otherUid!.value = fleaChatModel.otherUid!;
    this._otherProfileImageUrl!.value = fleaChatModel.otherProfileImageUrl!;
    this._otherResortNickname!.value = fleaChatModel.otherResortNickname!;
    this._otherDisplayName!.value = fleaChatModel.otherDisplayName!;
    this._myDisplayName!.value = fleaChatModel.myDisplayName!;
    this._myProfileImageUrl!.value = fleaChatModel.myProfileImageUrl!;
    this._myResortNickname!.value = fleaChatModel.myResortNickname!;
    this._chatRoomName!.value = fleaChatModel.chatRoomName!;
  }

  Future<void> sendMessage(
      {required myDisplayName,
        required senderUid,
        required receiverUid,
        required myProfileImageUrl,
        required comment,
        required myResortNickname,
        required chatCount,
        required chatRoomName
      }) async {
    await FleaChatModel().uploadChat(
        myDisplayName : myDisplayName,
        myUid : senderUid,
        otherUid : receiverUid,
        myProfileImageUrl : myProfileImageUrl,
        comment : comment,
        myResortNickname : myResortNickname,
        chatCount : chatCount,
        chatRoomName : chatRoomName,
      timeStamp: Timestamp.now(),
    );
  }

  Future<void> createChatroom(
      {required myUid,
        required otherUid,
        required otherProfileImageUrl,
        required otherResortNickname,
        required otherDisplayName,
        required myDisplayName,
        required myProfileImageUrl,
        required myResortNickname,
      }) async {
    await FleaChatModel().createChatroom(
        otherUid: otherUid,
        myUid: myUid,
        otherProfileImageUrl: otherProfileImageUrl,
        otherResortNickname: otherResortNickname,
        otherDisplayName: otherDisplayName,
        myDisplayName: myDisplayName,
        myProfileImageUrl: myProfileImageUrl,
        myResortNickname: myResortNickname,
    );

    await getCurrentFleaChat(myUid: myUid, otherUid: otherUid);
    await setNewChatCountUid(otherUid: otherUid, otherDispName: otherDisplayName, myDispName: myDisplayName);
    await getChatCount(myUid: myUid, chatRoomName: chatRoomName, otherUid: otherUid);

  }

  Future<void> setNewChatCountUid({required otherUid, required otherDispName, required myDispName}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).collection('$uid#$otherUid').doc(otherUid).set({
      'chatCount': 0,
      'chatOpponent' : otherDispName
    });
    await ref.collection('user').doc(otherUid).collection('$uid#$otherUid').doc(uid).set({
      'chatCount': 0,
      'chatOpponent' : myDispName
    });
  }

  Future<void> deleteChatUid({required chatRoomName,required myUid,required otherUid}) async {
    try {
      CollectionReference myChatUidColRef = FirebaseFirestore
          .instance.collection('user').doc(myUid).collection(chatRoomName);
      await myChatUidColRef.doc(otherUid).delete();
      CollectionReference otherChatUidColRef = FirebaseFirestore
          .instance.collection('user').doc(otherUid).collection(chatRoomName);
      await otherChatUidColRef.doc(otherUid).delete();
    }catch(e){
      CustomFullScreenDialog.cancelDialog();
    }
  }

  Future<void> getChatCount({required myUid,required otherUid,required chatRoomName}) async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(otherUid).collection(chatRoomName).doc(myUid);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int chatCount = documentSnapshot.get('chatCount');
    this._chatCount!.value = chatCount;
  }


  Future<void> updateChatUidSumList(uid) async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('fleaChat').doc('$userMe#$uid').update({
      'chatUidSumList': FieldValue.arrayUnion([uid, userMe])
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('fleaChat').doc('$userMe#$uid');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List chatUidSumList = documentSnapshot.get('chatUidSumList');
    this._chatUidSumList!.value = chatUidSumList;
  }

  Future<void> deleteChatroom(chatroomUid) async {
    CustomFullScreenDialog.showDialog();
    try {
      CollectionReference chatRoom = FirebaseFirestore
          .instance.collection('fleaChat');
      await chatRoom.doc(chatroomUid).delete();
      CustomFullScreenDialog.cancelDialog();
    }catch(e){
      CustomFullScreenDialog.cancelDialog();
    }
    CustomFullScreenDialog.cancelDialog();
  }


  Future<void> deleteChatUidListSell(uid) async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('user').doc(uid).update({
      'fleaChatUidList': FieldValue.arrayRemove([userMe])
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List chatUidList = documentSnapshot.get('fleaChatUidList');
    this._chatUidList!.value = chatUidList;
  }

  Future<void> deleteChatUidListBuy(uid) async {
    final  userMe = auth.currentUser!.uid;
    print(uid);
    await ref.collection('user').doc(userMe).update({
      'fleaChatUidList': FieldValue.arrayRemove([uid])
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List chatUidList = documentSnapshot.get('fleaChatUidList');
    this._chatUidList!.value = chatUidList;
  }





  String getAgoTime(timestamp) {
    String time = CommentModel().getAgo(timestamp);
    return time;
  }
}


//
// Future<void> sendMessageBuy(
//     {required displayName,
//       required uid,
//       required profileImageUrl,
//       required comment,
//       required fleaChatCount,
//       required resortNickname,
//       required commentCount,
//       required myUid,}) async {
//   await FleaChatModel().uploadCommentBuy(
//     comment: comment,
//     displayName: displayName,
//     profileImageUrl: profileImageUrl,
//     timeStamp: Timestamp.now(),
//     fleaChatCount: fleaChatCount,
//     uid: uid,
//     resortNickname: resortNickname,
//     commentCount: commentCount,
//     myUid: myUid,
//   );
//   FleaChatModel fleaChatModel =
//   await FleaChatModel().getCuyrrentFleaChatInfo(uid, myUid);
//   this._uid!.value = fleaChatModel.uid!;
//   this._myDisplayName!.value = fleaChatModel.myDisplayName!;
//   this._myProfileImageUrl!.value = fleaChatModel.myProfileImageUrl!;
//   this._comment!.value = fleaChatModel.comment!;
//   this._timeStamp = fleaChatModel.timeStamp!;
//   this._myResortNickname!.value = fleaChatModel.myResortNickname!;
//   this._myUid.value = fleaChatModel.myUid!;
// }
//
// Future<void> sendMessageSell(
//     {required displayName,
//       required uid,
//       required profileImageUrl,
//       required comment,
//       required fleaChatCount,
//       required resortNickname,
//       required commentCount,
//       required myUid,}) async {
//   await FleaChatModel().uploadCommentSell(
//     comment: comment,
//     displayName: displayName,
//     profileImageUrl: profileImageUrl,
//     timeStamp: Timestamp.now(),
//     fleaChatCount: fleaChatCount,
//     uid: uid,
//     resortNickname: resortNickname,
//     commentCount: commentCount,
//     myUid: myUid,
//   );
//   FleaChatModel fleaChatModel =
//   await FleaChatModel().getCuyrrentFleaChatInfo(uid, myUid);
//   this._uid!.value = fleaChatModel.uid!;
//   this._myDisplayName!.value = fleaChatModel.myDisplayName!;
//   this._myProfileImageUrl!.value = fleaChatModel.myProfileImageUrl!;
//   this._comment!.value = fleaChatModel.comment!;
//   this._timeStamp = fleaChatModel.timeStamp!;
//   this._myResortNickname!.value = fleaChatModel.myResortNickname!;
//   this._myUid.value = fleaChatModel.myUid!;
// }
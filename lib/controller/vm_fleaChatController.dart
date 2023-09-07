import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_commentModel.dart';
import 'package:com.snowlive/model/m_fleaChatModel.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';

class FleaChatModelController extends GetxController {

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getCurrentFleaChat(myUid: myUid, otherUid: otherUid);
  }

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
  RxInt? _myChatCount = 0.obs;
  RxInt? _otherChatCount = 0.obs;
  RxInt? _myChatCheckCount = 0.obs;
  RxInt? _otherChatCheckCount = 0.obs;

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
  int? get myChatCount => _myChatCount!.value;
  int? get otherChatCount => _otherChatCount!.value;
  int? get myChatCheckCount => _myChatCheckCount!.value;
  int? get otherChatCheckCount => _otherChatCheckCount!.value;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> getCurrentFleaChat({required myUid, required otherUid}) async {
    try {
      FleaChatModel fleaChatModel = await FleaChatModel()
          .getCuyrrentFleaChatInfo('$myUid#$otherUid');
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
      this._myChatCount!.value = fleaChatModel.myChatCount!;
      this._otherChatCount!.value = fleaChatModel.otherChatCount!;
      this._myChatCheckCount!.value = fleaChatModel.myChatCheckCount!;
      this._otherChatCheckCount!.value = fleaChatModel.otherChatCheckCount!;
      this._comment!.value = fleaChatModel.comment!;
    }catch(e){}

  }

  Future<void> sendMessage(
      {required myDisplayName,
        required senderUid,
        required receiverUid,
        required myProfileImageUrl,
        required comment,
        required myResortNickname,
        required chatRoomName,
        required myChatCount,
        required otherChatCount,
        required myChatCheckCount,
        required otherChatCheckCount
      }) async {
    await FleaChatModel().uploadChat(
        myDisplayName : myDisplayName,
        myUid : senderUid,
        otherUid : receiverUid,
        myProfileImageUrl : myProfileImageUrl,
        comment : comment,
        myResortNickname : myResortNickname,
        chatRoomName : chatRoomName,
        myChatCount : myChatCount,
        otherChatCount : otherChatCount,
        myChatCheckCount : myChatCheckCount,
        otherChatCheckCount : otherChatCheckCount,
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
    await getChatCount(myUid: myUid, chatRoomName: chatRoomName, otherUid: otherUid);

  }


  Future<void> resetMyChatCheckCount({required chatRoomName}) async {
    await ref.collection('fleaChat').doc(chatRoomName).update({
      'myChatCheckCount' : 0
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('fleaChat').doc(chatRoomName);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int myChatCheckCount = documentSnapshot.get('myChatCheckCount');
    this._myChatCheckCount!.value = myChatCheckCount;
    getCurrentFleaChat(myUid: myUid, otherUid: otherUid);
  }

  Future<void> resetOtherChatCheckCount({required chatRoomName}) async {
    await ref.collection('fleaChat').doc(chatRoomName).update({
      'otherChatCheckCount' : 0
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('fleaChat').doc(chatRoomName);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int otherChatCheckCount = documentSnapshot.get('otherChatCheckCount');
    this._otherChatCheckCount!.value = otherChatCheckCount;
    getCurrentFleaChat(myUid: myUid, otherUid: otherUid);
  }

  Future<void> setOtherChatCountUid({required chatRoomName,}) async {
    await ref.collection('fleaChat').doc(chatRoomName).update({
      'otherChatCount': 0,
      'otherChatCheckCount' : 0,
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

  Future<void> updateOtherChatCount({required otherChatCount, required otherChatCheckCount}) async {
    await ref.collection('fleaChat').doc(chatRoomName).update({
      'otherChatCount': otherChatCount+1,
      'otherChatCheckCount' : otherChatCheckCount+1,
    });
  }

  Future<void> updateMyChatCount({required myChatCount, required myChatCheckCount}) async {
    await ref.collection('fleaChat').doc(chatRoomName).update({
      'myChatCount': myChatCount+1,
      'myChatCheckCount' : myChatCheckCount+1,
    });
  }

  Future<void> getChatCount({required myUid,required otherUid,required chatRoomName}) async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('fleaChat').doc(chatRoomName);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int myChatCheckCount = documentSnapshot.get('myChatCheckCount');
    int myChatCount = documentSnapshot.get('myChatCount');
    int otherChatCheckCount = documentSnapshot.get('otherChatCheckCount');
    int otherChatCount = documentSnapshot.get('otherChatCount');
    this._myChatCheckCount!.value = myChatCheckCount;
    this._myChatCount!.value = myChatCount;
    this._otherChatCheckCount!.value = otherChatCheckCount;
    this._otherChatCount!.value = otherChatCount;

  }

  Future<void> updateChatUidSumList(uid) async {
    final  userMe = auth.currentUser!.uid;
    try {
      await ref.collection('fleaChat').doc('$userMe#$uid').update({
        'chatUidSumList': FieldValue.arrayUnion([uid, userMe])
      });
    }catch(e){
      await ref.collection('fleaChat').doc('$uid#$userMe').update({
        'chatUidSumList': FieldValue.arrayUnion([uid, userMe])
      });
    }
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('fleaChat').doc('$userMe#$uid');
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();
      List chatUidSumList = documentSnapshot.get('chatUidSumList');
      this._chatUidSumList!.value = chatUidSumList;
    }catch(e){
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('fleaChat').doc('$uid#$userMe');
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();
      List chatUidSumList = documentSnapshot.get('chatUidSumList');
      this._chatUidSumList!.value = chatUidSumList;
    }
  }

  Future<void> deleteChatroom({required chatRoomName, required myUid,required otherUid,required fleaMyUid, required myChatCount, required otherChatCount}) async {
    CustomFullScreenDialog.showDialog();
    print('myChatCount:$myChatCount');
    print('otherChatCount:$otherChatCount');
    try {
      //내가 구매자이면
      if(myUid == fleaMyUid){
        for (int i = myChatCount; i > -1; i--) {
          DocumentReference myChatDocs = FirebaseFirestore
              .instance.collection('fleaChat').doc(chatRoomName).collection(myUid).doc('$myUid$i');
           FirebaseFirestore.instance.runTransaction((transaction) async => await transaction.delete(myChatDocs));
        }
        for (int i = otherChatCount; i > -1; i--) {
          DocumentReference otherChatDocs = FirebaseFirestore
              .instance.collection('fleaChat').doc(chatRoomName).collection(
              myUid).doc('$otherUid$i');
           FirebaseFirestore.instance.runTransaction((transaction) async => await transaction.delete(otherChatDocs));
        }
      }
      //내가 판매자이면
      else{
        for (int i = myChatCount; i > -1; i--) {
          DocumentReference myChatDocs = FirebaseFirestore
              .instance.collection('fleaChat').doc(chatRoomName).collection(myUid).doc('$myUid$i');
           FirebaseFirestore.instance.runTransaction((transaction) async => await transaction.delete(myChatDocs));
          for (int i = otherChatCount; i > -1; i--) {
            DocumentReference otherChatDocs = FirebaseFirestore
                .instance.collection('fleaChat').doc(chatRoomName).collection(myUid).doc('$fleaMyUid$i');
             FirebaseFirestore.instance.runTransaction((transaction) async => await transaction.delete(otherChatDocs));
          }
        }
      }
      await ref.collection('fleaChat').doc(chatRoomName).update({
        'chatUidSumList': FieldValue.arrayRemove([myUid])
      });

      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('fleaChat').doc(chatRoomName);
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();
      List chatUidSumList = documentSnapshot.get('chatUidSumList');
      if(chatUidSumList.length==0){
        await ref.collection('fleaChat').doc(chatRoomName).update({'myChatCount' : 0});
        await ref.collection('fleaChat').doc(chatRoomName).update({'myChatCheckCount' : 0});
        await ref.collection('fleaChat').doc(chatRoomName).update({'otherChatCount' : 0});
        await ref.collection('fleaChat').doc(chatRoomName).update({'otherChatCheckCount' : 0});
      }else{}
      CustomFullScreenDialog.cancelDialog();
    }catch(e){
      print('에러');
      CustomFullScreenDialog.cancelDialog();
    }
    CustomFullScreenDialog.cancelDialog();
  }

  Future<void> resetMyChatCount({required chatRoomName}) async {
    await ref.collection('fleaChat').doc(chatRoomName).update({
      'myChatCheckCount' : 0
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('fleaChat').doc(chatRoomName);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int myChatCheckCount = documentSnapshot.get('myChatCheckCount');
    this._myChatCheckCount!.value = myChatCheckCount;
    getCurrentFleaChat(myUid: myUid, otherUid: otherUid);
  }

  Future<void> resetOtherChatCount({required chatRoomName}) async {
    await ref.collection('fleaChat').doc(chatRoomName).update({
      'otherChatCheckCount' : 0
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('fleaChat').doc(chatRoomName);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int otherChatCheckCount = documentSnapshot.get('otherChatCheckCount');
    this._myChatCheckCount!.value = otherChatCheckCount;
    getCurrentFleaChat(myUid: myUid, otherUid: otherUid);
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

  Future<void> deleteChatUidList({required myUid, required otherUid}) async {
    await ref.collection('user').doc(myUid).update({
      'fleaChatUidList': FieldValue.arrayRemove([otherUid])
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(myUid);
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
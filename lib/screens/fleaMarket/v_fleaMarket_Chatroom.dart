import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_10.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/controller/vm_fleaChatController.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class FleaChatroom extends StatefulWidget {
  const FleaChatroom({Key? key}) : super(key: key);

  @override
  State<FleaChatroom> createState() =>
      _FleaChatroomState();
}

class _FleaChatroomState
    extends State<FleaChatroom> {
  final _controller = TextEditingController();
  var _newComment = '';
  final _formKey = GlobalKey<FormState>();

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaChatModelController _fleaChatModelController = Get.find<FleaChatModelController>();

//TODO: Dependency Injection**************************************************

  var _stream;
  bool _isVisible = false;
  bool _firstPress = true;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stream = newStream();
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          _isVisible = true;
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward ||
            _scrollController.position.pixels <=
                _scrollController.position.maxScrollExtent) {
          _isVisible = false;
        }
      });
    });
  }



  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('fleaChat')
        .doc('${_fleaChatModelController.uid}#${_fleaChatModelController.otherUid}')
        .collection('messege')
        .orderBy('timeStamp', descending: true)
        .limit(500)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(58),
              child: AppBar(
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),

                ),
                actions: [
                  TextButton(
                      onPressed: () async{
                        CustomFullScreenDialog.showDialog();

                        try{
                          if(_fleaChatModelController.uid == _userModelController.uid){
                            await _fleaChatModelController
                                .deleteChatroom(
                                '${_fleaChatModelController.uid}#${_fleaChatModelController.otherUid}'
                            );
                            await _fleaChatModelController
                                .deleteChatUidListBuy(
                                _fleaChatModelController.otherUid
                            );
                            CustomFullScreenDialog.cancelDialog();
                            Get.offAll(()=>MainHome());
                          }else{
                            await _fleaChatModelController
                                .deleteChatroom(
                                '${_fleaChatModelController.uid}#${_fleaChatModelController.otherUid}'
                            );
                            await _fleaChatModelController
                                .deleteChatUidListSell(
                                _fleaChatModelController.uid
                            );
                            CustomFullScreenDialog.cancelDialog();
                            Get.offAll(()=>MainHome());
                          }
                        }catch(e){
                          CustomFullScreenDialog.cancelDialog();
                        }
                      },

                      child: Text('채팅방 나가기'))
                ],
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '채팅방',
                    style: GoogleFonts.notoSans(
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.w900,
                        fontSize: 22),
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          color: Colors.white,
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final chatDocs = snapshot.data!.docs;
                      return Scrollbar(
                        child: ListView.builder(
                          reverse: true,
                          controller: _scrollController,
                          itemCount: chatDocs.length,
                          itemBuilder: (context, index) {
                            String _time = _fleaChatModelController
                                .getAgoTime(chatDocs[index].get('timeStamp'));
                            bool _isMe = chatDocs[index]['fixMyUid'] == _userModelController.uid;
                            return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child:
                                Container(
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment:
                                    _isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    _isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      if (chatDocs[index][
                                      'profileImageUrl'] != "")
                                        Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child:
                                          !_isMe
                                              ? GestureDetector(
                                            onTap: () {
                                              Get.to(() =>
                                                  ProfileImagePage(
                                                    CommentProfileUrl:
                                                    chatDocs[index]
                                                    ['profileImageUrl'],
                                                  ));
                                            },
                                            child: ExtendedImage.network(
                                              chatDocs[index]['profileImageUrl'],
                                              cache: true,
                                              shape:
                                              BoxShape.circle,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  20),
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                              : null,
                                        ),

                                      if (chatDocs[index][
                                      'profileImageUrl'] == "")
                                        Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child:
                                          !_isMe
                                              ? GestureDetector(
                                            onTap: () {
                                              Get.to(() =>
                                                  ProfileImagePage(
                                                      CommentProfileUrl:
                                                      ''));
                                            },
                                            child: ExtendedImage
                                                .asset(
                                              'assets/imgs/profile/img_profile_default_circle.png',
                                              shape:
                                              BoxShape.circle,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  20),
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                              :null,
                                        ),
                                      SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment:
                                        _isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        _isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        children: [
                                          if(!_isMe)
                                            Row(
                                              children: [
                                                Text(
                                                  chatDocs[index].get('displayName'),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFF111111)),
                                                ),
                                                SizedBox(
                                                    width: 6),
                                                Text(
                                                  chatDocs[index].get(
                                                      'resortNickname'),
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w300,
                                                      fontSize:
                                                      13,
                                                      color: Color(
                                                          0xFF949494)),
                                                ),
                                                SizedBox(
                                                    width: 1),
                                              ],
                                            ),
                                          if(_isMe)
                                            SizedBox(
                                              height: 2,
                                            ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 30),
                                                child: Container(
                                                  child:
                                                  _isMe ? Text(
                                                    '$_time   ',
                                                    style: TextStyle(
                                                        fontSize:
                                                        10,
                                                        color: Color(
                                                            0xFF949494),
                                                        fontWeight:
                                                        FontWeight
                                                            .w300),
                                                  ) : null,
                                                ),
                                              ),
                                              ChatBubble(
                                                clipper:
                                                _isMe ? ChatBubbleClipper10(type: BubbleType.sendBubble)
                                                    : ChatBubbleClipper10(type: BubbleType.receiverBubble),
                                                backGroundColor: _isMe ? Colors.yellow : Colors.black38,
                                                elevation: 0,
                                                child: Container(
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                      _size.width - 106),
                                                  child: Text(
                                                    chatDocs[index].get('comment'),
                                                    maxLines: 1000,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color:
                                                        _isMe ? Color(0xFF111111) : Colors.white,
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 13),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 30),
                                                child: Container(
                                                  child:
                                                  !_isMe ? Text(
                                                    '   $_time',
                                                    style: TextStyle(
                                                        fontSize:
                                                        10,
                                                        color: Color(
                                                            0xFF949494),
                                                        fontWeight:
                                                        FontWeight
                                                            .w300),
                                                  ) : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.only(bottom: 2),
                  padding:
                  EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: _formKey,
                          cursorColor: Color(0xff377EEA),
                          controller: _controller,
                          strutStyle: StrutStyle(leading: 0.3),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                splashColor: Colors.transparent,
                                onPressed: () async {
                                  if(_controller.text.trim().isEmpty)
                                  {return ;}
                                  FocusScope.of(context).unfocus();
                                  _controller.clear();
                                  _scrollController.jumpTo(0);
                                  try {
                                    await _userModelController.updateCommentCount(_userModelController.commentCount);
                                    await _fleaChatModelController.sendMessage(
                                        displayName: _userModelController.displayName,
                                        uid: (_fleaChatModelController.uid == _userModelController.uid)
                                        ? _fleaChatModelController.otherUid : _userModelController.uid,
                                        myUid:
                                        (_fleaChatModelController.uid == _userModelController.uid)
                                        ? _userModelController.uid : _fleaChatModelController.uid,
                                        profileImageUrl: _userModelController.profileImageUrl,
                                        comment: _newComment,
                                        commentCount: _userModelController.commentCount,
                                        resortNickname: _userModelController.resortNickname,
                                        fleaChatCount: _fleaChatModelController.fleaChatCount,
                                        fixMyUid: _userModelController.uid);
                                    setState(() {});
                                    print(_userModelController.uid);
                                  } catch (e) {}
                                },
                                icon: (_controller.text.trim().isEmpty)
                                    ? Image.asset(
                                  'assets/imgs/icons/icon_livetalk_send_g.png',
                                  width: 27,
                                  height: 27,
                                )
                                    : Image.asset(
                                  'assets/imgs/icons/icon_livetalk_send.png',
                                  width: 27,
                                  height: 27,
                                ),
                              ),
                              errorStyle: TextStyle(
                                fontSize: 12,
                              ),
                              hintStyle: TextStyle(
                                  color: Color(0xff949494), fontSize: 14),
                              hintText: '메시지 보내기',
                              contentPadding: EdgeInsets.only(
                                  top: 10, bottom: 10, left: 16, right: 16),
                              border: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xFFDEDEDE)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xFFDEDEDE)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xFFFF3726)),
                                borderRadius: BorderRadius.circular(6),
                              )),
                          onChanged: (value) {
                            setState(() {
                              _newComment = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                )
              ],
            ),
            floatingActionButton: Visibility(
              visible: _isVisible,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: FloatingActionButton(
                  mini: true,
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero
                  ),
                  backgroundColor: Color(0xFF111111),
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _scrollController.jumpTo(0);
                  },
                  child: Icon(Icons.arrow_downward,
                    size: 22,),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_commentController.dart';
import 'package:snowlive3/controller/vm_replyModelController.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../controller/vm_userModelController.dart';

class NewReply extends StatefulWidget {
  NewReply({Key? key,
    required this.replyLocationUid,
    required this.replyLocationUidCount}) : super(key: key);

  String? replyLocationUid; //내가 대댓글을 남기는 댓글 작성자의 UID
  int? replyLocationUidCount; //내가 대댓글을 남기는 댓글 작성자 UID의 넘버

  @override
  _NewReplyState createState() => _NewReplyState();
}

class _NewReplyState extends State<NewReply> {
  final _controller = TextEditingController();
  var _newReply = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
//TODO: Dependency Injection**************************************************
    UserModelController _userModelController = Get.find<UserModelController>();
    ReplyModelController _replyModelController =
    Get.find<ReplyModelController>();
    CommentModelController _commentModelController =
    Get.find<CommentModelController>();
//TODO: Dependency Injection**************************************************

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          margin: EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.only(top: 10, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: _formKey,
                  cursorColor: Color(0xff377EEA),
                  controller: _controller,
                  strutStyle: StrutStyle(leading: 0.3),
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () async {
                          _controller.text.trim().isEmpty
                              ? null
                              : FocusScope.of(context).unfocus();
                          _controller.clear();
                          CustomFullScreenDialog.showDialog();
                          try{
                          await _userModelController.updateCommentCount(_userModelController.commentCount);
                          await _commentModelController.replyCountUpdate('${widget.replyLocationUid}${widget.replyLocationUidCount}');
                          await _replyModelController.sendReply(
                              displayName: _userModelController.displayName,
                              uid: _userModelController.uid,
                              replyLocationUid: widget.replyLocationUid,
                              profileImageUrl: _userModelController.profileImageUrl,
                              reply: _newReply,
                              replyLocationUidCount: widget.replyLocationUidCount,
                              commentCount: _userModelController.commentCount);
                          setState(() {
                          });}catch(e){}
                          CustomFullScreenDialog.cancelDialog();
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
                      hintStyle: TextStyle(color: Color(0xff949494), fontSize: 14),
                      hintText: '답글 남기기',
                      contentPadding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF3726)),
                        borderRadius: BorderRadius.circular(6),
                      )),
                  onChanged: (value) {
                    setState(() {
                      _newReply = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Text('운영자가 실시간으로 악성댓글을 관리합니다.', style: TextStyle(
          fontSize: 12, color: Color(0xFFC8C8C8),
        ),),
        SizedBox(height: 16,)
      ],
    );
  }
}
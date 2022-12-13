import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_commentController.dart';
import '../../controller/vm_userModelController.dart';

class NewComment extends StatefulWidget {
   NewComment({Key? key}) : super(key: key);

  @override
  _NewCommentState createState() => _NewCommentState();
}

class _NewCommentState extends State<NewComment> {
  final _controller = TextEditingController();
  var _newComment = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
//TODO: Dependency Injection**************************************************
    UserModelController _userModelController = Get.find<UserModelController>();
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
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
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
                          await _userModelController.updateCommentCount(_userModelController.commentCount);
                          await _commentModelController.sendMessage(
                              displayName: _userModelController.displayName,
                              uid: _userModelController.uid,
                              profileImageUrl: _userModelController.profileImageUrl,
                              comment: _newComment,
                              commentCount: _userModelController.commentCount,
                          resortNickname: _userModelController.resortNickname);
                          _controller.clear();
                          setState(() {
                          });
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
                      hintText: '라이브톡 남기기',
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
                      _newComment = value;
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

import 'package:com.snowlive/controller/vm_commentController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controller/vm_liveCrewModelController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../widget/w_fullScreenDialog.dart';

class Modify_liveTalk extends StatefulWidget {
  const Modify_liveTalk({Key? key}) : super(key: key);

  @override
  State<Modify_liveTalk> createState() => _Modify_liveTalkState();
}

class _Modify_liveTalkState extends State<Modify_liveTalk> {

  String? _initComment ;
  TextEditingController _liveTalkTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CommentModelController _commentModelController = Get.find<CommentModelController>();
    _initComment = _commentModelController.comment;
  }

  @override
  Widget build(BuildContext context) {
    //TODO : ****************************************************************
    UserModelController _userModelController = Get.find<UserModelController>();
    CommentModelController _commentModelController = Get.find<CommentModelController>();
    //TODO : ****************************************************************

    Size _size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
              title: Text('스라지기 라톡 변경',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),),
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
                onTap: () {
                  Get.back();
                },
              ),
              actions: [
                TextButton(
                    onPressed: () async{
                      final isValid = _formKey.currentState!.validate();
                      if(isValid){
                        CustomFullScreenDialog.showDialog();
                        await _commentModelController.updateLiveTalk(comment: _liveTalkTextEditingController.text, uid: _commentModelController.uid, commentCount: _commentModelController.commentCount);
                        await _commentModelController.getCurrentLiveTalk(uid: _commentModelController.uid, commentCount: _commentModelController.commentCount);
                        CustomFullScreenDialog.cancelDialog();
                        Navigator.pop(context);
                        Get.back();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text('변경완료', style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D83ED)
                      ),),
                    ))
              ],
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ),
          body: GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _formKey,
                        child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F3F3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              onTap: (){
                                _liveTalkTextEditingController.selection =
                                    TextSelection.fromPosition(
                                        TextPosition(offset: _liveTalkTextEditingController.text.length));
                              },
                              maxLines: 22,
                              textAlignVertical: TextAlignVertical.top,
                              cursorColor: Color(0xff377EEA),
                              cursorHeight: 16,
                              cursorWidth: 2,
                              textAlign: TextAlign.start,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: _liveTalkTextEditingController..text = '$_initComment',
                              onChanged: (comment){
                                _initComment = comment;
                              },
                              strutStyle: StrutStyle(leading: 0.3),
                              decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  errorStyle: TextStyle(
                                    fontSize: 12,
                                  ),
                                  labelStyle: TextStyle(color: Color(0xff949494), fontSize: 15),
                                  hoverColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                  hintText: '내용을 작성해 주세요. (최대 1,000자)',
                                  border: InputBorder.none,
                                  errorBorder:  OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
                                  ),
                                  focusedBorder:  OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
                                  )
                              ),
                              validator: (val) {
                                if (val!.length <= 1000 && val.length >= 0) {
                                  return null;
                                } else if (val.length == 0 || val == "") {
                                  return '스라지기 라톡입력!';
                                } else {
                                  return '최대 입력 가능한 글자 수를 초과했습니다.';
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:bubble/bubble.dart';
import 'package:intl/intl.dart';

import '../../controller/home/vm_streamController_resortHome.dart';
import '../../controller/user/vm_userModelController.dart';
import '../../util/util_1.dart';
import '../../viewmodel/vm_resortHome.dart';
import '../snowliveDesignStyle.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final StreamController_ResortHome _streamController_ResortHome = Get.find<StreamController_ResortHome>();
  final UserModelController _userModelController = Get.find<UserModelController>();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);

  late AnimationController _animationController;
  OverlayEntry? _overlayEntry;

  //TODO: Dependency Injection**************************************************
  ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();
  //TODO: Dependency Injection**************************************************

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _scrollController.addListener(() {
      _resortHomeViewModel.scrollController_resortHome_openchat;
    });
  }

  void _handleTextChange() {
    if (_controller.text.isNotEmpty) {
      _isButtonEnabled.value = true;
    } else {
      _isButtonEnabled.value = false;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    _isButtonEnabled.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: SDSColor.snowliveWhite,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                color: SDSColor.snowliveWhite,
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: _streamController_ResortHome.setupStreams_resortHome_chat(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final chatDocs = snapshot.data!.docs;
                          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                          return ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: chatDocs.length,
                            itemBuilder: (context, index) {
                              final chatDoc = chatDocs[index];
                              final timestamp = chatDoc['createdAt'] as Timestamp;
                              final dateTime = timestamp.toDate().toString();
                              final timeString = GetDatetime().getAgoString(dateTime);


                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ListTile(
                                  title: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: _size.width - 110,
                                        ),
                                        child: Bubble(
                                          margin: BubbleEdges.only(top: 8),
                                          color: SDSColor.blue50,
                                          shadowColor: Colors.transparent,
                                          padding: BubbleEdges.symmetric(horizontal: 10, vertical: 8),
                                          child: Text(chatDoc['text'],
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 15,
                                                color: SDSColor.gray700
                                          )),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 1, left: 8),
                                        child: Text(
                                          timeString,
                                          style: SDSTextStyle.regular.copyWith(
                                              fontSize: 12,
                                              color: SDSColor.gray400),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _controller,
                        cursorColor: SDSColor.snowliveBlue,
                        cursorHeight: 16,
                        cursorWidth: 2,
                        style: SDSTextStyle.regular.copyWith(fontSize: 15),
                        decoration: InputDecoration(
                          errorMaxLines: 2,
                          errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                          labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                          hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                          hintText: '메시지를 입력해주세요.',
                          contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 50),
                          fillColor: SDSColor.gray50,
                          hoverColor: SDSColor.snowliveBlue,
                          focusColor: SDSColor.snowliveBlue,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: SDSColor.gray50),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          suffixIcon: ValueListenableBuilder<bool>(
                            valueListenable: _isButtonEnabled,
                            builder: (context, isEnabled, child) {
                              return IconButton(
                                icon: (_controller.text.trim().isEmpty)
                                    ? Image.asset(
                                  'assets/imgs/icons/icon_livetalk_send_g.png',
                                  width: 24,
                                  height: 24,
                                )
                                    : Image.asset(
                                  'assets/imgs/icons/icon_livetalk_send.png',
                                  width: 24,
                                  height: 24,
                                ),
                                color: isEnabled ? Colors.blue : Colors.grey,
                                onPressed: isEnabled
                                    ? () {
                                  _streamController_ResortHome.sendMessage(_controller.text, _userModelController.uid!);
                                  _controller.clear();
                                  _isButtonEnabled.value = false;
                                  _scrollToBottom();
                                }
                                    : null,
                              );
                            },
                          ),
                        ),
                        onFieldSubmitted: (value) {
                          _streamController_ResortHome.sendMessage(_controller.text, _userModelController.uid!);
                          _controller.clear();
                          _isButtonEnabled.value = false;
                          _scrollToBottom();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          width: 106,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: _scrollToBottom,
            splashColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            hoverElevation: 0,
            hoverColor: Colors.transparent,
            mini: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              side: BorderSide(color: SDSColor.gray200)
            ),
            backgroundColor: SDSColor.snowliveWhite,
            foregroundColor: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.arrow_downward_rounded,
                    color: SDSColor.gray900,
                    size: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 2, right: 3),
                  child: Text('최신글 보기',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: SDSColor.gray900,
                        letterSpacing: 0
                    ),),
                )
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      ),
    );
  }

}


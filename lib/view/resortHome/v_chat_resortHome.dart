import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_openChat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatViewModel _chatViewModel = Get.find<ChatViewModel>();
  final ScrollController _scrollController = ScrollController();
  FocusNode textFocus = FocusNode();

  @override
  void dispose() {
    textFocus.dispose(); // FocusNode 해제
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
      onTap: () {
        FocusScope.of(context).unfocus();
        textFocus.unfocus();
      },
      child: Scaffold(
        backgroundColor: SDSColor.snowliveWhite,
        body: SafeArea(
          child: Obx(
                () => Column(
              children: [
                // 채팅 리스트
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: _chatViewModel.chatDocs.length,
                    itemBuilder: (context, index) {
                      final chatDoc = _chatViewModel.chatDocs[index];
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
                                  maxWidth: _size.width * 0.6,
                                ),
                                child: Bubble(
                                  margin: BubbleEdges.only(top: 8),
                                  color: SDSColor.blue50,
                                  shadowColor: Colors.transparent,
                                  padding: BubbleEdges.symmetric(horizontal: 10, vertical: 8),
                                  child: Text(chatDoc['text'],
                                      style: SDSTextStyle.regular.copyWith(
                                          fontSize: 15,
                                          color: SDSColor.gray700)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 1, left: 8),
                                child: Text(
                                  timeString,
                                  style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
                                  softWrap: true,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  textFocus.unfocus();
                                  showModalBottomSheet(
                                    enableDrag: false,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context) {
                                      return SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
                                          child: Container(
                                            margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Wrap(
                                              children: [
                                                Column(
                                                  children: [
                                                    GestureDetector(
                                                      child: ListTile(
                                                        contentPadding: EdgeInsets.zero,
                                                        title: Center(
                                                          child: Text(
                                                            '신고하기',
                                                            style: SDSTextStyle.bold.copyWith(
                                                                fontSize: 15, color: SDSColor.gray900),
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                          await _chatViewModel.reportMessage(chatDoc['chatId']);
                                                          FocusScope.of(context).unfocus();
                                                          textFocus.unfocus();
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );},
                                child: Icon(
                                  Icons.more_vert,
                                  color: SDSColor.gray200,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 입력창
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    focusNode: textFocus,
                    controller: _chatViewModel.chatController,
                    cursorColor: SDSColor.snowliveBlue,
                    cursorHeight: 16,
                    cursorWidth: 2,
                    style: SDSTextStyle.regular.copyWith(fontSize: 15),
                    textInputAction: TextInputAction.newline,
                    maxLines: null,
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
                      suffixIcon: IconButton(
                        icon: (_chatViewModel.isButtonEnabled.value)
                            ? Image.asset(
                          'assets/imgs/icons/icon_livetalk_send.png',
                          width: 24,
                          height: 24,
                        )
                            : Image.asset(
                          'assets/imgs/icons/icon_livetalk_send_g.png',
                          width: 24,
                          height: 24,
                        ),
                        color: _chatViewModel.isButtonEnabled.value ? Colors.blue : Colors.grey,
                        onPressed: _chatViewModel.isButtonEnabled.value
                            ? () {
                          _chatViewModel.sendMessage(_chatViewModel.chatController.text);
                          _chatViewModel.chatController.clear();
                          _chatViewModel.isButtonEnabled.value = false;
                          _scrollToBottom();
                        }
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

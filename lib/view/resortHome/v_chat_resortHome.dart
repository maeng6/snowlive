import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_openChat.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_openChatAlarm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatViewModel _chatViewModel = Get.find<ChatViewModel>();
  final OpenChatAlarmViewModel _openChatAlarmViewModel = Get.find<OpenChatAlarmViewModel>();
  final ScrollController _scrollController = ScrollController();
  FocusNode textFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // 🛡️ 메모리 최적화: 화면 진입 시 스트림 시작
    _chatViewModel.startChatStream();
  }

  @override
  void dispose() {
    // 🛡️ 메모리 최적화: 화면 이탈 시 스트림 중지
    _chatViewModel.stopChatStream();
    _scrollController.dispose();
    textFocus.dispose();
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

  /// Pending 메시지 타일 빌드 (로딩/실패 상태 표시)
  Widget _buildPendingMessageTile(PendingMessage pendingMsg, Size size) {
    final isSending = pendingMsg.status == MessageStatus.sending;
    final isFailed = pendingMsg.status == MessageStatus.failed;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 12),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.70,
            ),
            child: Bubble(
              margin: BubbleEdges.only(top: 2),
              // 실패 시 연한 빨간색, 전송 중엔 연한 파란색
              color: isFailed ? SDSColor.red.withOpacity(0.1) : SDSColor.blue50,
              shadowColor: Colors.transparent,
              padding: BubbleEdges.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                pendingMsg.text,
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  color: isFailed ? SDSColor.gray500 : SDSColor.gray700,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 1, left: 6),
            child: isSending
                ? LoadingAnimationWidget.waveDots(
              color: SDSColor.gray400,
              size: 16,
            )
                : isFailed
                ? GestureDetector(
              onTap: () => _chatViewModel.retryMessage(pendingMsg.chatId),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: SDSColor.red,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '재시도',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 11,
                      color: SDSColor.red,
                    ),
                  ),
                ],
              ),
            )
                : SizedBox.shrink(),
          ),
          Spacer(),
          // 실패 시 삭제 버튼
          if (isFailed)
            GestureDetector(
              onTap: () => _chatViewModel.removePendingMessage(pendingMsg.chatId),
              child: Icon(
                Icons.close,
                color: SDSColor.gray400,
                size: 18,
              ),
            ),
        ],
      ),
    );
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
                    // pending 메시지 + Firebase 메시지 합산
                    itemCount: _chatViewModel.pendingMessages.length + _chatViewModel.chatDocs.length,
                    itemBuilder: (context, index) {
                      final pendingCount = _chatViewModel.pendingMessages.length;

                      // Pending 메시지 표시 (맨 위 = 최신)
                      if (index < pendingCount) {
                        final pendingList = _chatViewModel.pendingMessages.values.toList().reversed.toList();
                        final pendingMsg = pendingList[index];
                        return _buildPendingMessageTile(pendingMsg, _size);
                      }

                      // Firebase 메시지 표시
                      final chatDocIndex = index - pendingCount;
                      final chatDoc = _chatViewModel.chatDocs[chatDocIndex];
                      final data = chatDoc.data() as Map<String, dynamic>;
                      final timestamp = data['createdAt'] as Timestamp;
                      final dateTime = timestamp.toDate().toString();
                      final timeString = GetDatetime().getAgoString(dateTime);
                      final bool isSystemMsg = data.containsKey('system_msg') ? (data['system_msg'] ?? false) : false;

                      // 시스템 메시지인 경우
                      if (isSystemMsg) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: SDSColor.gray100,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                chatDoc['text'],
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 12,
                                  color: SDSColor.gray600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }

                      // 일반 채팅 메시지
                      return ListTile(
                        contentPadding: const EdgeInsets.only(left: 16, right: 12),
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: _size.width * 0.70,
                              ),
                              child: Bubble(
                                margin: BubbleEdges.only(top: 2),
                                color: SDSColor.blue50,
                                shadowColor: Colors.transparent,
                                padding: BubbleEdges.symmetric(horizontal: 10, vertical: 8),
                                child: Text(chatDoc['text'],
                                    style: SDSTextStyle.regular.copyWith(
                                        fontSize: 14,
                                        color: SDSColor.gray700)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 1, left: 6),
                              child: Text(
                                timeString,
                                style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray400),
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

                          // 새 글 작성 시 알람 초기화 (모든 유저에게 새 글 알림, 본인은 읽음 처리)
                          _openChatAlarmViewModel.clearAndMarkMyself();
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

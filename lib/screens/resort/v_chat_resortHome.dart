import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:bubble/bubble.dart';
import 'package:intl/intl.dart';

import '../../controller/home/vm_streamController_resortHome.dart';
import '../../controller/user/vm_userModelController.dart';
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

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
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

  void _showNewMessageNotification() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
    _animationController.forward().then((value) {
      _animationController.reverse().then((value) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: MediaQuery.of(context).size.width / 2 - 75,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: _animationController,
            child: Container(
              width: 150,
              height: 150,
              child: Image.asset('assets/imgs/icons/icon_alarm.png'), // Add your GIF file here
            ),
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 300, // Fixed height for the chat list view
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
                      final dateTime = timestamp.toDate();
                      final timeString = DateFormat('yyyy-MM-dd h:mm a').format(dateTime);

                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Bubble(
                              margin: BubbleEdges.only(top: 10),
                              color: Colors.grey[300],
                              nip: BubbleNip.leftTop,
                              child: Text(chatDoc['text'], style: TextStyle(fontSize: 16)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              timeString,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
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
                decoration: InputDecoration(
                  hintText: '메시지를 입력해주세요.',
                  filled: true,
                  fillColor: Color(0xFFEFEFEF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
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
                          _showNewMessageNotification();
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
                  _showNewMessageNotification();
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 100, // Positioning the button above the input field
          right: 20,
          child: IconButton(
            onPressed: _scrollToBottom,
            icon: Icon(Icons.arrow_circle_down_rounded),
            color: SDSColor.snowliveBlack,
            iconSize: 30, // Reduce the size of the icon
          ),
        ),
      ],
    );
  }
}

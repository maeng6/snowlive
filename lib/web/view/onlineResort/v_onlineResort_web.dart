import 'dart:html' as html;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// 온라인 스키장은 Flutter가 아닌 **순수 웹 앱**(`/mountain/`, three.js + Firebase)으로
/// 재구축됐다. 이 라우트(`/online-resort`)는 기존 링크 호환을 위해 남겨두고,
/// 진입 시 전체 페이지를 `/mountain/`으로 이동시킨다.
///
/// 같은 오리진이라 `/mountain/`이 Firebase 로그인 세션을 자동 공유하지만, 혹시
/// 세션 공유가 안 걸릴 때를 대비해 현재 로그인 uid를 `?uid=`로 함께 넘겨
/// 안전장치로 삼는다(미로그인이면 생략 → 게스트).
class OnlineResortViewWeb extends StatefulWidget {
  const OnlineResortViewWeb({super.key});

  @override
  State<OnlineResortViewWeb> createState() => _OnlineResortViewWebState();
}

class _OnlineResortViewWebState extends State<OnlineResortViewWeb> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final q = (uid != null && uid.isNotEmpty)
          ? '?uid=${Uri.encodeQueryComponent(uid)}'
          : '';
      // 파일명까지 적어야 `flutter run` 개발 서버에서도 스키장이 열린다
      // (개발 서버는 `/mountain/`에 Flutter 앱의 index.html을 돌려준다).
      html.window.location.assign('/mountain/index.html$q');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SDSColor.blue50,
      alignment: Alignment.center,
      child: Text(
        '온라인 스키장으로 이동 중…',
        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray600),
      ),
    );
  }
}

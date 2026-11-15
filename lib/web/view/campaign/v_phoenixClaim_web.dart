import 'package:com.snowlive/core/api/api_phoenix.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_daum_postcode.dart';
import 'package:com.snowlive/web/widget/w_web_back_icon_web.dart';
import 'package:com.snowlive/web/widget/w_web_floating_bottombar_web.dart';
import 'package:com.snowlive/web/widget/w_web_form_fields_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 상품 받기 — 수상자 본인이 배송 정보(이름/전화/주소)를 제출한다.
class PhoenixClaimWeb extends StatefulWidget {
  const PhoenixClaimWeb({super.key});

  @override
  State<PhoenixClaimWeb> createState() => _PhoenixClaimWebState();
}

class _PhoenixClaimWebState extends State<PhoenixClaimWeb> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _postcode = TextEditingController();
  final _address = TextEditingController();
  final _addressDetail = TextEditingController();
  bool _consent = false;

  int? _winnerId;
  bool _loading = true;
  bool _submitting = false;
  bool _done = false;
  String _error = '';
  String? _existingStatus; // 이미 제출함
  bool _claimOpen = true;

  bool get _loggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    _winnerId = int.tryParse(Get.parameters['winner'] ?? '');
    _init();
  }

  Future<void> _init() async {
    if (_winnerId == null) {
      setState(() { _loading = false; _error = '잘못된 접근이에요.'; });
      return;
    }
    if (!_loggedIn) {
      setState(() => _loading = false);
      return;
    }
    final d = await PhoenixAPI.fetchMyClaim(_winnerId!);
    if (d['ok'] == true) {
      _claimOpen = d['claim_open'] == true;
      final claim = d['claim'] as Map?;
      if (claim != null) _existingStatus = claim['status']?.toString();
    } else {
      _error = (d['error'] ?? '불러오지 못했어요.').toString();
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _postcode.dispose();
    _address.dispose();
    _addressDetail.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final r = await openDaumPostcode();
    if (r != null) {
      setState(() {
        _postcode.text = r.zonecode;
        _address.text = r.address;
      });
    }
  }

  Future<void> _submit() async {
    setState(() { _error = ''; });
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty || _address.text.trim().isEmpty) {
      setState(() => _error = '이름·전화번호·주소를 모두 입력해 주세요.');
      return;
    }
    if (!_consent) {
      setState(() => _error = '개인정보 수집·이용 동의가 필요해요.');
      return;
    }
    setState(() => _submitting = true);
    final d = await PhoenixAPI.submitClaim(
      winnerId: _winnerId!,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      addressDetail: _addressDetail.text.trim(),
      postcode: _postcode.text.trim(),
      consent: _consent,
    );
    setState(() => _submitting = false);
    if (d['ok'] == true) {
      setState(() => _done = true);
    } else {
      setState(() => _error = (d['error'] ?? '제출에 실패했어요.').toString());
    }
  }

  /// 지금 화면이 입력 폼인지. 제출 버튼을 헤더(PC)·하단바(모바일)에 둘지 정하는 데
  /// 쓴다 — 안내 화면에까지 제출 버튼이 떠 있으면 안 된다.
  bool get _showsForm {
    if (_loading || !_loggedIn) return false;
    if (_error.isNotEmpty && _winnerId == null) return false;
    if (_done || _existingStatus != null) return false;
    return _claimOpen;
  }

  @override
  Widget build(BuildContext context) {
    // 레이아웃·간격·필드는 중고거래 글 올리기(FleamarketUploadViewWeb)와 같은
    // 규칙을 쓴다. 서브 페이지끼리 폼 생김새가 갈리면 같은 서비스로 안 보인다.
    final isMobile = context.screenType == WebScreenType.mobile;
    final isDesktop = context.isDesktop;

    final scroll = SingleChildScrollView(
      padding: webSubPagePadding(
        context,
        bottom: isMobile && _showsForm
            ? kWebFloatingBottomBarHeight + SDSSpacing.md
            : SDSSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? kWebSubPageMaxWidth : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  WebIconButton(
                    onTap: () => Get.offAllNamed(WebRoutes.phoenix),
                    padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                    icon: WebBackIcon(size: isMobile ? 24 : 30),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '상품 받기',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: isDesktop ? 30 : 24,
                      color: SDSColor.gray900,
                    ),
                  ),
                  const Spacer(),
                  if (!isMobile && _showsForm) _submitButton(),
                ],
              ),
              SizedBox(height: webFormHeaderGap(context)),
              _body(),
            ],
          ),
        ),
      ),
    );

    if (!isMobile || !_showsForm) {
      return Container(color: SDSColor.snowliveWhite, child: scroll);
    }
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          scroll,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: WebFloatingBottomBar(child: _mobileSubmitButton()),
          ),
        ],
      ),
    );
  }

  /// 모바일 하단 플로팅 바 버튼 — 목록·글 올리기와 같은 전용 위젯(높이 48).
  /// 헤더용 40짜리를 그대로 쓰면 다른 화면의 하단바보다 낮아 보인다.
  Widget _mobileSubmitButton() {
    return WebBottomBarButton(
      label: '제출하기',
      background: SDSColor.snowliveBlue,
      foreground: SDSColor.snowliveWhite,
      onTap: _submitting ? null : _submit,
      leading: _submitting
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(SDSColor.snowliveWhite),
              ),
            )
          : null,
    );
  }

  /// PC·태블릿 헤더 제출 버튼 — 글 올리기의 '판매하기'와 같은 규격(높이 40,
  /// 라운드 5). 라벨을 스피너로 "교체"하면 폭이 튀므로 라벨은 두고 앞에 끼운다.
  Widget _submitButton({bool expand = false}) {
    final btn = SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: SDSColor.snowliveBlue,
          disabledBackgroundColor: SDSColor.gray200,
          elevation: 0,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_submitting) ...[
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(SDSColor.snowliveWhite),
                ),
              ),
              const SizedBox(width: SDSSpacing.sm),
            ],
            Text(
              '제출하기',
              style: SDSTextStyle.bold
                  .copyWith(fontSize: 16, color: SDSColor.snowliveWhite),
            ),
          ],
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  Widget _body() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (!_loggedIn) return _loginPrompt();
    if (_error.isNotEmpty && _winnerId == null) return _msg(_error);
    if (_done || _existingStatus != null) return _submitted();
    if (!_claimOpen) return _msg('상품 받기 기간이 아니에요.');
    return _form();
  }

  Widget _loginPrompt() => _notice(
        title: '로그인이 필요해요',
        body: '수상자 본인 확인을 위해 로그인 후 신청해 주세요.',
        actionLabel: '로그인하기',
        onAction: () => Get.toNamed(WebRoutes.login),
      );

  Widget _submitted() => _notice(
        // Material 기본 아이콘 대신 앱·웹 공통 체크 에셋 — 같은 화면 아래
        // 동의 체크박스와 같은 그래픽이라야 한 서비스로 읽힌다.
        iconAsset: 'assets/imgs/icons/icon_check_filled.png',
        title: '신청이 접수됐어요',
        body: '입력하신 정보로 상품을 보내드릴게요.',
        actionLabel: '이벤트로 돌아가기',
        onAction: () => Get.offAllNamed(WebRoutes.phoenix),
      );

  /// 안내 화면 공통 — 아이콘(선택) + 제목 + 설명 + 액션 하나.
  Widget _notice({
    String? iconAsset,
    required String title,
    required String body,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 40),
      child: Center(
        child: Column(
          children: [
            if (iconAsset != null) ...[
              Image.asset(iconAsset, width: 48, height: 48),
              const SizedBox(height: 14),
            ],
            Text(title,
                style: SDSTextStyle.bold
                    .copyWith(fontSize: 18, color: SDSColor.gray900)),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: SDSTextStyle.regular.copyWith(
                  fontSize: 14, color: SDSColor.gray600, height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SDSColor.snowliveBlue,
                  elevation: 0,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                child: Text(actionLabel,
                    style: SDSTextStyle.bold.copyWith(
                        fontSize: 15, color: SDSColor.snowliveWhite)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _msg(String t) => Padding(
        padding: const EdgeInsets.only(top: 60, bottom: 60),
        child: Center(
          child: Text(t,
              textAlign: TextAlign.center,
              style: SDSTextStyle.regular
                  .copyWith(fontSize: 15, color: SDSColor.gray600)),
        ),
      );

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebFormTextField(
          label: '이름',
          isRequired: true,
          controller: _name,
          hint: '받는 분 성함을 입력해 주세요.',
          maxLength: 20,
          onChanged: (_) => setState(() {}),
        ),
        // 필드 사이 30 — 글 올리기와 동일.
        const SizedBox(height: 30),
        WebFormTextField(
          label: '전화번호',
          isRequired: true,
          controller: _phone,
          hint: "'-' 없이 입력해 주세요. (예: 01012345678)",
          keyboardType: TextInputType.phone,
          maxLength: 11,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 30),
        // 주소는 라벨 하나 아래 세 필드를 쌓는다(우편번호 + 기본 + 상세).
        const WebFormLabel('주소', required: true),
        Row(
          children: [
            Expanded(
              child: WebFormTextField(
                label: '',
                controller: _postcode,
                hint: '우편번호',
                readOnly: true,
                onTap: _searchAddress,
              ),
            ),
            const SizedBox(width: 10),
            _addressSearchButton(),
          ],
        ),
        const SizedBox(height: 8),
        WebFormTextField(
          label: '',
          controller: _address,
          hint: '기본 주소 (주소 검색으로 입력)',
          readOnly: true,
          onTap: _searchAddress,
        ),
        const SizedBox(height: 8),
        WebFormTextField(
          label: '',
          controller: _addressDetail,
          hint: '상세 주소 (동/호수 등)',
        ),
        const SizedBox(height: 30),
        _consentRow(),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(_error,
              style: SDSTextStyle.regular
                  .copyWith(fontSize: 13, color: SDSColor.red)),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  /// 주소 검색 — 입력 높이(44)에 맞춘 보조 버튼. 파란 제출 버튼과 구분되게 중립색.
  Widget _addressSearchButton() {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: _searchAddress,
        style: ElevatedButton.styleFrom(
          backgroundColor: SDSColor.gray100,
          foregroundColor: SDSColor.gray900,
          elevation: 0,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text('주소 검색',
            style: SDSTextStyle.bold
                .copyWith(fontSize: 14, color: SDSColor.gray900)),
      ),
    );
  }

  Widget _consentRow() {
    return InkWell(
      onTap: () => setState(() => _consent = !_consent),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        // 앱·중고거래와 동일한 체크 에셋(icon_check_filled/unfilled) 20 + 간격 6.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              _consent
                  ? 'assets/imgs/icons/icon_check_filled.png'
                  : 'assets/imgs/icons/icon_check_unfilled.png',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '(필수) 개인정보 수집·이용에 동의합니다.\n'
                '수집항목: 이름·전화번호·주소 / 목적: 경품 배송 / 보유기간: 배송 완료 후 30일 이내 파기.',
                style: SDSTextStyle.regular.copyWith(
                    fontSize: 13, color: SDSColor.gray900, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

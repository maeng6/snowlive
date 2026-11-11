import 'package:com.snowlive/core/api/api_phoenix.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/web_daum_postcode.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
      appBar: AppBar(
        backgroundColor: SDSColor.snowliveWhite,
        elevation: 0,
        foregroundColor: SDSColor.gray900,
        title: Text('상품 받기', style: SDSTextStyle.bold.copyWith(fontSize: 17)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed(WebRoutes.phoenix),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _body(),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Padding(
          padding: EdgeInsets.only(top: 80),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (!_loggedIn) return _loginPrompt();
    if (_error.isNotEmpty && _winnerId == null) return _msg(_error);
    if (_done || _existingStatus != null) return _submitted();
    if (!_claimOpen) return _msg('상품 받기 기간이 아니에요.');
    return _form();
  }

  Widget _loginPrompt() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Text('로그인이 필요해요', style: SDSTextStyle.bold.copyWith(fontSize: 18)),
        const SizedBox(height: 8),
        Text('수상자 본인 확인을 위해 로그인 후 신청해 주세요.',
            style: SDSTextStyle.regular.copyWith(color: SDSColor.gray600, fontSize: 14)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Get.toNamed(WebRoutes.login),
          style: ElevatedButton.styleFrom(
              backgroundColor: SDSColor.snowliveBlue, elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: Text('로그인하기',
              style: SDSTextStyle.bold.copyWith(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _submitted() {
    return Column(
      children: [
        const SizedBox(height: 50),
        const Icon(Icons.check_circle_outline, size: 52, color: SDSColor.snowliveBlue),
        const SizedBox(height: 12),
        Text('신청이 접수됐어요', style: SDSTextStyle.bold.copyWith(fontSize: 20)),
        const SizedBox(height: 8),
        Text('입력하신 정보로 상품을 보내드릴게요. 배송 상태는 이 페이지에서 확인할 수 있어요.',
            textAlign: TextAlign.center,
            style: SDSTextStyle.regular.copyWith(color: SDSColor.gray600, fontSize: 14, height: 1.5)),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => Get.offAllNamed(WebRoutes.phoenix),
          child: const Text('이벤트로 돌아가기'),
        ),
      ],
    );
  }

  Widget _msg(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Text(t, textAlign: TextAlign.center,
          style: SDSTextStyle.regular.copyWith(color: SDSColor.gray600, fontSize: 15)),
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('휘닉스파크 상품 배송 정보',
            style: SDSTextStyle.bold.copyWith(fontSize: 18)),
        const SizedBox(height: 6),
        Text('경품 배송을 위해 아래 정보를 입력해 주세요.',
            style: SDSTextStyle.regular.copyWith(color: SDSColor.gray600, fontSize: 13)),
        const SizedBox(height: 20),
        _label('이름'),
        _field(_name, '받는 분 성함'),
        const SizedBox(height: 14),
        _label('전화번호'),
        _field(_phone, "'-' 없이 입력 (예: 01012345678)",
            keyboard: TextInputType.phone),
        const SizedBox(height: 14),
        _label('주소'),
        Row(children: [
          Expanded(
            child: _field(_postcode, '우편번호', enabled: false),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _searchAddress,
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
            child: const Text('주소 검색'),
          ),
        ]),
        const SizedBox(height: 8),
        _field(_address, '기본 주소 (주소 검색)', enabled: false),
        const SizedBox(height: 8),
        _field(_addressDetail, '상세 주소 (동/호수 등)'),
        const SizedBox(height: 18),
        InkWell(
          onTap: () => setState(() => _consent = !_consent),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Checkbox(
              value: _consent,
              onChanged: (v) => setState(() => _consent = v ?? false),
              activeColor: SDSColor.snowliveBlue,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '(필수) 개인정보 수집·이용에 동의합니다. 수집항목: 이름·전화번호·주소 / 목적: 경품 배송 / 보유기간: 배송 완료 후 30일 이내 파기.',
                  style: SDSTextStyle.regular.copyWith(
                      color: SDSColor.gray600, fontSize: 12, height: 1.5),
                ),
              ),
            ),
          ]),
        ),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(_error, style: SDSTextStyle.regular.copyWith(color: SDSColor.red, fontSize: 13)),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
              backgroundColor: SDSColor.snowliveBlue, elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: _submitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('제출하기', style: SDSTextStyle.bold.copyWith(color: Colors.white, fontSize: 15)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray700)),
      );

  Widget _field(TextEditingController c, String hint,
      {bool enabled = true, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      enabled: enabled,
      keyboardType: keyboard,
      style: SDSTextStyle.regular.copyWith(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
        filled: true,
        fillColor: enabled ? SDSColor.snowliveWhite : SDSColor.gray50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: SDSColor.gray200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: SDSColor.snowliveBlue)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: SDSColor.gray100)),
      ),
    );
  }
}

import 'package:com.snowlive/core/api/api_seasonPass.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/toss_payment.dart';
import 'package:get/get.dart';

/// 웹 시즌권 페이지 뷰모델.
/// 구매상태 조회 / 구매내역 / 토스 결제 시작 / 리다이렉트 승인 / 환불 신청.
class SeasonPassViewModelWeb extends GetxController {
  final SeasonPassAPI _api = SeasonPassAPI();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // 구독상태
  final RxBool isPaid = false.obs;
  final RxnString season = RxnString();
  final RxnString seasonName = RxnString();
  final RxInt price = 0.obs;
  final RxnString validUntil = RxnString();
  final Rxn<Map<String, dynamic>> currentPass = Rxn<Map<String, dynamic>>();

  // 구매내역
  final RxList<Map<String, dynamic>> history = <Map<String, dynamic>>[].obs;

  // 결제 화면 필수 동의 체크(멀티플랫폼/전자상거래법)
  final RxBool agreeTerms = false.obs; // 종료일/결제 고지
  final RxBool agreeRefund = false.obs; // 이용 시작 후 환불 제한

  final RxnString message = RxnString();

  bool get canPurchase => agreeTerms.value && agreeRefund.value && !isSubmitting.value;

  int? get _uid {
    if (!Get.isRegistered<UserViewModel>()) return null;
    final id = Get.find<UserViewModel>().user.user_id;
    if (id is int) return id;
    return int.tryParse('$id');
  }

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    await loadStatus();
    await loadHistory();
  }

  Future<void> loadStatus() async {
    final uid = _uid;
    if (uid == null) return;
    isLoading.value = true;
    try {
      final res = await _api.fetchStatus(userId: uid);
      if (res.success && res.data is Map) {
        final d = Map<String, dynamic>.from(res.data);
        isPaid.value = d['is_paid'] == true;
        season.value = d['season']?.toString();
        seasonName.value = d['season_name']?.toString();
        price.value = (d['price'] is int) ? d['price'] : int.tryParse('${d['price']}') ?? 0;
        validUntil.value = d['valid_until']?.toString();
        currentPass.value = d['pass'] is Map ? Map<String, dynamic>.from(d['pass']) : null;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadHistory() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final res = await _api.fetchHistory(userId: uid);
      if (res.success && res.data is Map && res.data['history'] is List) {
        history.assignAll(List<Map<String, dynamic>>.from(
            (res.data['history'] as List).map((e) => Map<String, dynamic>.from(e))));
      }
    } catch (_) {}
  }

  /// 구매하기: 주문 생성 → 토스 결제창(리다이렉트).
  Future<void> purchase() async {
    final uid = _uid;
    if (uid == null) {
      message.value = '로그인이 필요합니다.';
      return;
    }
    if (!canPurchase) {
      message.value = '필수 고지에 동의해주세요.';
      return;
    }
    isSubmitting.value = true;
    message.value = null;
    try {
      final res = await _api.prepare(userId: uid);
      if (!res.success || res.data is! Map) {
        final err = res.data is Map ? (res.data['message'] ?? res.data['error']) : '주문 생성 실패';
        message.value = '$err';
        return;
      }
      final d = Map<String, dynamic>.from(res.data);
      final err = await startTossPayment(
        clientKey: d['client_key']?.toString() ?? '',
        customerKey: d['customer_key']?.toString() ?? 'user_$uid',
        amount: (d['amount'] is int) ? d['amount'] : int.tryParse('${d['amount']}') ?? 0,
        orderId: d['order_id']?.toString() ?? '',
        orderName: d['order_name']?.toString() ?? '스노우라이브 시즌권',
      );
      // 성공 시 리다이렉트되어 이 지점에 도달하지 않음. err가 있으면 취소/실패.
      if (err != null) message.value = err;
    } catch (e) {
      message.value = '결제 중 오류가 발생했습니다.';
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 리다이렉트 복귀(성공 페이지)에서 승인 확정. 성공 여부 반환.
  /// 주의: 리다이렉트 직후엔 로그인 세션이 아직 복원되지 않아 _uid가 null일 수 있다.
  /// 서버는 order_id로 주문을 찾아 승인하므로 uid 없이도 승인은 진행한다(중단 금지).
  Future<bool> confirmFromRedirect() async {
    final p = readTossRedirectParams();
    if (!p.isValid) return false;
    isSubmitting.value = true;
    try {
      final res = await _api.confirm(
        userId: _uid,
        paymentKey: p.paymentKey!,
        orderId: p.orderId!,
        amount: p.amount!,
      );
      if (res.success) {
        await refreshAll();
        return true;
      }
      message.value = res.data is Map ? '${res.data['error'] ?? '승인 실패'}' : '승인 실패';
      return false;
    } catch (_) {
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 환불 신청.
  Future<bool> requestRefund(String orderId, {String reason = ''}) async {
    final uid = _uid;
    if (uid == null) return false;
    isSubmitting.value = true;
    try {
      final res = await _api.requestRefund(userId: uid, orderId: orderId, reason: reason);
      if (res.success) {
        message.value = res.data is Map
            ? '${res.data['message'] ?? '환불 신청이 접수되었습니다.'}'
            : '환불 신청이 접수되었습니다.';
        await loadHistory();
        return true;
      }
      message.value = res.data is Map ? '${res.data['message'] ?? res.data['error'] ?? '신청 실패'}' : '신청 실패';
      return false;
    } catch (_) {
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}

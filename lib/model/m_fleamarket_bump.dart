/// 끌어올리기 응답 모델
class FleamarketBumpResponse {
  String? message;
  String? error;
  int? bumpCount;
  int? remainingTotal;
  int? dailyBumpCount;
  int? remainingToday;

  FleamarketBumpResponse({
    this.message,
    this.error,
    this.bumpCount,
    this.remainingTotal,
    this.dailyBumpCount,
    this.remainingToday,
  });

  FleamarketBumpResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    error = json['error'];
    bumpCount = json['bump_count'];
    remainingTotal = json['remaining_total'];
    dailyBumpCount = json['daily_bump_count'];
    remainingToday = json['remaining_today'];
  }

  bool get isSuccess => error == null && message != null;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'error': error,
      'bump_count': bumpCount,
      'remaining_total': remainingTotal,
      'daily_bump_count': dailyBumpCount,
      'remaining_today': remainingToday,
    };
  }
}
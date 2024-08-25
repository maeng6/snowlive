import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TimeStamp{

  late String agoTime;

  String yyyymmddFormat(Timestamp timestamp) {
    final DateFormat formatter = DateFormat('yyyy.MM.dd');
    final dateTime = timestamp.toDate();
    final formattedDateTime = formatter.format(dateTime);
    return formattedDateTime;
  }


  String getAgo(Timestamp timestamp) {
    DateTime uploadTime = timestamp.toDate();
    DateTime now = DateTime.now();

    Duration difference = now.difference(uploadTime);

    if (difference.inDays >= 30) {
      int months = difference.inDays ~/ 30;
      return '$months개월 전';
    } else if (difference.inDays > 1) {
      return '${difference.inDays}일 전'; // 1일 이상이면 날짜 형식으로 반환
    } else if (difference.inHours > 1) {
      return '${difference.inHours}시간 전'; // 1시간 이상이면 시간 형식으로 반환
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes}분 전'; // 1분 이상이면 분 형식으로 반환
    } else {
      return '방금 전'; // 그 외의 경우 방금 전으로 반환
    }
  }

}

class GetDatetime{

  late String agoTime;

  String yyyymmddFormat(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy.MM.dd');
    final formattedDateTime = formatter.format(dateTime);
    return formattedDateTime;
  }



  String getAgo(DateTime dateTime) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays >= 30) {
      int months = difference.inDays ~/ 30;
      return '$months개월 전';
    } else if (difference.inDays > 1) {
      return '${difference.inDays}일 전'; // 1일 이상이면 날짜 형식으로 반환
    } else if (difference.inHours > 1) {
      return '${difference.inHours}시간 전'; // 1시간 이상이면 시간 형식으로 반환
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes}분 전'; // 1분 이상이면 분 형식으로 반환
    } else {
      return '방금 전'; // 그 외의 경우 방금 전으로 반환
    }
  }

  String getAgoString(String time) {
    DateTime dateTime = DateTime.parse(time); // 문자열을 DateTime으로 변환
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays >= 30) {
      int months = difference.inDays ~/ 30;
      return '$months개월 전';
    } else if (difference.inDays > 1) {
      return '${difference.inDays}일 전'; // 1일 이상이면 날짜 형식으로 반환
    } else if (difference.inHours > 1) {
      return '${difference.inHours}시간 전'; // 1시간 이상이면 시간 형식으로 반환
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes}분 전'; // 1분 이상이면 분 형식으로 반환
    } else {
      return '방금 전'; // 그 외의 경우 방금 전으로 반환
    }
  }

  String getAgo_dateFormat(DateTime dateTime) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays > 1) {
      return DateFormat.yMMMd('ko').format(dateTime); // 1일 이상이면 날짜 형식으로 반환
    } else if (difference.inHours > 1) {
      return '${difference.inHours}시간 전'; // 1시간 이상이면 시간 형식으로 반환
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes}분 전'; // 1분 이상이면 분 형식으로 반환
    } else {
      return '방금 전'; // 그 외의 경우 방금 전으로 반환
    }
  }

  String getDateTime(){
    var now = DateTime.now();
    return DateFormat('yyyy.MM.dd E').format(now);
  }

}

Future<void> otherShare({required String contents}) async {
  final Uri url = Uri.parse(contents);

  if (!await launchUrl(url)) {
    throw "Could not launch $contents";
  }
}
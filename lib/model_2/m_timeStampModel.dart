import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

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

    if (difference.inDays > 1) {
      return DateFormat.yMMMd('ko').format(uploadTime); // 1일 이상이면 날짜 형식으로 반환
    } else if (difference.inHours > 1) {
      return '${difference.inHours}시간 전'; // 1시간 이상이면 시간 형식으로 반환
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes}분 전'; // 1분 이상이면 분 형식으로 반환
    } else {
      return '방금 전'; // 그 외의 경우 방금 전으로 반환
    }
  }

}
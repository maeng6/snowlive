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
    agoTime = Jiffy(uploadTime).fromNow();
    Jiffy.locale('ko');
    return agoTime;
  }

}
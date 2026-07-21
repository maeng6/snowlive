import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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


  String getAgo(DateTime dateTime) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays >= 365) {
      int years = difference.inDays ~/ 365;
      return '$years년 전'; // 1년 이상인 경우 년으로 표현
    } else if (difference.inDays >= 30) {
      int months = difference.inDays ~/ 30;
      return '$months개월 전'; // 1개월 이상인 경우 개월로 표현
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}일 전'; // 1일 이상인 경우 일로 표현
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}시간 전'; // 1시간 이상인 경우 시간으로 표현
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}분 전'; // 1분 이상인 경우 분으로 표현
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

  String yyyymmddFormatFromString(String dateString) {
    // 입력된 문자열을 DateTime으로 파싱
    DateTime? dateTime;
    try {
      dateTime = DateTime.parse(dateString);
    } catch (e) {
      throw FormatException("Invalid date format. Please use 'YYYY-MM-DD'.");
    }

    // 원하는 형식으로 변환
    final DateFormat formatter = DateFormat('yyyy.MM.dd');
    final formattedDateTime = formatter.format(dateTime);
    return formattedDateTime;
  }


  String getAgoString(String time) {
    DateTime dateTime = DateTime.parse(time); // 문자열을 DateTime으로 변환
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays >= 365) {
      int years = difference.inDays ~/ 365;
      return '$years년 전';
    } else if (difference.inDays >= 30) {
      int months = difference.inDays ~/ 30;
      return '$months개월 전';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}일 전'; // 1일 이상이면 날짜 형식으로 반환
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}시간 전'; // 1시간 이상이면 시간 형식으로 반환
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}분 전'; // 1분 이상이면 분 형식으로 반환
    } else {
      return '방금 전'; // 그 외의 경우 방금 전으로 반환
    }
  }




  String getDateTime(){
    var now = DateTime.now();
    return DateFormat('yyyy.MM.dd (E)', 'ko').format(now);
  }

}

Future<void> otherShare({required String contents}) async {
  final Uri url = Uri.parse(contents);

  if (!await launchUrl(url)) {
    throw "Could not launch $contents";
  }
}

Future<void> deleteFolder(String ref, String id) async {
  final storageRef = FirebaseStorage.instance.ref().child('$ref/#$id/');

  // 폴더 내의 모든 파일 가져오기
  final listResult = await storageRef.listAll();

  // 병렬로 파일 삭제 작업 수행
  await Future.wait(listResult.items.map((item) => item.delete()));
  print('파이어베이스 스토리지 이미지 삭제 완료');

  // 폴더 삭제 (비어있는 경우)
  try {
    await storageRef.delete();
    print('빈 폴더 삭제 완료');
  } catch (e) {
    print('빈 폴더 없음: $e');
  }
}


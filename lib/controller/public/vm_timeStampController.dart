import 'package:get/get.dart';
import 'package:com.snowlive/model_2/m_timeStampModel.dart';

class TimeStampController extends GetxController{

  String yyyymmddFormat(timeStamp){
    String getFormatedDate = TimeStamp().yyyymmddFormat(timeStamp);
    return getFormatedDate;
  }

  String getAgoTime(timeStamp){
    String getAgoTime = TimeStamp().getAgo(timeStamp);
    return getAgoTime;
  }

}
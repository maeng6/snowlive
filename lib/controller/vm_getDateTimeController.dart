import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GetDateTimeController extends GetxController{

  @override
  void onInit()  {
    // TODO: implement onInit
    getDateTime();
    super.onInit();
  }

  dynamic date=''.obs;

  String getDateTime(){
    var now = DateTime.now();
    this.date = DateFormat('yyyy.MM.dd E').format(now);
    return date;
  }

}
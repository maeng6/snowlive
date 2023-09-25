import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_splashScreen.dart';

class SplashController extends GetxController{

  String _url='';
  String _localUrl='';
  String get url => _url;
  String get localUrl => _localUrl;

  @override
  void onInit() async {
    // TODO: implement onInit
    await getSplashUrl();
    update();
    super.onInit();
  }

  Future<void> getSplashUrl() async{
    SplashModel splashModel = await SplashModel().getSplashImage();
    this._url = splashModel.modelUrl;
    await FlutterSecureStorage().write(key: 'splashUrl', value: '${splashModel.modelUrl}');

  }

}
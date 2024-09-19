import 'package:com.snowlive/model/m_splash.dart';
import 'package:get/get.dart';

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
    try {
      SplashModel splashModel = await SplashModel().getSplashImage();
      this._url = splashModel.modelUrl;
    }catch(e){
      this._url = 'https://i.esdrop.com/d/f/yytYSNBROy/spAvUnyvK6.png';
    }
  }

}
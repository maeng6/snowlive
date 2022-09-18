import 'package:get/get.dart';
import 'package:snowlive3/model/m_splashScreen.dart';

class SplashController extends GetxController{

  String _url='';
  String get url => _url;

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
  }

}
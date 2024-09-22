import 'package:com.snowlive/model/m_splash.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_authcheck.dart';
import 'package:get/get.dart';

class SplashController extends GetxController{

  @override
  void onInit() async{
    // TODO: implement onInit
    super.onInit();
    await getSplashUrlandGotoMainHome();
  }

  final AuthCheckViewModel controller = Get.find<AuthCheckViewModel>();

  String _url='';
  String _localUrl='';
  String get url => _url;
  String get localUrl => _localUrl;
  bool gotoMainHome = false;



  Future<void> getSplashUrlandGotoMainHome() async{
    try {
      SplashModel splashModel = await SplashModel().getSplashImage();
      gotoMainHome = await controller.userCheck();
      this._url = splashModel.modelUrl;
    }catch(e){
      this._url = 'https://i.esdrop.com/d/f/yytYSNBROy/spAvUnyvK6.png';
    }
  }

}
import 'package:com.snowlive/model/m_splash.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_authcheck.dart';
import 'package:get/get.dart';

class SplashController extends GetxController{



  final AuthCheckViewModel controller = Get.find<AuthCheckViewModel>();

  String _url='';
  String _localUrl='';
  String get url => _url;
  String get localUrl => _localUrl;
  bool gotoMainHome = false;
  RxBool isLoadingUrl = true.obs;

  @override
  void onInit() async{
    // TODO: implement onInit
    super.onInit();
    await loadSplashImage();
  }

  Future<void> userCheck() async{
    try {
      gotoMainHome = await controller.userCheck();
    }catch(e){
      this._url = 'https://i.esdrop.com/d/f/yytYSNBROy/spAvUnyvK6.png';
    }
  }

  Future<void> loadSplashImage() async {
    try {
      SplashModel splashModel = await SplashModel().getSplashImage();
      _url = splashModel.modelUrl;
    } catch (e) {
      _url = 'https://i.esdrop.com/d/f/yytYSNBROy/spAvUnyvK6.png';
    } finally {
      isLoadingUrl.value = false;
      print('스플래시 url 다운완료');
    }
  }

}
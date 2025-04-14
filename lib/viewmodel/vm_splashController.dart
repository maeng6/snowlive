import 'package:com.snowlive/model/m_splash.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_authcheck.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }

  Future<void> userCheck() async{
    try {
      print('2');
      gotoMainHome = await controller.userCheck();
      print('3');
    }catch(e){
      this._url = 'https://i.esdrop.com/d/f/yytYSNBROy/spAvUnyvK6.png';
    }
  }

  Future<void> loadSplashImage() async {
    try {
      SplashModel splashModel = await SplashModel().getSplashImage();
      _url = splashModel.modelUrl;

      // SharedPreferences에 splashUrl 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('splashUrl', _url);

    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('splashUrl', 'https://i.esdrop.com/d/f/yytYSNBROy/it36mfOyr1.png');
    } finally {
      isLoadingUrl.value = false;
      print('스플래시 url 다운완료');
    }
  }

  Future<void> loadLocalSplashUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _url = prefs.getString('splashUrl') ?? 'https://i.esdrop.com/d/f/yytYSNBROy/spAvUnyvK6.png';
    print('로컬에서 splashUrl 불러옴: $_url');
  }

}
import 'package:com.snowlive/model/m_splash.dart';
import 'package:com.snowlive/mobile/viewmodel/auth/vm_authcheck.dart';
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
      // 에러 시 _url 수정하지 않음 - loadLocalSplashUrl()에서 로드한 URL 유지
      print('userCheck 실패: $e');
    }
  }

  Future<void> loadSplashImage() async {
    try {
      SplashModel splashModel = await SplashModel().getSplashImage();
      final newUrl = splashModel.modelUrl;

      // URL이 유효한 경우에만 저장
      if (newUrl.isNotEmpty) {
        _url = newUrl;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('splashUrl', _url);
        print('스플래시 url 새로 저장: $_url');
      }
    } catch (e) {
      // 에러 시 기존 저장된 URL 유지 (덮어쓰지 않음)
      print('스플래시 url 다운로드 실패: $e');
    } finally {
      isLoadingUrl.value = false;
    }
  }

  Future<void> loadLocalSplashUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _url = prefs.getString('splashUrl') ?? 'https://i.esdrop.com/d/f/yytYSNBROy/spAvUnyvK6.png';
    print('로컬에서 splashUrl 불러옴: $_url');
  }

}
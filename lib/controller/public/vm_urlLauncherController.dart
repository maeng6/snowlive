
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherController extends GetxController {

  Future<void> otherShare({required String contents}) async {
    final Uri url = Uri.parse(contents);

    if (!await launchUrl(url)) {
      throw "Could not launch $contents";
    }
  }
}
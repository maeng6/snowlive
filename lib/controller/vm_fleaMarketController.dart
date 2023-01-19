import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snowlive3/model/m_commentModel.dart';
import 'package:snowlive3/model/m_fleaMarketModel.dart';

class FleaModelController extends GetxController {

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> uploadFleaItem(
      {required  displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required itemName,
        required price,
        required location,
        required method,
        required description,
        required fleaCount,
        required resortNickname
      }) async {

    await FleaModel().uploadFleaItem(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        itemImagesUrls: itemImagesUrls,
        title: title,
        category: category,
        itemName: itemName,
        price: price,
        location: location,
        method: method,
        description: description,
        fleaCount: fleaCount,
        resortNickname: resortNickname
    );
  }

  String getAgoTime(timestamp) {
    String time = CommentModel().getAgo(timestamp);
    return time;
  }
}

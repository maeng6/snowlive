import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/imgaUrls/Data_url_image.dart';

class RankingTierModel {
  final String tierName;
  final double scoreRng;
  final int totalScore;
  final String badgeAsset;

  RankingTierModel({required this.tierName, required this.scoreRng, required this.totalScore, required this.badgeAsset });

}

List<RankingTierModel> rankingTierList = [
  RankingTierModel(
    tierName: 'D',
    scoreRng: 1.0,
    totalScore: 0,
    badgeAsset : '${rankingTierUrlList[0].tierD}'
  ),
  RankingTierModel(
    tierName: 'C',
    scoreRng: 0.90,
    totalScore: 100,
      badgeAsset : '${rankingTierUrlList[0].tierC}'
  ),
  RankingTierModel(
    tierName: 'B',
    scoreRng: 0.66,
    totalScore: 200,
      badgeAsset : '${rankingTierUrlList[0].tierB}'
  ),
  RankingTierModel(
    tierName: 'A',
    scoreRng: 0.24,
    totalScore: 300,
      badgeAsset : '${rankingTierUrlList[0].tierA}'
  ),
  RankingTierModel(
    tierName: 'S',
    scoreRng: 0.04,
    totalScore: 400,
      badgeAsset : '${rankingTierUrlList[0].tierS}'
  ),
];

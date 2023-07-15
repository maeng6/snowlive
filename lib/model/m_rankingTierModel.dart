import 'package:google_maps_flutter/google_maps_flutter.dart';

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
    badgeAsset : 'assets/imgs/ranking/icon_ranking_tier_D.png'
  ),
  RankingTierModel(
    tierName: 'C',
    scoreRng: 0.90,
    totalScore: 100,
      badgeAsset : 'assets/imgs/ranking/icon_ranking_tier_C.png'
  ),
  RankingTierModel(
    tierName: 'B',
    scoreRng: 0.66,
    totalScore: 200,
      badgeAsset : 'assets/imgs/ranking/icon_ranking_tier_B.png'
  ),
  RankingTierModel(
    tierName: 'A',
    scoreRng: 0.24,
    totalScore: 300,
      badgeAsset : 'assets/imgs/ranking/icon_ranking_tier_A.png'
  ),
  RankingTierModel(
    tierName: 'S',
    scoreRng: 0.04,
    totalScore: 400,
      badgeAsset : 'assets/imgs/ranking/icon_ranking_tier_S.png'
  ),
];

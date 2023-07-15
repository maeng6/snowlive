import 'package:google_maps_flutter/google_maps_flutter.dart';

class RankingTierModel {
  final String tierName;
  final double scoreRng;
  final int totalScore;

  RankingTierModel({required this.tierName, required this.scoreRng, required this.totalScore});

}

List<RankingTierModel> rankingTierList = [
  RankingTierModel(
    tierName: 'D',
    scoreRng: 1.0,
    totalScore: 0
  ),
  RankingTierModel(
    tierName: 'C',
    scoreRng: 0.90,
    totalScore: 100
  ),
  RankingTierModel(
    tierName: 'B',
    scoreRng: 0.66,
    totalScore: 200
  ),
  RankingTierModel(
    tierName: 'A',
    scoreRng: 0.24,
    totalScore: 300
  ),
  RankingTierModel(
    tierName: 'S',
    scoreRng: 0.04,
    totalScore: 400
  ),
];

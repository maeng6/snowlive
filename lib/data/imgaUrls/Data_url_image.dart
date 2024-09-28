import 'dart:ui';

class ProfileImgUrl {
  final String default_round;
  final String default_suqare;
  final String anony_round;
  final String snowlive_official;

  ProfileImgUrl({
    required this.default_round,
    required this.default_suqare,
    required this.anony_round,
    required this.snowlive_official
  });

}

class RankingTierUrl {
  final String tierD;
  final String tierC;
  final String tierB;
  final String tierA;
  final String tierS;

  RankingTierUrl({
    required this.tierD,
    required this.tierC,
    required this.tierB,
    required this.tierA,
    required this.tierS,
  });

}


class KusbfAssetUrl {
  final String mainLogo;

  KusbfAssetUrl({
    required this.mainLogo,
  });

}

class IconAssetUrl {
  final String filter;

  IconAssetUrl({
    required this.filter,
  });

}


List<ProfileImgUrl> profileImgUrlList = [
  ProfileImgUrl(
    default_round: 'https://i.esdrop.com/d/f/yytYSNBROy/NIlGn0N46O.png',
    default_suqare: 'https://i.esdrop.com/d/f/yytYSNBROy/6rPYflzCCZ.png',
    anony_round: 'https://i.esdrop.com/d/f/yytYSNBROy/JgMO4cLHTW.png',
    snowlive_official : 'https://i.esdrop.com/d/f/yytYSNBROy/0e1CZIxevJ.jpg',
  ),
];

List<RankingTierUrl> rankingTierUrlList = [
  RankingTierUrl(
    tierD: 'https://i.esdrop.com/d/f/yytYSNBROy/XdOyef6TBl.png',
    tierC: 'https://i.esdrop.com/d/f/yytYSNBROy/bilTq2pBeV.png',
    tierB: 'https://i.esdrop.com/d/f/yytYSNBROy/00dk3Ku3r1.png',
    tierA : 'https://i.esdrop.com/d/f/yytYSNBROy/l64DLQ5f3u.png',
    tierS : 'https://i.esdrop.com/d/f/yytYSNBROy/uxsqBeErnC.png',
  ),
];

Map<String, String> crewDefaultLogoUrl = {

  "0XFFEA4E4E": 'https://i.esdrop.com/d/f/yytYSNBROy/wIJ17SLObC.png',
  "0XFFFD6D04": 'https://i.esdrop.com/d/f/yytYSNBROy/JrVtDA58J9.png',
  "0XFFFDAF04": 'https://i.esdrop.com/d/f/yytYSNBROy/QP4cG3vjk3.png',
  "0XFF37CBA8": 'https://i.esdrop.com/d/f/yytYSNBROy/9FdGigpyYO.png',
  "0XFF68A1F6": 'https://i.esdrop.com/d/f/yytYSNBROy/jolYV66aQZ.png',
  "0XFF9241F9": 'https://i.esdrop.com/d/f/yytYSNBROy/GizZEbY9JS.png',
  "0XFF0D4CA9": 'https://i.esdrop.com/d/f/yytYSNBROy/Md8NI0Tkki.png',
  "0XFF5E6B7F": 'https://i.esdrop.com/d/f/yytYSNBROy/V7BdtuFI9r.png',

};


List<KusbfAssetUrl> KusbfAssetUrlList = [
  KusbfAssetUrl(
    mainLogo: 'https://i.esdrop.com/d/f/yytYSNBROy/aYg5y9C2Wa.png',
  ),
];

List<IconAssetUrl> IconAssetUrlList = [
  IconAssetUrl(
    filter: 'https://i.esdrop.com/d/f/yytYSNBROy/WD1ovQIAOq.png',
  ),
];

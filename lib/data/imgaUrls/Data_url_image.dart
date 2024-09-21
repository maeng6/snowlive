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

  "0XFFFFA835": 'https://i.esdrop.com/d/f/yytYSNBROy/G017nvg1rV.png',
  "0XFF2EB6FF": 'https://i.esdrop.com/d/f/yytYSNBROy/MhoKgYVdel.png',
  "0XFFFF54A0": 'https://i.esdrop.com/d/f/yytYSNBROy/ecIhTcQfBC.png',
  "0XFF10BB88": 'https://i.esdrop.com/d/f/yytYSNBROy/3Z334m5Bf3.png',
  "0XFFB173FF": 'https://i.esdrop.com/d/f/yytYSNBROy/AEc8rqvTTO.png',
  "0XFFFF5F18": 'https://i.esdrop.com/d/f/yytYSNBROy/R3kA6TprLZ.png',
  "0XFF326EF6": 'https://i.esdrop.com/d/f/yytYSNBROy/pXOiCC6n3G.png',
  "0XFFEF0069": 'https://i.esdrop.com/d/f/yytYSNBROy/lBsRF5aLqb.png',
  "0XFF019D78": 'https://i.esdrop.com/d/f/yytYSNBROy/zvA5hiKedr.png',
  "0XFF772ED3": 'https://i.esdrop.com/d/f/yytYSNBROy/XJyCNPi4nS.png',

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

import 'package:com.snowlive/core/model/m_liveTalk.dart';

/// 크루홈의 크루 1개 항목(카드). 공통 필드 + 그 리스트에서만 채워지는 지표(nullable).
class CrewCard {
  final int? crewId;
  final String? crewName;
  final String? crewLogoUrl;
  final String? color;
  final String? description;
  final int? baseResortId;
  final String? baseResortNickname;
  final int? memberCount;

  // ── 리스트별 지표(해당 리스트에서만 값이 있음) ──
  final int? occupiedSlopeCount; // slope_occupied: 점령 슬로프 수
  final int? resortCount;        // diverse_resort: 탄 리조트 종류 수
  final num? todayScore;         // today_score: 오늘 획득 랭킹점수
  final int? liveonTodayCount;   // liveon_today: 오늘 라이브온 인원
  final int? liveonSeasonCount;  // liveon_season: 이번시즌 라이브온 인원
  final double? ratio;           // ski/board_majority: 비율(0~1)
  final int? count;              // ski/board_majority: 스키어/보더 인원수

  CrewCard({
    this.crewId,
    this.crewName,
    this.crewLogoUrl,
    this.color,
    this.description,
    this.baseResortId,
    this.baseResortNickname,
    this.memberCount,
    this.occupiedSlopeCount,
    this.resortCount,
    this.todayScore,
    this.liveonTodayCount,
    this.liveonSeasonCount,
    this.ratio,
    this.count,
  });

  factory CrewCard.fromJson(Map<String, dynamic> json) {
    return CrewCard(
      crewId: json['crew_id'],
      crewName: json['crew_name'],
      crewLogoUrl: json['crew_logo_url'],
      color: json['color'],
      description: json['description'],
      baseResortId: json['base_resort_id'],
      baseResortNickname: json['base_resort_nickname'],
      memberCount: json['member_count'],
      occupiedSlopeCount: json['occupied_slope_count'],
      resortCount: json['resort_count'],
      todayScore: json['today_score'],
      liveonTodayCount: json['liveon_today_count'],
      liveonSeasonCount: json['liveon_season_count'],
      ratio: (json['ratio'] as num?)?.toDouble(),
      count: json['count'],
    );
  }

  static List<CrewCard> listFrom(dynamic raw) {
    if (raw is! List) return [];
    final out = <CrewCard>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) out.add(CrewCard.fromJson(e));
    }
    return out;
  }
}

/// 중단 "스키장별 크루 리스트" 1개 리조트 블록.
class CrewHomeResortGroup {
  final int? resortId;
  final String? resortNickname;
  final String? resortFullname;
  final List<CrewCard> crews;

  CrewHomeResortGroup({
    this.resortId,
    this.resortNickname,
    this.resortFullname,
    List<CrewCard>? crews,
  }) : crews = crews ?? [];

  factory CrewHomeResortGroup.fromJson(Map<String, dynamic> json) {
    return CrewHomeResortGroup(
      resortId: json['resort_id'],
      resortNickname: json['resort_nickname'],
      resortFullname: json['resort_fullname'],
      crews: CrewCard.listFrom(json['crews']),
    );
  }
}

/// 크루홈 전체 응답. 상단 5리스트 + 중단(스키장별 + 4리스트) + 하단(공개 크루톡).
class CrewHomeModel {
  // 상단
  final List<CrewCard> newestCrews;    // 신생 크루
  final List<CrewCard> liveonToday;    // 오늘 라이브온 많은 크루
  final List<CrewCard> slopeOccupied;  // 슬로프 많이 점령한 크루
  final List<CrewCard> diverseResort;  // 다양한 스키장 라이딩 크루
  final List<CrewCard> todayScore;     // 오늘 점수 많은 크루

  // 중단
  final List<CrewHomeResortGroup> byResort; // 스키장별(리조트별 30)
  final List<CrewCard> mostMembers;         // 크루원 많은 순
  final List<CrewCard> liveonSeason;        // 이번시즌 라이브온 많은
  final List<CrewCard> skiMajority;         // 스키 비율 50% 초과(10명 이상)
  final List<CrewCard> boardMajority;       // 보더 비율 50% 초과(10명 이상)

  // 하단
  final List<LiveTalk> crewTalks; // 공개 크루톡 최신 20

  CrewHomeModel({
    List<CrewCard>? newestCrews,
    List<CrewCard>? liveonToday,
    List<CrewCard>? slopeOccupied,
    List<CrewCard>? diverseResort,
    List<CrewCard>? todayScore,
    List<CrewHomeResortGroup>? byResort,
    List<CrewCard>? mostMembers,
    List<CrewCard>? liveonSeason,
    List<CrewCard>? skiMajority,
    List<CrewCard>? boardMajority,
    List<LiveTalk>? crewTalks,
  })  : newestCrews = newestCrews ?? [],
        liveonToday = liveonToday ?? [],
        slopeOccupied = slopeOccupied ?? [],
        diverseResort = diverseResort ?? [],
        todayScore = todayScore ?? [],
        byResort = byResort ?? [],
        mostMembers = mostMembers ?? [],
        liveonSeason = liveonSeason ?? [],
        skiMajority = skiMajority ?? [],
        boardMajority = boardMajority ?? [],
        crewTalks = crewTalks ?? [];

  factory CrewHomeModel.fromJson(Map<String, dynamic> json) {
    final top = (json['top'] as Map<String, dynamic>?) ?? {};
    final middle = (json['middle'] as Map<String, dynamic>?) ?? {};
    final bottom = (json['bottom'] as Map<String, dynamic>?) ?? {};

    final byResortRaw = middle['by_resort'];
    final byResort = <CrewHomeResortGroup>[];
    if (byResortRaw is List) {
      for (final e in byResortRaw) {
        if (e is Map<String, dynamic>) byResort.add(CrewHomeResortGroup.fromJson(e));
      }
    }

    final talksRaw = bottom['crew_talks'];
    final talks = <LiveTalk>[];
    if (talksRaw is List) {
      for (final e in talksRaw) {
        if (e is Map<String, dynamic>) talks.add(LiveTalk.fromJson(e));
      }
    }

    return CrewHomeModel(
      newestCrews: CrewCard.listFrom(top['newest_crews']),
      liveonToday: CrewCard.listFrom(top['liveon_today']),
      slopeOccupied: CrewCard.listFrom(top['slope_occupied']),
      diverseResort: CrewCard.listFrom(top['diverse_resort']),
      todayScore: CrewCard.listFrom(top['today_score']),
      byResort: byResort,
      mostMembers: CrewCard.listFrom(middle['most_members']),
      liveonSeason: CrewCard.listFrom(middle['liveon_season']),
      skiMajority: CrewCard.listFrom(middle['ski_majority']),
      boardMajority: CrewCard.listFrom(middle['board_majority']),
      crewTalks: talks,
    );
  }
}

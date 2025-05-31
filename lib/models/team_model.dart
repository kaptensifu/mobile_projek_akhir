class Team {
  final String teamId;
  final String teamName;
  final String teamNationality;
  final int? firstAppearance;
  final int? constructorsChampionships;
  final int? driversChampionships;
  final String url;

  Team({
    required this.teamId,
    required this.teamName,
    required this.teamNationality,
    this.firstAppearance,
    this.constructorsChampionships,
    this.driversChampionships,
    required this.url,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamId: json['teamId'] ?? '',
      teamName: json['teamName'] ?? '',
      teamNationality: json['teamNationality'] ?? '',
      firstAppearance: int.tryParse(json['firstAppeareance'].toString()) ?? 0,
      constructorsChampionships: int.tryParse(json['constructorsChampionships'].toString()) ?? 0,
      driversChampionships: int.tryParse(json['driversChampionships'].toString()) ?? 0,
      url: json['url'] ?? '',
    );
  }
}

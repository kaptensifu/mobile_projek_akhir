class Circuit {
  final String circuitId;
  final String circuitName;
  final String country;
  final String city;
  final int circuitLength;
  final String lapRecord;
  final int firstParticipationYear;
  final int numberOfCorners;
  final String fastestLapDriverId;
  final String fastestLapTeamId;
  final int fastestLapYear;
  final String url;

  Circuit({
    required this.circuitId,
    required this.circuitName,
    required this.country,
    required this.city,
    required this.circuitLength,
    required this.lapRecord,
    required this.firstParticipationYear,
    required this.numberOfCorners,
    required this.fastestLapDriverId,
    required this.fastestLapTeamId,
    required this.fastestLapYear,
    required this.url,
  });

  factory Circuit.fromJson(Map<String, dynamic> json) {
    return Circuit(
      circuitId: json['circuitId'],
      circuitName: json['circuitName'],
      country: json['country'],
      city: json['city'],
      circuitLength: json['circuitLength'],
      lapRecord: json['lapRecord'],
      firstParticipationYear: json['firstParticipationYear'],
      numberOfCorners: json['numberOfCorners'],
      fastestLapDriverId: json['fastestLapDriverId'],
      fastestLapTeamId: json['fastestLapTeamId'],
      fastestLapYear: json['fastestLapYear'],
      url: json['url'],
    );
  }
}

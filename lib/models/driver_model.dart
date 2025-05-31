class Driver {
  final String driverId;
  final String name;
  final String surname;
  final String nationality;
  final String birthday;
  final int? number;
  final String? shortName;
  final String url;

  Driver({
    required this.driverId,
    required this.name,
    required this.surname,
    required this.nationality,
    required this.birthday,
    this.number,
    this.shortName,
    required this.url,
  });

  String get fullName => '$name $surname';
  
  String get formattedBirthday {
    try {
      final date = DateTime.parse(birthday);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return birthday;
    }
  }

  int get age {
    try {
      final birthDate = DateTime.parse(birthday);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month || 
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driverId'] ?? '',
      name: json['name'] ?? 'Unknown',
      surname: json['surname'] ?? 'Unknown',
      nationality: json['nationality'] ?? 'Unknown',
      birthday: json['birthday'] ?? '',
      number: json['number'],
      shortName: json['shortName'],
      url: json['url'] ?? '',
    );
  }
}
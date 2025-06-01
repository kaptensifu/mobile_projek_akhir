class Competition {
  final int? id;
  final String title;
  final String? description;
  final String circuitId;
  final String circuitName;
  final DateTime startTime;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Competition({
    this.id,
    required this.title,
    this.description,
    required this.circuitId,
    required this.circuitName,
    required this.startTime,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'circuit_id': circuitId,
      'circuit_name': circuitName,
      'start_time': startTime.millisecondsSinceEpoch,
      'created_by': createdBy,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Competition.fromMap(Map<String, dynamic> map) {
    return Competition(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      circuitId: map['circuit_id'],
      circuitName: map['circuit_name'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      createdBy: map['created_by'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  Competition copyWith({
    int? id,
    String? title,
    String? description,
    String? circuitId,
    String? circuitName,
    DateTime? startTime,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Competition(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      circuitId: circuitId ?? this.circuitId,
      circuitName: circuitName ?? this.circuitName,
      startTime: startTime ?? this.startTime,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedStartTime {
    return '${startTime.day.toString().padLeft(2, '0')}/${startTime.month.toString().padLeft(2, '0')}/${startTime.year} ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }
}
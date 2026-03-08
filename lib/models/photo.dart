class Photo {
  final String id;
  final String path;
  final DateTime createdAt;

  Photo({
    required this.id,
    required this.path,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    id: json['id'],
    path: json['path'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
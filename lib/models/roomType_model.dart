class RoomType {
  final String id;
  final String name;

  RoomType({required this.id, required this.name});

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

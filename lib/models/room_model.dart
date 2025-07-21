class Room {
  final String? id;
  final String name;
  final String image;
  final String price;
  final String type;
  final String rate;
  final String location;
  final bool isFavorited;
  final List<String> albumImages;
  final String description;

  Room({
    this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.type,
    required this.rate,
    required this.location,
    required this.isFavorited,
    required this.albumImages,
    required this.description,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id']?.toString(),
      name: json['name'],
      image: json['image'],
      price: json['price']?.toString() ?? '',
      type: json['type'],
      rate: json['rate']?.toString() ?? '',
      location: json['location'] ?? '',
      isFavorited: json['is_favorited'] ?? false,
      albumImages: json['album_images'] != null
          ? List<String>.from(json['album_images'])
          : <String>[],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'type': type,
      'rate': rate,
      'location': location,
      'is_favorited': isFavorited,
      'album_images': albumImages,
      'description': description,
    };
  }
  
}

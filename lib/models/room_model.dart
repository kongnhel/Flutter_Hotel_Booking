class Room {
  final String? id;
  final String name;
  final String image;
  final String price;
  final String roomTypeId;
  final String rate;
  final String location;
  final bool isFavorited;
  final bool isBooked; // ✅ បន្ថែម field នេះ
  final List<String> albumImages;
  final String description;

  Room({
    this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.roomTypeId,
    required this.rate,
    required this.location,
    required this.isFavorited,
    required this.isBooked, // ✅ បន្ថែមនៅ constructor
    required this.albumImages,
    required this.description,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: json['price']?.toString() ?? '',
      roomTypeId: json['roomTypeId'] ?? '',
      rate: json['rate']?.toString() ?? '',
      location: json['location'] ?? '',
      isFavorited: json['is_favorited'] ?? false,
      isBooked: json['isBooked'] ?? false, // ✅ ទទួលពី API

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
      'roomTypeId': roomTypeId,
      'rate': rate,
      'location': location,
      'is_favorited': isFavorited,
      'isBooked': isBooked, // ✅ បញ្ចូលក្នុង JSON
      'album_images': albumImages,
      'description': description,
    };
  }
}

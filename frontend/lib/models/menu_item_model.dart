class MenuItemModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;
  final bool available;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    required this.available,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    final priceRaw = json['price'];
    final availableRaw = json['available'];

    return MenuItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: (json['description'] ?? '') as String,
      price: priceRaw is num
          ? priceRaw.toDouble()
          : double.parse(priceRaw as String),
      category: json['category'] as String,
      imageUrl: json['image_url'] as String?,
      available: availableRaw is bool
          ? availableRaw
          : availableRaw == 1 || availableRaw == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'available': available,
    };
  }
}

class PackageItem {
  final String title;
  final String description;
  final double price;
  final String details;

  PackageItem({
    required this.title,
    required this.description,
    required this.price,
    this.details = '',
  });

  // Factory method to create from Firestore document
  factory PackageItem.fromMap(String id, Map<String, dynamic> data) {
    return PackageItem(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      details: data['details'] ?? '',
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'details': details,
    };
  }
}
class FoodItem {
  final String name;
  final double carbAmount;
  int consumedCount;

  FoodItem({
    required this.name,
    required this.carbAmount,
    this.consumedCount = 0,
  });
}

class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final List<String> features;
  final bool isPremium;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    this.isPremium = false,
  });
}

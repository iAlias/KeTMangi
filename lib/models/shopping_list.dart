import 'ingredient.dart';

/// Represents the shopping list generated from an approved meal plan.
class ShoppingList {
  final String id;
  final String mealPlanId;
  final DateTime createdAt;
  final List<ShoppingItem> items;
  final double estimatedCostMin;
  final double estimatedCostMax;

  const ShoppingList({
    required this.id,
    required this.mealPlanId,
    required this.createdAt,
    required this.items,
    this.estimatedCostMin = 0,
    this.estimatedCostMax = 0,
  });

  ShoppingList copyWith({
    String? id,
    String? mealPlanId,
    DateTime? createdAt,
    List<ShoppingItem>? items,
    double? estimatedCostMin,
    double? estimatedCostMax,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      estimatedCostMin: estimatedCostMin ?? this.estimatedCostMin,
      estimatedCostMax: estimatedCostMax ?? this.estimatedCostMax,
    );
  }

  /// Groups shopping items by ingredient category.
  Map<IngredientCategory, List<ShoppingItem>> get itemsByCategory {
    final result = <IngredientCategory, List<ShoppingItem>>{};
    for (final item in items) {
      final category = item.ingredient.category;
      result.putIfAbsent(category, () => []).add(item);
    }
    return result;
  }

  /// Number of items not yet purchased.
  int get remainingCount => items.where((i) => !i.isPurchased && !i.alreadyOwned).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'mealPlanId': mealPlanId,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'estimatedCostMin': estimatedCostMin,
        'estimatedCostMax': estimatedCostMax,
      };

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
        id: json['id'] as String,
        mealPlanId: json['mealPlanId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        items: (json['items'] as List)
            .map((i) => ShoppingItem.fromJson(i as Map<String, dynamic>))
            .toList(),
        estimatedCostMin: (json['estimatedCostMin'] as num?)?.toDouble() ?? 0,
        estimatedCostMax: (json['estimatedCostMax'] as num?)?.toDouble() ?? 0,
      );
}

/// A single item in the shopping list.
class ShoppingItem {
  final Ingredient ingredient;
  final double totalQuantity;
  final String displayUnit;
  final bool isPurchased;
  final bool alreadyOwned;
  final int? suggestedShelfLifeDays;

  const ShoppingItem({
    required this.ingredient,
    required this.totalQuantity,
    required this.displayUnit,
    this.isPurchased = false,
    this.alreadyOwned = false,
    this.suggestedShelfLifeDays,
  });

  ShoppingItem copyWith({
    Ingredient? ingredient,
    double? totalQuantity,
    String? displayUnit,
    bool? isPurchased,
    bool? alreadyOwned,
    int? suggestedShelfLifeDays,
  }) {
    return ShoppingItem(
      ingredient: ingredient ?? this.ingredient,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      displayUnit: displayUnit ?? this.displayUnit,
      isPurchased: isPurchased ?? this.isPurchased,
      alreadyOwned: alreadyOwned ?? this.alreadyOwned,
      suggestedShelfLifeDays:
          suggestedShelfLifeDays ?? this.suggestedShelfLifeDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'ingredient': ingredient.toJson(),
        'totalQuantity': totalQuantity,
        'displayUnit': displayUnit,
        'isPurchased': isPurchased,
        'alreadyOwned': alreadyOwned,
        'suggestedShelfLifeDays': suggestedShelfLifeDays,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        ingredient:
            Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
        totalQuantity: (json['totalQuantity'] as num).toDouble(),
        displayUnit: json['displayUnit'] as String,
        isPurchased: json['isPurchased'] as bool? ?? false,
        alreadyOwned: json['alreadyOwned'] as bool? ?? false,
        suggestedShelfLifeDays: json['suggestedShelfLifeDays'] as int?,
      );
}

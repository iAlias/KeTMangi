import '../models/models.dart';

/// Service responsible for generating shopping lists from approved meal plans.
class ShoppingListGenerator {
  /// Generates a shopping list from a meal plan by aggregating all
  /// recipe ingredients, removing duplicates, and organizing by category.
  ///
  /// Optionally takes pantry items to exclude ingredients already in stock.
  ShoppingList generateFromMealPlan({
    required MealPlan mealPlan,
    required String listId,
    List<PantryItem> pantryItems = const [],
  }) {
    final aggregated = <String, _AggregatedIngredient>{};

    // Collect all ingredients from all meals in the plan
    for (final day in mealPlan.days) {
      _addRecipeIngredients(day.lunch, aggregated);
      _addRecipeIngredients(day.dinner, aggregated);
    }

    // Build shopping items
    final items = <ShoppingItem>[];
    for (final entry in aggregated.values) {
      final pantryItem = _findInPantry(entry.ingredient, pantryItems);
      final alreadyOwned = pantryItem != null &&
          pantryItem.quantityInStock >= entry.totalQuantity;

      items.add(ShoppingItem(
        ingredient: entry.ingredient,
        totalQuantity: _roundToCommercialQuantity(entry.totalQuantity, entry.unit),
        displayUnit: entry.unit,
        alreadyOwned: alreadyOwned,
        suggestedShelfLifeDays: entry.ingredient.defaultShelfLifeDays,
      ));
    }

    // Sort by category order: fresh → pantry → frozen → staple
    items.sort((a, b) {
      final catOrder = a.ingredient.category.index.compareTo(b.ingredient.category.index);
      if (catOrder != 0) return catOrder;
      return a.ingredient.name.compareTo(b.ingredient.name);
    });

    return ShoppingList(
      id: listId,
      mealPlanId: mealPlan.id,
      createdAt: DateTime.now(),
      items: items,
      estimatedCostMin: _estimateCost(items, 0.85),
      estimatedCostMax: _estimateCost(items, 1.15),
    );
  }

  /// Adds ingredients from a recipe to the aggregated map.
  void _addRecipeIngredients(
      Recipe? recipe, Map<String, _AggregatedIngredient> aggregated) {
    if (recipe == null) return;

    for (final ri in recipe.ingredients) {
      final key = ri.ingredient.id;
      if (aggregated.containsKey(key)) {
        aggregated[key] = aggregated[key]!.addQuantity(ri.quantity);
      } else {
        aggregated[key] = _AggregatedIngredient(
          ingredient: ri.ingredient,
          totalQuantity: ri.quantity,
          unit: ri.unit,
        );
      }
    }
  }

  /// Finds a matching pantry item for the given ingredient.
  PantryItem? _findInPantry(
      Ingredient ingredient, List<PantryItem> pantryItems) {
    for (final item in pantryItems) {
      if (item.ingredient.id == ingredient.id &&
          item.status == PantryStatus.available) {
        return item;
      }
    }
    return null;
  }

  /// Rounds a quantity to a typical commercial package size.
  double _roundToCommercialQuantity(double quantity, String unit) {
    if (unit == 'g' || unit == 'ml') {
      // Round up to nearest 50g/ml
      return (quantity / 50).ceil() * 50.0;
    }
    if (unit == 'kg' || unit == 'l') {
      // Round up to nearest 0.25
      return (quantity / 0.25).ceil() * 0.25;
    }
    // For pieces, round up to nearest integer
    return quantity.ceilToDouble();
  }

  /// Estimates the cost of the shopping list with a multiplier.
  double _estimateCost(List<ShoppingItem> items, double multiplier) {
    // Base price estimation per unit (simplified)
    var total = 0.0;
    for (final item in items) {
      if (item.alreadyOwned) continue;

      double unitPrice;
      switch (item.ingredient.category) {
        case IngredientCategory.fresh:
          unitPrice = 0.008; // ~€8/kg
          break;
        case IngredientCategory.pantry:
          unitPrice = 0.003; // ~€3/kg
          break;
        case IngredientCategory.frozen:
          unitPrice = 0.005; // ~€5/kg
          break;
        case IngredientCategory.staple:
          unitPrice = 0.004; // ~€4/kg
          break;
      }

      total += item.totalQuantity * unitPrice;
    }
    return double.parse((total * multiplier).toStringAsFixed(2));
  }
}

class _AggregatedIngredient {
  final Ingredient ingredient;
  final double totalQuantity;
  final String unit;

  const _AggregatedIngredient({
    required this.ingredient,
    required this.totalQuantity,
    required this.unit,
  });

  _AggregatedIngredient addQuantity(double quantity) {
    return _AggregatedIngredient(
      ingredient: ingredient,
      totalQuantity: totalQuantity + quantity,
      unit: unit,
    );
  }
}

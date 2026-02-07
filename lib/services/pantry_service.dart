import '../models/models.dart';

/// Service responsible for managing pantry items, tracking expiry dates,
/// and handling the "Non cucino" (not cooking) flow.
class PantryService {
  /// Returns pantry items sorted by expiry urgency (most critical first).
  List<PantryItem> sortByUrgency(List<PantryItem> items) {
    final sorted = List<PantryItem>.from(items);
    sorted.sort((a, b) {
      // Items without expiry go to the end
      if (a.daysUntilExpiry == null && b.daysUntilExpiry == null) {
        return a.ingredient.name.compareTo(b.ingredient.name);
      }
      if (a.daysUntilExpiry == null) return 1;
      if (b.daysUntilExpiry == null) return -1;
      return a.daysUntilExpiry!.compareTo(b.daysUntilExpiry!);
    });
    return sorted;
  }

  /// Returns items that are expiring within the given number of days.
  List<PantryItem> getExpiringItems(List<PantryItem> items, {int withinDays = 2}) {
    return items.where((item) {
      final days = item.daysUntilExpiry;
      return days != null && days >= 0 && days <= withinDays;
    }).toList();
  }

  /// Returns items that have already expired.
  List<PantryItem> getExpiredItems(List<PantryItem> items) {
    return items.where((item) => item.isExpired).toList();
  }

  /// Returns items filtered by category.
  List<PantryItem> filterByCategory(
      List<PantryItem> items, IngredientCategory category) {
    return items
        .where((item) => item.ingredient.category == category)
        .toList();
  }

  /// Searches pantry items by ingredient name (case-insensitive).
  List<PantryItem> search(List<PantryItem> items, String query) {
    final lower = query.toLowerCase();
    return items
        .where(
            (item) => item.ingredient.name.toLowerCase().contains(lower))
        .toList();
  }

  /// Counts items that need urgent attention (expiring within 2 days).
  int getUrgentCount(List<PantryItem> items) {
    return items.where((item) => item.urgency == ExpiryUrgency.critical).length;
  }

  /// Handles the "Non cucino" flow by processing a skipped meal.
  /// Returns updated pantry items and the action taken.
  SkipMealResult handleSkippedMeal({
    required Recipe recipe,
    required List<PantryItem> pantryItems,
    required SkipMealAction action,
  }) {
    switch (action) {
      case SkipMealAction.moveToAnotherDay:
        // No pantry changes, just mark the meal as moved
        return SkipMealResult(
          updatedPantryItems: pantryItems,
          action: action,
          wasteValue: 0,
        );

      case SkipMealAction.alreadyUsed:
        // Mark recipe ingredients as used in pantry
        final updated = _markIngredientsUsed(recipe, pantryItems);
        return SkipMealResult(
          updatedPantryItems: updated,
          action: action,
          wasteValue: 0,
        );

      case SkipMealAction.leaveInPantry:
        // No changes, continue monitoring
        return SkipMealResult(
          updatedPantryItems: pantryItems,
          action: action,
          wasteValue: 0,
        );

      case SkipMealAction.wasted:
        // Mark as wasted and calculate value
        final wasteValue = _calculateWasteValue(recipe, pantryItems);
        final updated = _markIngredientsWasted(recipe, pantryItems);
        return SkipMealResult(
          updatedPantryItems: updated,
          action: action,
          wasteValue: wasteValue,
        );
    }
  }

  List<PantryItem> _markIngredientsUsed(
      Recipe recipe, List<PantryItem> pantryItems) {
    final result = List<PantryItem>.from(pantryItems);
    for (final ri in recipe.ingredients) {
      final index = result
          .indexWhere((p) => p.ingredient.id == ri.ingredient.id);
      if (index >= 0) {
        result[index] = result[index].copyWith(status: PantryStatus.used);
      }
    }
    return result;
  }

  List<PantryItem> _markIngredientsWasted(
      Recipe recipe, List<PantryItem> pantryItems) {
    final result = List<PantryItem>.from(pantryItems);
    for (final ri in recipe.ingredients) {
      final index = result
          .indexWhere((p) => p.ingredient.id == ri.ingredient.id);
      if (index >= 0) {
        result[index] = result[index].copyWith(status: PantryStatus.wasted);
      }
    }
    return result;
  }

  double _calculateWasteValue(Recipe recipe, List<PantryItem> pantryItems) {
    var total = 0.0;
    for (final ri in recipe.ingredients) {
      // Simplified cost estimation
      double unitPrice;
      switch (ri.ingredient.category) {
        case IngredientCategory.fresh:
          unitPrice = 0.008;
          break;
        case IngredientCategory.pantry:
          unitPrice = 0.003;
          break;
        case IngredientCategory.frozen:
          unitPrice = 0.005;
          break;
        case IngredientCategory.staple:
          unitPrice = 0.004;
          break;
      }
      total += ri.quantity * unitPrice;
    }
    return double.parse(total.toStringAsFixed(2));
  }
}

/// Actions available when skipping a planned meal.
enum SkipMealAction {
  moveToAnotherDay,  // 🔄 Sposta a un altro giorno
  alreadyUsed,       // ✅ Ho già usato gli ingredienti
  leaveInPantry,     // 📦 Lasciali in dispensa
  wasted,            // 🗑️ Elimina tutto (sprecato)
}

/// Result of handling a skipped meal.
class SkipMealResult {
  final List<PantryItem> updatedPantryItems;
  final SkipMealAction action;
  final double wasteValue;

  const SkipMealResult({
    required this.updatedPantryItems,
    required this.action,
    required this.wasteValue,
  });
}

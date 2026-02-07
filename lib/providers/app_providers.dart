import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Provider for the MealPlanGenerator service.
final mealPlanGeneratorProvider = Provider<MealPlanGenerator>((ref) {
  return MealPlanGenerator();
});

/// Provider for the ShoppingListGenerator service.
final shoppingListGeneratorProvider = Provider<ShoppingListGenerator>((ref) {
  return ShoppingListGenerator();
});

/// Provider for the PantryService.
final pantryServiceProvider = Provider<PantryService>((ref) {
  return PantryService();
});

/// Provider for the recipe catalog.
final recipeCatalogProvider = Provider<List<Recipe>>((ref) {
  return RecipeCatalog.recipes;
});

/// State provider for the current user profile.
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});

/// State notifier for managing user profile.
class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null);

  void setProfile(UserProfile profile) {
    state = profile;
  }

  void updateProfile(UserProfile Function(UserProfile) updater) {
    if (state != null) {
      state = updater(state!);
    }
  }

  void clearProfile() {
    state = null;
  }
}

/// State provider for the current meal plan.
final currentMealPlanProvider = StateNotifierProvider<MealPlanNotifier, MealPlan?>((ref) {
  return MealPlanNotifier();
});

/// State notifier for managing the current meal plan.
class MealPlanNotifier extends StateNotifier<MealPlan?> {
  MealPlanNotifier() : super(null);

  void setPlan(MealPlan plan) {
    state = plan;
  }

  void approvePlan() {
    if (state != null) {
      state = state!.copyWith(
        status: MealPlanStatus.approved,
        approvedAt: DateTime.now(),
      );
    }
  }

  void updateMealStatus(DateTime date, bool isLunch, MealStatus status) {
    if (state == null) return;
    final days = state!.days.map((day) {
      if (day.date == date) {
        return isLunch
            ? day.copyWith(lunchStatus: status)
            : day.copyWith(dinnerStatus: status);
      }
      return day;
    }).toList();
    state = state!.copyWith(days: days);
  }

  void swapMeals(DateTime date1, bool isLunch1, DateTime date2, bool isLunch2) {
    if (state == null) return;

    Recipe? meal1;
    Recipe? meal2;

    for (final day in state!.days) {
      if (day.date == date1) {
        meal1 = isLunch1 ? day.lunch : day.dinner;
      }
      if (day.date == date2) {
        meal2 = isLunch2 ? day.lunch : day.dinner;
      }
    }

    final days = state!.days.map((day) {
      if (day.date == date1) {
        return isLunch1
            ? day.copyWith(lunch: meal2)
            : day.copyWith(dinner: meal2);
      }
      if (day.date == date2) {
        return isLunch2
            ? day.copyWith(lunch: meal1)
            : day.copyWith(dinner: meal1);
      }
      return day;
    }).toList();
    state = state!.copyWith(days: days);
  }

  void clearPlan() {
    state = null;
  }
}

/// State provider for the current shopping list.
final currentShoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, ShoppingList?>((ref) {
  return ShoppingListNotifier();
});

/// State notifier for managing the shopping list.
class ShoppingListNotifier extends StateNotifier<ShoppingList?> {
  ShoppingListNotifier() : super(null);

  void setList(ShoppingList list) {
    state = list;
  }

  void togglePurchased(int index) {
    if (state == null) return;
    final items = List<ShoppingItem>.from(state!.items);
    items[index] = items[index].copyWith(isPurchased: !items[index].isPurchased);
    state = state!.copyWith(items: items);
  }

  void toggleAlreadyOwned(int index) {
    if (state == null) return;
    final items = List<ShoppingItem>.from(state!.items);
    items[index] = items[index].copyWith(alreadyOwned: !items[index].alreadyOwned);
    state = state!.copyWith(items: items);
  }

  void clearList() {
    state = null;
  }
}

/// State provider for pantry items.
final pantryItemsProvider =
    StateNotifierProvider<PantryItemsNotifier, List<PantryItem>>((ref) {
  return PantryItemsNotifier();
});

/// State notifier for managing pantry items.
class PantryItemsNotifier extends StateNotifier<List<PantryItem>> {
  PantryItemsNotifier() : super([]);

  void addItem(PantryItem item) {
    state = [...state, item];
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  void updateItem(PantryItem updatedItem) {
    state = state.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();
  }

  void markAsUsed(String itemId) {
    state = state.map((item) {
      return item.id == itemId
          ? item.copyWith(status: PantryStatus.used)
          : item;
    }).toList();
  }

  void markAsWasted(String itemId) {
    state = state.map((item) {
      return item.id == itemId
          ? item.copyWith(status: PantryStatus.wasted)
          : item;
    }).toList();
  }

  void setItems(List<PantryItem> items) {
    state = items;
  }
}

/// Provider for pantry items sorted by urgency.
final sortedPantryItemsProvider = Provider<List<PantryItem>>((ref) {
  final items = ref.watch(pantryItemsProvider);
  final service = ref.read(pantryServiceProvider);
  return service.sortByUrgency(
      items.where((i) => i.status == PantryStatus.available).toList());
});

/// Provider for the count of urgent pantry items (badge count).
final urgentPantryCountProvider = Provider<int>((ref) {
  final items = ref.watch(pantryItemsProvider);
  final service = ref.read(pantryServiceProvider);
  return service.getUrgentCount(
      items.where((i) => i.status == PantryStatus.available).toList());
});

/// Provider tracking whether onboarding is complete.
final isOnboardingCompleteProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.isOnboardingComplete ?? false;
});

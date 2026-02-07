import 'dart:math';
import '../models/models.dart';

/// Service responsible for generating weekly meal plans based on user preferences.
class MealPlanGenerator {
  final Random _random;

  MealPlanGenerator({Random? random}) : _random = random ?? Random();

  /// Generates a weekly meal plan based on user preferences and available recipes.
  ///
  /// The algorithm considers:
  /// - User's dietary restrictions
  /// - Day-specific preferences (quick/medium/elaborate/not cooking)
  /// - Favorite recipes and their desired frequency
  /// - History of recent plans to avoid repetition
  /// - Pantry items to prioritize recipes using ingredients about to expire
  MealPlan generateWeeklyPlan({
    required UserProfile userProfile,
    required List<Recipe> recipeDatabase,
    required String planId,
    List<MealPlan> history = const [],
    List<PantryItem> pantryItems = const [],
    DateTime? startDate,
  }) {
    final weekStart = startDate ?? _getNextMonday();
    final validRecipes = _filterByRestrictions(recipeDatabase, userProfile.restrictions);
    final usedRecipeIds = <String>{};
    final recentRecipeIds = _getRecentRecipeIds(history, 14);
    final days = <DayMeals>[];

    for (int dayIndex = 0; dayIndex < userProfile.planningDays; dayIndex++) {
      final date = weekStart.add(Duration(days: dayIndex));
      final dayOfWeek = date.weekday; // 1=Monday, 7=Sunday
      final dayPref = userProfile.dayPreferences[dayOfWeek] ??
          const DayPreference();

      Recipe? lunch;
      Recipe? dinner;

      // Plan lunch
      if (dayPref.lunch != MealPreference.notCooking) {
        final difficulty = _mealPrefToDifficulty(dayPref.lunch);
        final scored = _scoreRecipes(
          validRecipes,
          difficulty,
          usedRecipeIds,
          recentRecipeIds,
          userProfile.favoriteRecipes,
          pantryItems,
          dayIndex,
        );
        if (scored.isNotEmpty) {
          lunch = _pickWeightedRandom(scored);
          usedRecipeIds.add(lunch.id);
        }
      }

      // Plan dinner
      if (dayPref.dinner != MealPreference.notCooking) {
        final difficulty = _mealPrefToDifficulty(dayPref.dinner);
        final scored = _scoreRecipes(
          validRecipes,
          difficulty,
          usedRecipeIds,
          recentRecipeIds,
          userProfile.favoriteRecipes,
          pantryItems,
          dayIndex,
        );
        if (scored.isNotEmpty) {
          dinner = _pickWeightedRandom(scored);
          usedRecipeIds.add(dinner.id);
        }
      }

      days.add(DayMeals(date: date, lunch: lunch, dinner: dinner));
    }

    return MealPlan(
      id: planId,
      userId: userProfile.id,
      weekStartDate: weekStart,
      days: days,
      status: MealPlanStatus.draft,
      createdAt: DateTime.now(),
    );
  }

  /// Filters recipes by the user's dietary restrictions.
  List<Recipe> _filterByRestrictions(
      List<Recipe> recipes, List<DietaryRestriction> restrictions) {
    if (restrictions.isEmpty || restrictions.contains(DietaryRestriction.none)) {
      return List.from(recipes);
    }
    return recipes.where((recipe) {
      return restrictions.every((r) => recipe.suitableFor.contains(r));
    }).toList();
  }

  /// Gets recipe IDs used in the recent N days of history.
  Set<String> _getRecentRecipeIds(List<MealPlan> history, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final ids = <String>{};
    for (final plan in history) {
      if (plan.weekStartDate.isAfter(cutoff)) {
        for (final day in plan.days) {
          if (day.lunch != null) ids.add(day.lunch!.id);
          if (day.dinner != null) ids.add(day.dinner!.id);
        }
      }
    }
    return ids;
  }

  /// Scores and sorts recipes based on multiple factors.
  List<_ScoredRecipe> _scoreRecipes(
    List<Recipe> recipes,
    RecipeDifficulty? targetDifficulty,
    Set<String> usedRecipeIds,
    Set<String> recentRecipeIds,
    List<FavoriteRecipe> favorites,
    List<PantryItem> pantryItems,
    int dayIndex,
  ) {
    final favoriteIds = {for (final f in favorites) f.recipeId: f};
    final pantryIngredientIds =
        pantryItems.map((p) => p.ingredient.id).toSet();

    final scored = <_ScoredRecipe>[];
    for (final recipe in recipes) {
      if (usedRecipeIds.contains(recipe.id)) continue;

      var score = 0;

      // Match difficulty preference (+30)
      if (targetDifficulty != null && recipe.difficulty == targetDifficulty) {
        score += 30;
      }

      // Favorite recipe bonus (+20)
      if (favoriteIds.containsKey(recipe.id)) {
        score += 20;
      }

      // Recently used penalty (-25)
      if (recentRecipeIds.contains(recipe.id)) {
        score -= 25;
      }

      // Has ingredients in pantry bonus (+15)
      final pantryMatch = recipe.ingredients
          .where((ri) => pantryIngredientIds.contains(ri.ingredient.id))
          .length;
      if (pantryMatch > 0) {
        score += 15 * pantryMatch ~/ recipe.ingredients.length;
      }

      // Perishable ingredients should be planned early (+10 for first 2 days)
      if (dayIndex < 3) {
        final hasPerishable = recipe.ingredients.any(
            (ri) => ri.ingredient.category == IngredientCategory.fresh);
        if (hasPerishable) score += 10;
      }

      if (score >= 0) {
        scored.add(_ScoredRecipe(recipe, score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  /// Picks a recipe using weighted random selection from the top candidates.
  Recipe _pickWeightedRandom(List<_ScoredRecipe> scored) {
    if (scored.length <= 1) return scored.first.recipe;

    // Take top 5 candidates
    final candidates = scored.take(5).toList();
    final totalScore =
        candidates.fold<int>(0, (sum, s) => sum + s.score.abs() + 1);
    var pick = _random.nextInt(totalScore);

    for (final candidate in candidates) {
      pick -= (candidate.score.abs() + 1);
      if (pick < 0) return candidate.recipe;
    }
    return candidates.first.recipe;
  }

  /// Maps MealPreference to RecipeDifficulty.
  RecipeDifficulty? _mealPrefToDifficulty(MealPreference pref) {
    switch (pref) {
      case MealPreference.quick:
        return RecipeDifficulty.quick;
      case MealPreference.medium:
        return RecipeDifficulty.medium;
      case MealPreference.elaborate:
        return RecipeDifficulty.elaborate;
      case MealPreference.notCooking:
        return null;
    }
  }

  /// Gets the next Monday from today.
  DateTime _getNextMonday() {
    final now = DateTime.now();
    final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    return DateTime(now.year, now.month, now.day + (daysUntilMonday == 0 ? 7 : daysUntilMonday));
  }
}

class _ScoredRecipe {
  final Recipe recipe;
  final int score;

  const _ScoredRecipe(this.recipe, this.score);
}

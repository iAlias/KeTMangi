import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:ketmangi/models/models.dart';
import 'package:ketmangi/services/services.dart';

void main() {
  group('MealPlanGenerator', () {
    late MealPlanGenerator generator;
    late UserProfile userProfile;
    late List<Recipe> recipes;

    setUp(() {
      generator = MealPlanGenerator(random: Random(42));
      recipes = _createTestRecipes();
      userProfile = UserProfile(
        id: 'u1',
        numberOfPeople: 2,
        planningDays: 7,
        restrictions: [],
        favoriteRecipes: [
          const FavoriteRecipe(recipeId: 'r1'),
          const FavoriteRecipe(recipeId: 'r2'),
          const FavoriteRecipe(recipeId: 'r3'),
        ],
        dayPreferences: {
          1: const DayPreference(lunch: MealPreference.quick, dinner: MealPreference.medium),
          2: const DayPreference(lunch: MealPreference.quick, dinner: MealPreference.medium),
          3: const DayPreference(lunch: MealPreference.quick, dinner: MealPreference.medium),
          4: const DayPreference(lunch: MealPreference.quick, dinner: MealPreference.medium),
          5: const DayPreference(lunch: MealPreference.quick, dinner: MealPreference.medium),
          6: const DayPreference(lunch: MealPreference.elaborate, dinner: MealPreference.elaborate),
          7: const DayPreference(lunch: MealPreference.notCooking, dinner: MealPreference.notCooking),
        },
        createdAt: DateTime(2026, 2, 1),
        updatedAt: DateTime(2026, 2, 1),
      );
    });

    test('generates a plan with correct number of days', () {
      final plan = generator.generateWeeklyPlan(
        userProfile: userProfile,
        recipeDatabase: recipes,
        planId: 'plan1',
        startDate: DateTime(2026, 2, 9), // Monday
      );

      expect(plan.days.length, 7);
      expect(plan.status, MealPlanStatus.draft);
    });

    test('respects "not cooking" preference', () {
      final plan = generator.generateWeeklyPlan(
        userProfile: userProfile,
        recipeDatabase: recipes,
        planId: 'plan1',
        startDate: DateTime(2026, 2, 9),
      );

      // Sunday (day index 6) is set to "not cooking"
      final sunday = plan.days[6];
      expect(sunday.lunch, isNull);
      expect(sunday.dinner, isNull);
    });

    test('does not repeat recipes within the same week', () {
      final plan = generator.generateWeeklyPlan(
        userProfile: userProfile,
        recipeDatabase: recipes,
        planId: 'plan1',
        startDate: DateTime(2026, 2, 9),
      );

      final usedIds = <String>{};
      for (final day in plan.days) {
        if (day.lunch != null) {
          expect(usedIds.contains(day.lunch!.id), isFalse,
              reason: 'Recipe ${day.lunch!.name} repeated');
          usedIds.add(day.lunch!.id);
        }
        if (day.dinner != null) {
          expect(usedIds.contains(day.dinner!.id), isFalse,
              reason: 'Recipe ${day.dinner!.name} repeated');
          usedIds.add(day.dinner!.id);
        }
      }
    });

    test('filters by dietary restrictions', () {
      final veganProfile = userProfile.copyWith(
        restrictions: [DietaryRestriction.vegan],
      );
      final veganRecipes = recipes.where((r) =>
          r.suitableFor.contains(DietaryRestriction.vegan)).toList();

      final plan = generator.generateWeeklyPlan(
        userProfile: veganProfile,
        recipeDatabase: recipes,
        planId: 'plan1',
        startDate: DateTime(2026, 2, 9),
      );

      for (final day in plan.days) {
        if (day.lunch != null) {
          expect(veganRecipes.any((r) => r.id == day.lunch!.id), isTrue,
              reason: '${day.lunch!.name} is not vegan');
        }
        if (day.dinner != null) {
          expect(veganRecipes.any((r) => r.id == day.dinner!.id), isTrue,
              reason: '${day.dinner!.name} is not vegan');
        }
      }
    });

    test('generates plan with 5 planning days', () {
      final fiveDayProfile = userProfile.copyWith(planningDays: 5);
      final plan = generator.generateWeeklyPlan(
        userProfile: fiveDayProfile,
        recipeDatabase: recipes,
        planId: 'plan1',
        startDate: DateTime(2026, 2, 9),
      );

      expect(plan.days.length, 5);
    });
  });

  group('ShoppingListGenerator', () {
    late ShoppingListGenerator generator;

    setUp(() {
      generator = ShoppingListGenerator();
    });

    test('aggregates ingredients from multiple recipes', () {
      final plan = MealPlan(
        id: 'plan1',
        userId: 'u1',
        weekStartDate: DateTime(2026, 2, 9),
        days: [
          DayMeals(
            date: DateTime(2026, 2, 9),
            lunch: _recipeWithIngredient('r1', 'pasta', 'Pasta', 200, 'g',
                IngredientCategory.pantry),
            dinner: _recipeWithIngredient('r2', 'pasta', 'Pasta', 300, 'g',
                IngredientCategory.pantry),
          ),
        ],
        createdAt: DateTime.now(),
      );

      final list = generator.generateFromMealPlan(
        mealPlan: plan,
        listId: 'sl1',
      );

      // Pasta should be aggregated (200 + 300 = 500g, rounded to 500g)
      final pastaItems = list.items.where((i) => i.ingredient.id == 'pasta');
      expect(pastaItems.length, 1);
      expect(pastaItems.first.totalQuantity, 500);
    });

    test('produces no duplicate ingredients', () {
      final plan = MealPlan(
        id: 'plan1',
        userId: 'u1',
        weekStartDate: DateTime(2026, 2, 9),
        days: [
          DayMeals(
            date: DateTime(2026, 2, 9),
            lunch: _recipeWithIngredient('r1', 'olio', 'Olio', 30, 'ml',
                IngredientCategory.staple),
            dinner: _recipeWithIngredient('r2', 'olio', 'Olio', 20, 'ml',
                IngredientCategory.staple),
          ),
          DayMeals(
            date: DateTime(2026, 2, 10),
            lunch: _recipeWithIngredient('r3', 'olio', 'Olio', 25, 'ml',
                IngredientCategory.staple),
          ),
        ],
        createdAt: DateTime.now(),
      );

      final list = generator.generateFromMealPlan(
        mealPlan: plan,
        listId: 'sl1',
      );

      final oilItems = list.items.where((i) => i.ingredient.id == 'olio');
      expect(oilItems.length, 1);
    });

    test('marks items already in pantry', () {
      final plan = MealPlan(
        id: 'plan1',
        userId: 'u1',
        weekStartDate: DateTime(2026, 2, 9),
        days: [
          DayMeals(
            date: DateTime(2026, 2, 9),
            lunch: _recipeWithIngredient('r1', 'pasta', 'Pasta', 200, 'g',
                IngredientCategory.pantry),
          ),
        ],
        createdAt: DateTime.now(),
      );

      final pantryItems = [
        PantryItem(
          id: 'p1',
          userId: 'u1',
          ingredient: const Ingredient(
            id: 'pasta',
            name: 'Pasta',
            category: IngredientCategory.pantry,
          ),
          quantityInStock: 500,
          addedAt: DateTime.now(),
        ),
      ];

      final list = generator.generateFromMealPlan(
        mealPlan: plan,
        listId: 'sl1',
        pantryItems: pantryItems,
      );

      final pastaItem = list.items.firstWhere((i) => i.ingredient.id == 'pasta');
      expect(pastaItem.alreadyOwned, isTrue);
    });

    test('rounds quantities to commercial sizes', () {
      final plan = MealPlan(
        id: 'plan1',
        userId: 'u1',
        weekStartDate: DateTime(2026, 2, 9),
        days: [
          DayMeals(
            date: DateTime(2026, 2, 9),
            lunch: _recipeWithIngredient('r1', 'pasta', 'Pasta', 320, 'g',
                IngredientCategory.pantry),
          ),
        ],
        createdAt: DateTime.now(),
      );

      final list = generator.generateFromMealPlan(
        mealPlan: plan,
        listId: 'sl1',
      );

      final pastaItem = list.items.firstWhere((i) => i.ingredient.id == 'pasta');
      // 320g should round up to 350g (nearest 50)
      expect(pastaItem.totalQuantity, 350);
    });

    test('sorts items by category order', () {
      final plan = MealPlan(
        id: 'plan1',
        userId: 'u1',
        weekStartDate: DateTime(2026, 2, 9),
        days: [
          DayMeals(
            date: DateTime(2026, 2, 9),
            lunch: Recipe(
              id: 'r1',
              name: 'Recipe',
              difficulty: RecipeDifficulty.quick,
              preparationMinutes: 20,
              ingredients: [
                RecipeIngredient(
                  ingredient: const Ingredient(id: 'olio', name: 'Olio', category: IngredientCategory.staple),
                  quantity: 20, unit: 'ml',
                ),
                RecipeIngredient(
                  ingredient: const Ingredient(id: 'pollo', name: 'Pollo', category: IngredientCategory.fresh),
                  quantity: 500, unit: 'g',
                ),
                RecipeIngredient(
                  ingredient: const Ingredient(id: 'pasta', name: 'Pasta', category: IngredientCategory.pantry),
                  quantity: 300, unit: 'g',
                ),
              ],
            ),
          ),
        ],
        createdAt: DateTime.now(),
      );

      final list = generator.generateFromMealPlan(
        mealPlan: plan,
        listId: 'sl1',
      );

      // Fresh should come before pantry, pantry before staple
      expect(list.items[0].ingredient.category, IngredientCategory.fresh);
      expect(list.items[1].ingredient.category, IngredientCategory.pantry);
      expect(list.items[2].ingredient.category, IngredientCategory.staple);
    });
  });

  group('PantryService', () {
    late PantryService service;

    setUp(() {
      service = PantryService();
    });

    test('sorts items by urgency', () {
      final items = [
        _pantryItem('3', daysUntilExpiry: 10),
        _pantryItem('1', daysUntilExpiry: 1),
        _pantryItem('2', daysUntilExpiry: 5),
        _pantryItem('4'), // No expiry
      ];

      final sorted = service.sortByUrgency(items);
      expect(sorted[0].id, '1');
      expect(sorted[1].id, '2');
      expect(sorted[2].id, '3');
      expect(sorted[3].id, '4');
    });

    test('finds expiring items', () {
      final items = [
        _pantryItem('1', daysUntilExpiry: 1),
        _pantryItem('2', daysUntilExpiry: 5),
        _pantryItem('3', daysUntilExpiry: 10),
      ];

      final expiring = service.getExpiringItems(items, withinDays: 2);
      expect(expiring.length, 1);
      expect(expiring[0].id, '1');
    });

    test('searches by name', () {
      final items = [
        _pantryItemNamed('1', 'Pomodori'),
        _pantryItemNamed('2', 'Pasta'),
        _pantryItemNamed('3', 'Pollo'),
      ];

      final results = service.search(items, 'po');
      expect(results.length, 2); // Pomodori and Pollo
    });

    test('handles skipped meal - wasted', () {
      final recipe = Recipe(
        id: 'r1',
        name: 'Test',
        difficulty: RecipeDifficulty.quick,
        preparationMinutes: 20,
        ingredients: [
          RecipeIngredient(
            ingredient: const Ingredient(id: 'a', name: 'A', category: IngredientCategory.fresh),
            quantity: 100, unit: 'g',
          ),
        ],
      );

      final pantryItems = [
        PantryItem(
          id: 'p1',
          userId: 'u1',
          ingredient: const Ingredient(id: 'a', name: 'A', category: IngredientCategory.fresh),
          quantityInStock: 100,
          addedAt: DateTime.now(),
        ),
      ];

      final result = service.handleSkippedMeal(
        recipe: recipe,
        pantryItems: pantryItems,
        action: SkipMealAction.wasted,
      );

      expect(result.action, SkipMealAction.wasted);
      expect(result.wasteValue, greaterThan(0));
      expect(result.updatedPantryItems[0].status, PantryStatus.wasted);
    });

    test('handles skipped meal - already used', () {
      final recipe = Recipe(
        id: 'r1',
        name: 'Test',
        difficulty: RecipeDifficulty.quick,
        preparationMinutes: 20,
        ingredients: [
          RecipeIngredient(
            ingredient: const Ingredient(id: 'a', name: 'A', category: IngredientCategory.fresh),
            quantity: 100, unit: 'g',
          ),
        ],
      );

      final pantryItems = [
        PantryItem(
          id: 'p1',
          userId: 'u1',
          ingredient: const Ingredient(id: 'a', name: 'A', category: IngredientCategory.fresh),
          quantityInStock: 100,
          addedAt: DateTime.now(),
        ),
      ];

      final result = service.handleSkippedMeal(
        recipe: recipe,
        pantryItems: pantryItems,
        action: SkipMealAction.alreadyUsed,
      );

      expect(result.action, SkipMealAction.alreadyUsed);
      expect(result.wasteValue, 0);
      expect(result.updatedPantryItems[0].status, PantryStatus.used);
    });

    test('handles skipped meal - leave in pantry', () {
      final recipe = Recipe(
        id: 'r1',
        name: 'Test',
        difficulty: RecipeDifficulty.quick,
        preparationMinutes: 20,
        ingredients: [],
      );

      final pantryItems = <PantryItem>[];

      final result = service.handleSkippedMeal(
        recipe: recipe,
        pantryItems: pantryItems,
        action: SkipMealAction.leaveInPantry,
      );

      expect(result.action, SkipMealAction.leaveInPantry);
      expect(result.wasteValue, 0);
    });
  });

  group('RecipeCatalog', () {
    test('contains at least 10 recipes', () {
      expect(RecipeCatalog.recipes.length, greaterThanOrEqualTo(10));
    });

    test('all recipes have unique IDs', () {
      final ids = RecipeCatalog.recipes.map((r) => r.id).toSet();
      expect(ids.length, RecipeCatalog.recipes.length);
    });

    test('filters by dietary restriction', () {
      final veganRecipes =
          RecipeCatalog.filterByRestrictions([DietaryRestriction.vegan]);
      for (final recipe in veganRecipes) {
        expect(recipe.suitableFor, contains(DietaryRestriction.vegan));
      }
    });

    test('searches by name', () {
      final results = RecipeCatalog.search('Pasta');
      expect(results, isNotEmpty);
      for (final recipe in results) {
        expect(recipe.name.toLowerCase(), contains('pasta'));
      }
    });

    test('filters by difficulty', () {
      final quickRecipes =
          RecipeCatalog.filterByDifficulty(RecipeDifficulty.quick);
      for (final recipe in quickRecipes) {
        expect(recipe.difficulty, RecipeDifficulty.quick);
      }
    });
  });
}

List<Recipe> _createTestRecipes() {
  return List.generate(20, (i) {
    final difficulty = RecipeDifficulty.values[i % 3];
    return Recipe(
      id: 'r$i',
      name: 'Recipe $i',
      difficulty: difficulty,
      preparationMinutes: difficulty == RecipeDifficulty.quick
          ? 20
          : difficulty == RecipeDifficulty.medium
              ? 40
              : 70,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(
            id: 'ing-$i',
            name: 'Ingredient $i',
            category: IngredientCategory.values[i % 4],
          ),
          quantity: 100,
          unit: 'g',
        ),
      ],
      suitableFor: i % 3 == 0
          ? [DietaryRestriction.vegetarian, DietaryRestriction.vegan]
          : [],
    );
  });
}

Recipe _recipeWithIngredient(String recipeId, String ingredientId,
    String ingredientName, double quantity, String unit,
    IngredientCategory category) {
  return Recipe(
    id: recipeId,
    name: 'Recipe $recipeId',
    difficulty: RecipeDifficulty.quick,
    preparationMinutes: 20,
    ingredients: [
      RecipeIngredient(
        ingredient: Ingredient(
          id: ingredientId,
          name: ingredientName,
          category: category,
        ),
        quantity: quantity,
        unit: unit,
      ),
    ],
  );
}

PantryItem _pantryItem(String id, {int? daysUntilExpiry}) {
  return PantryItem(
    id: id,
    userId: 'u1',
    ingredient: Ingredient(
      id: 'ing-$id',
      name: 'Ingredient $id',
      category: IngredientCategory.fresh,
    ),
    quantityInStock: 100,
    expiryDate: daysUntilExpiry != null
        ? DateTime.now().add(Duration(days: daysUntilExpiry))
        : null,
    addedAt: DateTime.now(),
  );
}

PantryItem _pantryItemNamed(String id, String name) {
  return PantryItem(
    id: id,
    userId: 'u1',
    ingredient: Ingredient(
      id: 'ing-$id',
      name: name,
      category: IngredientCategory.fresh,
    ),
    quantityInStock: 100,
    addedAt: DateTime.now(),
  );
}

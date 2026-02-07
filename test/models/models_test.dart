import 'package:flutter_test/flutter_test.dart';
import 'package:ketmangi/models/models.dart';

void main() {
  group('Ingredient', () {
    test('creates ingredient with required fields', () {
      const ingredient = Ingredient(
        id: 'pasta',
        name: 'Pasta',
        category: IngredientCategory.pantry,
      );

      expect(ingredient.id, 'pasta');
      expect(ingredient.name, 'Pasta');
      expect(ingredient.category, IngredientCategory.pantry);
      expect(ingredient.defaultUnit, 'g');
      expect(ingredient.defaultShelfLifeDays, isNull);
    });

    test('serializes to and from JSON', () {
      const ingredient = Ingredient(
        id: 'salmone',
        name: 'Salmone',
        category: IngredientCategory.fresh,
        defaultUnit: 'g',
        defaultShelfLifeDays: 2,
      );

      final json = ingredient.toJson();
      final restored = Ingredient.fromJson(json);

      expect(restored.id, ingredient.id);
      expect(restored.name, ingredient.name);
      expect(restored.category, ingredient.category);
      expect(restored.defaultUnit, ingredient.defaultUnit);
      expect(restored.defaultShelfLifeDays, ingredient.defaultShelfLifeDays);
    });

    test('equality based on id', () {
      const a = Ingredient(id: 'x', name: 'A', category: IngredientCategory.pantry);
      const b = Ingredient(id: 'x', name: 'B', category: IngredientCategory.fresh);
      const c = Ingredient(id: 'y', name: 'A', category: IngredientCategory.pantry);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('Recipe', () {
    test('creates recipe with all fields', () {
      final recipe = Recipe(
        id: 'pasta-pomodoro',
        name: 'Pasta al Pomodoro',
        difficulty: RecipeDifficulty.quick,
        preparationMinutes: 20,
        ingredients: [
          RecipeIngredient(
            ingredient: const Ingredient(
              id: 'pasta',
              name: 'Pasta',
              category: IngredientCategory.pantry,
            ),
            quantity: 320,
            unit: 'g',
          ),
        ],
        suitableFor: [DietaryRestriction.vegetarian, DietaryRestriction.vegan],
        tags: ['primo', 'classico'],
      );

      expect(recipe.name, 'Pasta al Pomodoro');
      expect(recipe.difficulty, RecipeDifficulty.quick);
      expect(recipe.ingredients.length, 1);
      expect(recipe.suitableFor.length, 2);
    });

    test('serializes to and from JSON', () {
      final recipe = Recipe(
        id: 'test',
        name: 'Test Recipe',
        difficulty: RecipeDifficulty.medium,
        preparationMinutes: 30,
        ingredients: [
          RecipeIngredient(
            ingredient: const Ingredient(
              id: 'ing1',
              name: 'Ingredient 1',
              category: IngredientCategory.fresh,
            ),
            quantity: 100,
            unit: 'g',
          ),
        ],
        suitableFor: [DietaryRestriction.vegetarian],
      );

      final json = recipe.toJson();
      final restored = Recipe.fromJson(json);

      expect(restored.id, recipe.id);
      expect(restored.name, recipe.name);
      expect(restored.difficulty, recipe.difficulty);
      expect(restored.ingredients.length, 1);
      expect(restored.suitableFor, contains(DietaryRestriction.vegetarian));
    });
  });

  group('UserProfile', () {
    test('onboarding is incomplete with less than 5 favorites', () {
      final profile = UserProfile(
        id: 'u1',
        favoriteRecipes: [
          const FavoriteRecipe(recipeId: 'r1'),
          const FavoriteRecipe(recipeId: 'r2'),
        ],
        dayPreferences: {1: const DayPreference()},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.isOnboardingComplete, isFalse);
    });

    test('onboarding is complete with 5+ favorites and day preferences', () {
      final profile = UserProfile(
        id: 'u1',
        favoriteRecipes: List.generate(
          5, (i) => FavoriteRecipe(recipeId: 'r$i'),
        ),
        dayPreferences: {1: const DayPreference()},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.isOnboardingComplete, isTrue);
    });

    test('serializes to and from JSON', () {
      final profile = UserProfile(
        id: 'u1',
        displayName: 'Marco',
        numberOfPeople: 2,
        planningDays: 7,
        weeklyBudget: 100,
        restrictions: [DietaryRestriction.vegetarian],
        favoriteRecipes: [const FavoriteRecipe(recipeId: 'r1', weeklyFrequency: 2)],
        dayPreferences: {
          1: const DayPreference(
            lunch: MealPreference.quick,
            dinner: MealPreference.elaborate,
          ),
        },
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final json = profile.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.id, 'u1');
      expect(restored.displayName, 'Marco');
      expect(restored.numberOfPeople, 2);
      expect(restored.restrictions, [DietaryRestriction.vegetarian]);
      expect(restored.dayPreferences[1]?.lunch, MealPreference.quick);
      expect(restored.dayPreferences[1]?.dinner, MealPreference.elaborate);
    });
  });

  group('MealPlan', () {
    test('calculates total, completed, and skipped meals', () {
      final plan = MealPlan(
        id: 'plan1',
        userId: 'u1',
        weekStartDate: DateTime(2026, 2, 9),
        days: [
          DayMeals(
            date: DateTime(2026, 2, 9),
            lunch: _testRecipe('r1'),
            dinner: _testRecipe('r2'),
            lunchStatus: MealStatus.cooked,
            dinnerStatus: MealStatus.planned,
          ),
          DayMeals(
            date: DateTime(2026, 2, 10),
            lunch: _testRecipe('r3'),
            dinner: null,
            lunchStatus: MealStatus.skipped,
          ),
        ],
        createdAt: DateTime.now(),
      );

      expect(plan.totalMeals, 3);
      expect(plan.completedMeals, 1);
      expect(plan.skippedMeals, 1);
    });

    test('serializes to and from JSON', () {
      final plan = MealPlan(
        id: 'plan1',
        userId: 'u1',
        weekStartDate: DateTime(2026, 2, 9),
        days: [
          DayMeals(
            date: DateTime(2026, 2, 9),
            lunch: _testRecipe('r1'),
            dinner: _testRecipe('r2'),
          ),
        ],
        status: MealPlanStatus.draft,
        createdAt: DateTime(2026, 2, 7),
      );

      final json = plan.toJson();
      final restored = MealPlan.fromJson(json);

      expect(restored.id, 'plan1');
      expect(restored.status, MealPlanStatus.draft);
      expect(restored.days.length, 1);
      expect(restored.days[0].lunch?.name, 'Recipe r1');
    });
  });

  group('ShoppingList', () {
    test('groups items by category', () {
      final list = ShoppingList(
        id: 'sl1',
        mealPlanId: 'plan1',
        createdAt: DateTime.now(),
        items: [
          ShoppingItem(
            ingredient: const Ingredient(id: 'a', name: 'Apple', category: IngredientCategory.fresh),
            totalQuantity: 3,
            displayUnit: 'pz',
          ),
          ShoppingItem(
            ingredient: const Ingredient(id: 'b', name: 'Pasta', category: IngredientCategory.pantry),
            totalQuantity: 500,
            displayUnit: 'g',
          ),
          ShoppingItem(
            ingredient: const Ingredient(id: 'c', name: 'Carrot', category: IngredientCategory.fresh),
            totalQuantity: 2,
            displayUnit: 'pz',
          ),
        ],
      );

      final grouped = list.itemsByCategory;
      expect(grouped[IngredientCategory.fresh]?.length, 2);
      expect(grouped[IngredientCategory.pantry]?.length, 1);
    });

    test('counts remaining items', () {
      final list = ShoppingList(
        id: 'sl1',
        mealPlanId: 'plan1',
        createdAt: DateTime.now(),
        items: [
          ShoppingItem(
            ingredient: const Ingredient(id: 'a', name: 'A', category: IngredientCategory.fresh),
            totalQuantity: 1, displayUnit: 'pz',
          ),
          ShoppingItem(
            ingredient: const Ingredient(id: 'b', name: 'B', category: IngredientCategory.fresh),
            totalQuantity: 1, displayUnit: 'pz', isPurchased: true,
          ),
          ShoppingItem(
            ingredient: const Ingredient(id: 'c', name: 'C', category: IngredientCategory.fresh),
            totalQuantity: 1, displayUnit: 'pz', alreadyOwned: true,
          ),
        ],
      );

      expect(list.remainingCount, 1);
    });
  });

  group('PantryItem', () {
    test('calculates expiry urgency correctly', () {
      final critical = PantryItem(
        id: '1',
        userId: 'u1',
        ingredient: const Ingredient(id: 'a', name: 'A', category: IngredientCategory.fresh),
        quantityInStock: 1,
        expiryDate: DateTime.now().add(const Duration(days: 1)),
        addedAt: DateTime.now(),
      );
      expect(critical.urgency, ExpiryUrgency.critical);
      expect(critical.isExpiringSoon, isTrue);
      expect(critical.isExpired, isFalse);

      final warning = PantryItem(
        id: '2',
        userId: 'u1',
        ingredient: const Ingredient(id: 'b', name: 'B', category: IngredientCategory.fresh),
        quantityInStock: 1,
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        addedAt: DateTime.now(),
      );
      expect(warning.urgency, ExpiryUrgency.warning);

      final ok = PantryItem(
        id: '3',
        userId: 'u1',
        ingredient: const Ingredient(id: 'c', name: 'C', category: IngredientCategory.pantry),
        quantityInStock: 1,
        addedAt: DateTime.now(),
      );
      expect(ok.urgency, ExpiryUrgency.ok);
      expect(ok.daysUntilExpiry, isNull);
    });

    test('detects expired items', () {
      final expired = PantryItem(
        id: '1',
        userId: 'u1',
        ingredient: const Ingredient(id: 'a', name: 'A', category: IngredientCategory.fresh),
        quantityInStock: 1,
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        addedAt: DateTime.now(),
      );

      expect(expired.isExpired, isTrue);
      expect(expired.urgency, ExpiryUrgency.critical);
    });
  });
}

Recipe _testRecipe(String id) => Recipe(
      id: id,
      name: 'Recipe $id',
      difficulty: RecipeDifficulty.quick,
      preparationMinutes: 20,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(
            id: 'ing-$id',
            name: 'Ingredient $id',
            category: IngredientCategory.fresh,
          ),
          quantity: 100,
          unit: 'g',
        ),
      ],
    );

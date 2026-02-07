import 'recipe.dart';

/// User profile containing personal information and preferences.
class UserProfile {
  final String id;
  final String? displayName;
  final int numberOfPeople;
  final int planningDays;
  final double? weeklyBudget;
  final List<DietaryRestriction> restrictions;
  final List<FavoriteRecipe> favoriteRecipes;
  final Map<int, DayPreference> dayPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.displayName,
    this.numberOfPeople = 1,
    this.planningDays = 7,
    this.weeklyBudget,
    this.restrictions = const [],
    this.favoriteRecipes = const [],
    this.dayPreferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    int? numberOfPeople,
    int? planningDays,
    double? weeklyBudget,
    List<DietaryRestriction>? restrictions,
    List<FavoriteRecipe>? favoriteRecipes,
    Map<int, DayPreference>? dayPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      planningDays: planningDays ?? this.planningDays,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      restrictions: restrictions ?? this.restrictions,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      dayPreferences: dayPreferences ?? this.dayPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'numberOfPeople': numberOfPeople,
        'planningDays': planningDays,
        'weeklyBudget': weeklyBudget,
        'restrictions': restrictions.map((r) => r.name).toList(),
        'favoriteRecipes': favoriteRecipes.map((f) => f.toJson()).toList(),
        'dayPreferences': dayPreferences.map(
          (key, value) => MapEntry(key.toString(), value.toJson()),
        ),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        displayName: json['displayName'] as String?,
        numberOfPeople: json['numberOfPeople'] as int? ?? 1,
        planningDays: json['planningDays'] as int? ?? 7,
        weeklyBudget: (json['weeklyBudget'] as num?)?.toDouble(),
        restrictions: (json['restrictions'] as List?)
                ?.map((r) => DietaryRestriction.values.byName(r as String))
                .toList() ??
            [],
        favoriteRecipes: (json['favoriteRecipes'] as List?)
                ?.map(
                    (f) => FavoriteRecipe.fromJson(f as Map<String, dynamic>))
                .toList() ??
            [],
        dayPreferences: (json['dayPreferences'] as Map<String, dynamic>?)
                ?.map(
              (key, value) => MapEntry(
                int.parse(key),
                DayPreference.fromJson(value as Map<String, dynamic>),
              ),
            ) ??
            {},
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  /// Whether the user has completed the onboarding process.
  bool get isOnboardingComplete =>
      favoriteRecipes.length >= 5 && dayPreferences.isNotEmpty;
}

/// A recipe marked as favorite with an optional desired frequency.
class FavoriteRecipe {
  final String recipeId;
  final int weeklyFrequency;

  const FavoriteRecipe({
    required this.recipeId,
    this.weeklyFrequency = 1,
  });

  Map<String, dynamic> toJson() => {
        'recipeId': recipeId,
        'weeklyFrequency': weeklyFrequency,
      };

  factory FavoriteRecipe.fromJson(Map<String, dynamic> json) => FavoriteRecipe(
        recipeId: json['recipeId'] as String,
        weeklyFrequency: json['weeklyFrequency'] as int? ?? 1,
      );
}

/// Preferences for a specific day of the week (1=Monday, 7=Sunday).
class DayPreference {
  final MealPreference lunch;
  final MealPreference dinner;

  const DayPreference({
    this.lunch = MealPreference.medium,
    this.dinner = MealPreference.medium,
  });

  Map<String, dynamic> toJson() => {
        'lunch': lunch.name,
        'dinner': dinner.name,
      };

  factory DayPreference.fromJson(Map<String, dynamic> json) => DayPreference(
        lunch: MealPreference.values.byName(json['lunch'] as String),
        dinner: MealPreference.values.byName(json['dinner'] as String),
      );
}

/// Meal preference indicating cooking complexity or opt-out.
enum MealPreference {
  quick,       // Veloce (<30min)
  medium,      // Medio (30-60min)
  elaborate,   // Elaborato (>60min)
  notCooking,  // Non cucino
}

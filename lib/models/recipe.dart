import 'ingredient.dart';

/// Represents a recipe with its properties and ingredients.
class Recipe {
  final String id;
  final String name;
  final RecipeDifficulty difficulty;
  final int preparationMinutes;
  final List<RecipeIngredient> ingredients;
  final String? imageUrl;
  final String? procedure;
  final List<String> tags;
  final List<DietaryRestriction> suitableFor;
  final bool isCustom;
  final String? userId;

  const Recipe({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.preparationMinutes,
    required this.ingredients,
    this.imageUrl,
    this.procedure,
    this.tags = const [],
    this.suitableFor = const [],
    this.isCustom = false,
    this.userId,
  });

  Recipe copyWith({
    String? id,
    String? name,
    RecipeDifficulty? difficulty,
    int? preparationMinutes,
    List<RecipeIngredient>? ingredients,
    String? imageUrl,
    String? procedure,
    List<String>? tags,
    List<DietaryRestriction>? suitableFor,
    bool? isCustom,
    String? userId,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      preparationMinutes: preparationMinutes ?? this.preparationMinutes,
      ingredients: ingredients ?? this.ingredients,
      imageUrl: imageUrl ?? this.imageUrl,
      procedure: procedure ?? this.procedure,
      tags: tags ?? this.tags,
      suitableFor: suitableFor ?? this.suitableFor,
      isCustom: isCustom ?? this.isCustom,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'difficulty': difficulty.name,
        'preparationMinutes': preparationMinutes,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'imageUrl': imageUrl,
        'procedure': procedure,
        'tags': tags,
        'suitableFor': suitableFor.map((r) => r.name).toList(),
        'isCustom': isCustom,
        'userId': userId,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        name: json['name'] as String,
        difficulty:
            RecipeDifficulty.values.byName(json['difficulty'] as String),
        preparationMinutes: json['preparationMinutes'] as int,
        ingredients: (json['ingredients'] as List)
            .map((i) => RecipeIngredient.fromJson(i as Map<String, dynamic>))
            .toList(),
        imageUrl: json['imageUrl'] as String?,
        procedure: json['procedure'] as String?,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        suitableFor: (json['suitableFor'] as List?)
                ?.map((r) => DietaryRestriction.values.byName(r as String))
                .toList() ??
            [],
        isCustom: json['isCustom'] as bool? ?? false,
        userId: json['userId'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Recipe && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Recipe($name)';
}

/// Recipe difficulty levels matching preparation time.
enum RecipeDifficulty {
  quick,      // Veloce (<30min)
  medium,     // Medio (30-60min)
  elaborate,  // Elaborato (>60min)
}

/// Dietary restrictions supported by the app.
enum DietaryRestriction {
  vegetarian,
  vegan,
  glutenFree,
  lactoseFree,
  halal,
  kosher,
  none,
}

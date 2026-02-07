/// Represents a food ingredient with its properties.
class Ingredient {
  final String id;
  final String name;
  final IngredientCategory category;
  final String defaultUnit;
  final int? defaultShelfLifeDays;

  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    this.defaultUnit = 'g',
    this.defaultShelfLifeDays,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    IngredientCategory? category,
    String? defaultUnit,
    int? defaultShelfLifeDays,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      defaultShelfLifeDays: defaultShelfLifeDays ?? this.defaultShelfLifeDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'defaultUnit': defaultUnit,
        'defaultShelfLifeDays': defaultShelfLifeDays,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json['id'] as String,
        name: json['name'] as String,
        category: IngredientCategory.values.byName(json['category'] as String),
        defaultUnit: json['defaultUnit'] as String? ?? 'g',
        defaultShelfLifeDays: json['defaultShelfLifeDays'] as int?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Ingredient && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Ingredient($name)';
}

/// Categories for organizing ingredients in the shopping list.
enum IngredientCategory {
  fresh,    // 🥬 Fresco (carne, pesce, latticini, verdure)
  pantry,   // 🥫 Dispensa (pasta, riso, scatolame)
  frozen,   // 🧊 Surgelati
  staple,   // ✅ Ingredienti base (olio, sale, spezie)
}

/// An ingredient with its quantity as used in a recipe.
class RecipeIngredient {
  final Ingredient ingredient;
  final double quantity;
  final String unit;

  const RecipeIngredient({
    required this.ingredient,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
        'ingredient': ingredient.toJson(),
        'quantity': quantity,
        'unit': unit,
      };

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        ingredient:
            Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
      );
}

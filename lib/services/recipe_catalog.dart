import '../models/models.dart';

/// A predefined catalog of Italian recipes for the app.
/// This provides the initial recipe database for users to select from.
class RecipeCatalog {
  static final List<Recipe> recipes = [
    // === PRIMI PIATTI ===
    Recipe(
      id: 'pasta-pomodoro',
      name: 'Pasta al Pomodoro',
      difficulty: RecipeDifficulty.quick,
      preparationMinutes: 20,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'pasta', name: 'Pasta', category: IngredientCategory.pantry),
          quantity: 320, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'pelati', name: 'Pomodori pelati', category: IngredientCategory.pantry),
          quantity: 400, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'aglio', name: 'Aglio', category: IngredientCategory.fresh, defaultShelfLifeDays: 30),
          quantity: 2, unit: 'spicchi',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'olio-evo', name: 'Olio extravergine', category: IngredientCategory.staple),
          quantity: 30, unit: 'ml',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'basilico', name: 'Basilico', category: IngredientCategory.fresh, defaultShelfLifeDays: 5),
          quantity: 5, unit: 'foglie',
        ),
      ],
      suitableFor: [DietaryRestriction.vegetarian, DietaryRestriction.vegan],
      tags: ['primo', 'classico', 'italiano'],
    ),
    Recipe(
      id: 'carbonara',
      name: 'Pasta alla Carbonara',
      difficulty: RecipeDifficulty.medium,
      preparationMinutes: 30,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'pasta', name: 'Pasta', category: IngredientCategory.pantry),
          quantity: 320, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'guanciale', name: 'Guanciale', category: IngredientCategory.fresh, defaultShelfLifeDays: 14),
          quantity: 150, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'uova', name: 'Uova', category: IngredientCategory.fresh, defaultShelfLifeDays: 21),
          quantity: 4, unit: 'pz',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'pecorino', name: 'Pecorino Romano', category: IngredientCategory.fresh, defaultShelfLifeDays: 30),
          quantity: 100, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'pepe-nero', name: 'Pepe nero', category: IngredientCategory.staple),
          quantity: 5, unit: 'g',
        ),
      ],
      tags: ['primo', 'romano', 'classico'],
    ),
    Recipe(
      id: 'risotto-zafferano',
      name: 'Risotto allo Zafferano',
      difficulty: RecipeDifficulty.medium,
      preparationMinutes: 40,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'riso', name: 'Riso Carnaroli', category: IngredientCategory.pantry),
          quantity: 320, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'zafferano', name: 'Zafferano', category: IngredientCategory.pantry),
          quantity: 1, unit: 'bustina',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'cipolla', name: 'Cipolla', category: IngredientCategory.fresh, defaultShelfLifeDays: 14),
          quantity: 1, unit: 'pz',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'burro', name: 'Burro', category: IngredientCategory.fresh, defaultShelfLifeDays: 30),
          quantity: 50, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'parmigiano', name: 'Parmigiano Reggiano', category: IngredientCategory.fresh, defaultShelfLifeDays: 60),
          quantity: 80, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'brodo', name: 'Brodo vegetale', category: IngredientCategory.pantry),
          quantity: 1000, unit: 'ml',
        ),
      ],
      suitableFor: [DietaryRestriction.vegetarian],
      tags: ['primo', 'milanese', 'risotto'],
    ),

    // === SECONDI - POLLO ===
    Recipe(
      id: 'pollo-forno',
      name: 'Pollo al Forno',
      difficulty: RecipeDifficulty.medium,
      preparationMinutes: 50,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'pollo', name: 'Pollo intero', category: IngredientCategory.fresh, defaultShelfLifeDays: 3),
          quantity: 1200, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'patate', name: 'Patate', category: IngredientCategory.fresh, defaultShelfLifeDays: 21),
          quantity: 500, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'rosmarino', name: 'Rosmarino', category: IngredientCategory.fresh, defaultShelfLifeDays: 7),
          quantity: 2, unit: 'rametti',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'olio-evo', name: 'Olio extravergine', category: IngredientCategory.staple),
          quantity: 40, unit: 'ml',
        ),
      ],
      tags: ['secondo', 'pollo', 'forno'],
    ),
    Recipe(
      id: 'petto-pollo-limone',
      name: 'Petto di Pollo al Limone',
      difficulty: RecipeDifficulty.quick,
      preparationMinutes: 25,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'petto-pollo', name: 'Petto di pollo', category: IngredientCategory.fresh, defaultShelfLifeDays: 3),
          quantity: 500, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'limone', name: 'Limone', category: IngredientCategory.fresh, defaultShelfLifeDays: 14),
          quantity: 2, unit: 'pz',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'olio-evo', name: 'Olio extravergine', category: IngredientCategory.staple),
          quantity: 30, unit: 'ml',
        ),
      ],
      tags: ['secondo', 'pollo', 'veloce'],
    ),

    // === SECONDI - PESCE ===
    Recipe(
      id: 'salmone-forno',
      name: 'Salmone al Forno',
      difficulty: RecipeDifficulty.quick,
      preparationMinutes: 25,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'salmone', name: 'Filetto di salmone', category: IngredientCategory.fresh, defaultShelfLifeDays: 2),
          quantity: 400, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'limone', name: 'Limone', category: IngredientCategory.fresh, defaultShelfLifeDays: 14),
          quantity: 1, unit: 'pz',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'olio-evo', name: 'Olio extravergine', category: IngredientCategory.staple),
          quantity: 20, unit: 'ml',
        ),
      ],
      tags: ['secondo', 'pesce', 'veloce'],
    ),
    Recipe(
      id: 'pesce-spada-griglia',
      name: 'Pesce Spada alla Griglia',
      difficulty: RecipeDifficulty.medium,
      preparationMinutes: 35,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'pesce-spada', name: 'Pesce spada', category: IngredientCategory.fresh, defaultShelfLifeDays: 2),
          quantity: 400, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'pomodorini', name: 'Pomodorini', category: IngredientCategory.fresh, defaultShelfLifeDays: 5),
          quantity: 200, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'capperi', name: 'Capperi', category: IngredientCategory.pantry),
          quantity: 20, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'olio-evo', name: 'Olio extravergine', category: IngredientCategory.staple),
          quantity: 30, unit: 'ml',
        ),
      ],
      tags: ['secondo', 'pesce', 'griglia'],
    ),

    // === SECONDI - CARNE ROSSA ===
    Recipe(
      id: 'bistecca-fiorentina',
      name: 'Bistecca alla Fiorentina',
      difficulty: RecipeDifficulty.medium,
      preparationMinutes: 30,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'bistecca', name: 'Bistecca di manzo', category: IngredientCategory.fresh, defaultShelfLifeDays: 3),
          quantity: 800, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'olio-evo', name: 'Olio extravergine', category: IngredientCategory.staple),
          quantity: 20, unit: 'ml',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'sale-grosso', name: 'Sale grosso', category: IngredientCategory.staple),
          quantity: 10, unit: 'g',
        ),
      ],
      tags: ['secondo', 'carne', 'toscano'],
    ),
    Recipe(
      id: 'polpette-sugo',
      name: 'Polpette al Sugo',
      difficulty: RecipeDifficulty.medium,
      preparationMinutes: 45,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'macinato', name: 'Carne macinata', category: IngredientCategory.fresh, defaultShelfLifeDays: 2),
          quantity: 500, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'pelati', name: 'Pomodori pelati', category: IngredientCategory.pantry),
          quantity: 400, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'pane-raffermo', name: 'Pane raffermo', category: IngredientCategory.pantry),
          quantity: 100, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'uova', name: 'Uova', category: IngredientCategory.fresh, defaultShelfLifeDays: 21),
          quantity: 1, unit: 'pz',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'parmigiano', name: 'Parmigiano Reggiano', category: IngredientCategory.fresh, defaultShelfLifeDays: 60),
          quantity: 50, unit: 'g',
        ),
      ],
      tags: ['secondo', 'carne', 'comfort'],
    ),

    // === SECONDI - LEGUMI ===
    Recipe(
      id: 'zuppa-lenticchie',
      name: 'Zuppa di Lenticchie',
      difficulty: RecipeDifficulty.medium,
      preparationMinutes: 40,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'lenticchie', name: 'Lenticchie', category: IngredientCategory.pantry),
          quantity: 300, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'carote', name: 'Carote', category: IngredientCategory.fresh, defaultShelfLifeDays: 14),
          quantity: 2, unit: 'pz',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'sedano', name: 'Sedano', category: IngredientCategory.fresh, defaultShelfLifeDays: 7),
          quantity: 2, unit: 'gambi',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'cipolla', name: 'Cipolla', category: IngredientCategory.fresh, defaultShelfLifeDays: 14),
          quantity: 1, unit: 'pz',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'olio-evo', name: 'Olio extravergine', category: IngredientCategory.staple),
          quantity: 30, unit: 'ml',
        ),
      ],
      suitableFor: [DietaryRestriction.vegetarian, DietaryRestriction.vegan, DietaryRestriction.glutenFree],
      tags: ['piatto-unico', 'legumi', 'comfort'],
    ),
    Recipe(
      id: 'pasta-ceci',
      name: 'Pasta e Ceci',
      difficulty: RecipeDifficulty.medium,
      preparationMinutes: 40,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'pasta-corta', name: 'Pasta corta', category: IngredientCategory.pantry),
          quantity: 200, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'ceci', name: 'Ceci in scatola', category: IngredientCategory.pantry),
          quantity: 400, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'rosmarino', name: 'Rosmarino', category: IngredientCategory.fresh, defaultShelfLifeDays: 7),
          quantity: 1, unit: 'rametto',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'aglio', name: 'Aglio', category: IngredientCategory.fresh, defaultShelfLifeDays: 30),
          quantity: 2, unit: 'spicchi',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'olio-evo', name: 'Olio extravergine', category: IngredientCategory.staple),
          quantity: 40, unit: 'ml',
        ),
      ],
      suitableFor: [DietaryRestriction.vegetarian, DietaryRestriction.vegan],
      tags: ['primo', 'legumi', 'tradizionale'],
    ),

    // === PIATTI VELOCI ===
    Recipe(
      id: 'insalata-mista',
      name: 'Insalata Mista con Tonno',
      difficulty: RecipeDifficulty.quick,
      preparationMinutes: 15,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'insalata', name: 'Insalata mista', category: IngredientCategory.fresh, defaultShelfLifeDays: 3),
          quantity: 200, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'tonno', name: 'Tonno in scatola', category: IngredientCategory.pantry),
          quantity: 160, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'pomodorini', name: 'Pomodorini', category: IngredientCategory.fresh, defaultShelfLifeDays: 5),
          quantity: 100, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'mais', name: 'Mais in scatola', category: IngredientCategory.pantry),
          quantity: 150, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'olio-evo', name: 'Olio extravergine', category: IngredientCategory.staple),
          quantity: 20, unit: 'ml',
        ),
      ],
      tags: ['secondo', 'veloce', 'leggero'],
    ),
    Recipe(
      id: 'frittata-verdure',
      name: 'Frittata di Verdure',
      difficulty: RecipeDifficulty.quick,
      preparationMinutes: 20,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'uova', name: 'Uova', category: IngredientCategory.fresh, defaultShelfLifeDays: 21),
          quantity: 6, unit: 'pz',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'zucchine', name: 'Zucchine', category: IngredientCategory.fresh, defaultShelfLifeDays: 5),
          quantity: 200, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'parmigiano', name: 'Parmigiano Reggiano', category: IngredientCategory.fresh, defaultShelfLifeDays: 60),
          quantity: 40, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'olio-evo', name: 'Olio extravergine', category: IngredientCategory.staple),
          quantity: 20, unit: 'ml',
        ),
      ],
      suitableFor: [DietaryRestriction.vegetarian, DietaryRestriction.glutenFree],
      tags: ['secondo', 'uova', 'veloce'],
    ),

    // === PIATTI ELABORATI ===
    Recipe(
      id: 'lasagne',
      name: 'Lasagne alla Bolognese',
      difficulty: RecipeDifficulty.elaborate,
      preparationMinutes: 90,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'sfoglie-lasagna', name: 'Sfoglie per lasagna', category: IngredientCategory.pantry),
          quantity: 500, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'macinato', name: 'Carne macinata', category: IngredientCategory.fresh, defaultShelfLifeDays: 2),
          quantity: 400, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'pelati', name: 'Pomodori pelati', category: IngredientCategory.pantry),
          quantity: 400, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'besciamella', name: 'Besciamella', category: IngredientCategory.fresh, defaultShelfLifeDays: 7),
          quantity: 500, unit: 'ml',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'parmigiano', name: 'Parmigiano Reggiano', category: IngredientCategory.fresh, defaultShelfLifeDays: 60),
          quantity: 100, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'carote', name: 'Carote', category: IngredientCategory.fresh, defaultShelfLifeDays: 14),
          quantity: 1, unit: 'pz',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'sedano', name: 'Sedano', category: IngredientCategory.fresh, defaultShelfLifeDays: 7),
          quantity: 1, unit: 'gambo',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'cipolla', name: 'Cipolla', category: IngredientCategory.fresh, defaultShelfLifeDays: 14),
          quantity: 1, unit: 'pz',
        ),
      ],
      tags: ['primo', 'forno', 'elaborato', 'domenica'],
    ),
    Recipe(
      id: 'parmigiana',
      name: 'Parmigiana di Melanzane',
      difficulty: RecipeDifficulty.elaborate,
      preparationMinutes: 80,
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(id: 'melanzane', name: 'Melanzane', category: IngredientCategory.fresh, defaultShelfLifeDays: 5),
          quantity: 800, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'pelati', name: 'Pomodori pelati', category: IngredientCategory.pantry),
          quantity: 500, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'mozzarella', name: 'Mozzarella', category: IngredientCategory.fresh, defaultShelfLifeDays: 5),
          quantity: 300, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'parmigiano', name: 'Parmigiano Reggiano', category: IngredientCategory.fresh, defaultShelfLifeDays: 60),
          quantity: 80, unit: 'g',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'basilico', name: 'Basilico', category: IngredientCategory.fresh, defaultShelfLifeDays: 5),
          quantity: 10, unit: 'foglie',
        ),
        RecipeIngredient(
          ingredient: Ingredient(id: 'olio-evo', name: 'Olio extravergine', category: IngredientCategory.staple),
          quantity: 100, unit: 'ml',
        ),
      ],
      suitableFor: [DietaryRestriction.vegetarian],
      tags: ['secondo', 'forno', 'elaborato', 'campano'],
    ),
  ];

  /// Filters recipes by dietary restrictions.
  static List<Recipe> filterByRestrictions(List<DietaryRestriction> restrictions) {
    if (restrictions.isEmpty || restrictions.contains(DietaryRestriction.none)) {
      return recipes;
    }
    return recipes.where((recipe) {
      return restrictions.every((r) => recipe.suitableFor.contains(r));
    }).toList();
  }

  /// Searches recipes by name (case-insensitive).
  static List<Recipe> search(String query) {
    final lower = query.toLowerCase();
    return recipes.where((r) => r.name.toLowerCase().contains(lower)).toList();
  }

  /// Filters recipes by difficulty.
  static List<Recipe> filterByDifficulty(RecipeDifficulty difficulty) {
    return recipes.where((r) => r.difficulty == difficulty).toList();
  }
}

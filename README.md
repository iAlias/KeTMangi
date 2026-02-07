# KeTMangi 🍝

**Meal Planner App** — Pianifica i pasti, riduci gli sprechi.

KeTMangi è un'applicazione Flutter che rivoluziona il modo in cui le persone pianificano i pasti e fanno la spesa. Invece di comprare e poi decidere cosa cucinare, l'utente pianifica prima i pasti e riceve automaticamente la lista della spesa ottimizzata.

## Funzionalità

- **🧙 Onboarding guidato** — Configura preferenze alimentari, piatti abituali e preferenze giornaliere
- **📅 Piano settimanale automatico** — Generazione intelligente del piano pasti basato sulle tue preferenze
- **🛒 Lista della spesa** — Aggregazione automatica ingredienti, organizzata per categorie del supermercato
- **🏠 Gestione dispensa** — Traccia ingredienti e scadenze per ridurre gli sprechi
- **❌ Gestione imprevisti** — Quando non cucini, scegli cosa fare degli ingredienti
- **📊 Dashboard** — Metriche e statistiche su pasti completati e sprechi

## Tech Stack

- **Flutter** 3.16+ / **Dart** 3.2+
- **Riverpod** — State management
- **GoRouter** — Navigation
- **Material Design 3** — UI components

> 📖 Per l'analisi completa Flutter vs React Native per questo progetto, vedi [TECH_DECISION.md](TECH_DECISION.md)

## Struttura Progetto

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── ingredient.dart          # Ingredient & RecipeIngredient
│   ├── recipe.dart              # Recipe & enums
│   ├── user_profile.dart        # UserProfile & preferences
│   ├── meal_plan.dart           # MealPlan & DayMeals
│   ├── shopping_list.dart       # ShoppingList & ShoppingItem
│   └── pantry_item.dart         # PantryItem & expiry tracking
├── services/                    # Business logic
│   ├── meal_plan_generator.dart # Weekly plan generation algorithm
│   ├── shopping_list_generator.dart # Shopping list aggregation
│   ├── pantry_service.dart      # Pantry management & "Non cucino" flow
│   └── recipe_catalog.dart      # Predefined Italian recipes
├── providers/                   # Riverpod state management
│   └── app_providers.dart       # All app providers
├── router/                      # GoRouter configuration
│   └── app_router.dart          # Routes & bottom navigation
└── screens/                     # UI screens
    ├── onboarding/              # Multi-step setup wizard
    ├── meal_plan/               # Weekly plan view
    ├── shopping_list/           # Shopping list view
    ├── pantry/                  # Pantry management
    ├── dashboard/               # Home dashboard
    └── settings/                # App settings
```

## Getting Started

1. **Prerequisiti**: Flutter SDK 3.16+
2. **Installa dipendenze**: `flutter pub get`
3. **Avvia l'app**: `flutter run`
4. **Esegui test**: `flutter test`

## Catalogo Ricette

L'app include 15+ ricette italiane predefinite organizzate per:
- **Difficoltà**: Veloce (<30min), Medio (30-60min), Elaborato (>60min)
- **Tipo**: Primi, Secondi, Piatti unici
- **Restrizioni**: Vegetariano, Vegano, Senza glutine, etc.
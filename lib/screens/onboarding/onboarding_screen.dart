import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';

/// Multi-step onboarding screen for initial user setup.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1: Basic info
  int _numberOfPeople = 2;
  int _planningDays = 7;
  double _weeklyBudget = 100;

  // Step 2: Dietary restrictions
  final Set<DietaryRestriction> _selectedRestrictions = {};

  // Step 3: Favorite recipes
  final Set<String> _selectedRecipeIds = {};

  // Step 4: Day preferences
  final Map<int, DayPreference> _dayPreferences = {};

  @override
  void initState() {
    super.initState();
    // Initialize default day preferences
    for (int i = 1; i <= 7; i++) {
      _dayPreferences[i] = const DayPreference(
        lunch: MealPreference.medium,
        dinner: MealPreference.medium,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    final profile = UserProfile(
      id: 'user-1',
      numberOfPeople: _numberOfPeople,
      planningDays: _planningDays,
      weeklyBudget: _weeklyBudget,
      restrictions: _selectedRestrictions.toList(),
      favoriteRecipes: _selectedRecipeIds
          .map((id) => FavoriteRecipe(recipeId: id))
          .toList(),
      dayPreferences: _dayPreferences,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(userProfileProvider.notifier).setProfile(profile);
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup ${_currentStep + 1} di $_totalSteps'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(),
                _buildRestrictionsStep(),
                _buildFavoriteRecipesStep(),
                _buildDayPreferencesStep(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canProceed() ? _nextStep : null,
                child: Text(
                  _currentStep < _totalSteps - 1 ? 'Avanti' : 'Completa',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return true; // Restrictions are optional
      case 2:
        return _selectedRecipeIds.length >= 5;
      case 3:
        return _dayPreferences.isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildBasicInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informazioni Base',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Configuriamo le basi per il tuo piano pasti.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text('Numero di persone: $_numberOfPeople'),
          Slider(
            value: _numberOfPeople.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            label: '$_numberOfPeople',
            onChanged: (value) {
              setState(() => _numberOfPeople = value.round());
            },
          ),
          const SizedBox(height: 16),
          Text('Giorni di pianificazione: $_planningDays'),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 5, label: Text('5 giorni')),
              ButtonSegment(value: 7, label: Text('7 giorni')),
            ],
            selected: {_planningDays},
            onSelectionChanged: (Set<int> value) {
              setState(() => _planningDays = value.first);
            },
          ),
          const SizedBox(height: 16),
          Text('Budget settimanale: €${_weeklyBudget.round()}'),
          Slider(
            value: _weeklyBudget,
            min: 30,
            max: 200,
            divisions: 17,
            label: '€${_weeklyBudget.round()}',
            onChanged: (value) {
              setState(() => _weeklyBudget = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictionsStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restrizioni Alimentari',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Seleziona eventuali restrizioni alimentari.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DietaryRestriction.values.map((restriction) {
              final isSelected = _selectedRestrictions.contains(restriction);
              return FilterChip(
                label: Text(_restrictionLabel(restriction)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (restriction == DietaryRestriction.none) {
                        _selectedRestrictions.clear();
                      } else {
                        _selectedRestrictions.remove(DietaryRestriction.none);
                      }
                      _selectedRestrictions.add(restriction);
                    } else {
                      _selectedRestrictions.remove(restriction);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteRecipesStep() {
    final recipes = RecipeCatalog.recipes;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Piatti Abituali',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Seleziona almeno 5 piatti che cucini abitualmente (${_selectedRecipeIds.length} selezionati).',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final isSelected = _selectedRecipeIds.contains(recipe.id);
                return CheckboxListTile(
                  title: Text(recipe.name),
                  subtitle: Text(
                    '${_difficultyLabel(recipe.difficulty)} · ${recipe.preparationMinutes} min',
                  ),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedRecipeIds.add(recipe.id);
                      } else {
                        _selectedRecipeIds.remove(recipe.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPreferencesStep() {
    const dayNames = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferenze Giornaliere',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Indica il tipo di cucina per ogni giorno.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                final dayNumber = index + 1;
                final pref = _dayPreferences[dayNumber] ??
                    const DayPreference();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayNames[index],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Pranzo: '),
                            Expanded(
                              child: DropdownButton<MealPreference>(
                                value: pref.lunch,
                                isExpanded: true,
                                onChanged: (value) {
                                  setState(() {
                                    _dayPreferences[dayNumber] = DayPreference(
                                      lunch: value ?? pref.lunch,
                                      dinner: pref.dinner,
                                    );
                                  });
                                },
                                items: MealPreference.values
                                    .map((p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(_mealPrefLabel(p)),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Cena:    '),
                            Expanded(
                              child: DropdownButton<MealPreference>(
                                value: pref.dinner,
                                isExpanded: true,
                                onChanged: (value) {
                                  setState(() {
                                    _dayPreferences[dayNumber] = DayPreference(
                                      lunch: pref.lunch,
                                      dinner: value ?? pref.dinner,
                                    );
                                  });
                                },
                                items: MealPreference.values
                                    .map((p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(_mealPrefLabel(p)),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _restrictionLabel(DietaryRestriction restriction) {
    switch (restriction) {
      case DietaryRestriction.vegetarian:
        return 'Vegetariano';
      case DietaryRestriction.vegan:
        return 'Vegano';
      case DietaryRestriction.glutenFree:
        return 'Senza glutine';
      case DietaryRestriction.lactoseFree:
        return 'Senza lattosio';
      case DietaryRestriction.halal:
        return 'Halal';
      case DietaryRestriction.kosher:
        return 'Kosher';
      case DietaryRestriction.none:
        return 'Nessuna';
    }
  }

  String _difficultyLabel(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.quick:
        return 'Veloce';
      case RecipeDifficulty.medium:
        return 'Medio';
      case RecipeDifficulty.elaborate:
        return 'Elaborato';
    }
  }

  String _mealPrefLabel(MealPreference pref) {
    switch (pref) {
      case MealPreference.quick:
        return 'Veloce (<30min)';
      case MealPreference.medium:
        return 'Medio (30-60min)';
      case MealPreference.elaborate:
        return 'Elaborato (>60min)';
      case MealPreference.notCooking:
        return 'Non cucino';
    }
  }
}

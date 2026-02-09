import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

/// Screen displaying the weekly meal plan with options to approve, regenerate, or modify.
class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlan = ref.watch(currentMealPlanProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Piano Settimanale'),
        actions: [
          if (mealPlan != null && mealPlan.status == MealPlanStatus.draft)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Rigenera piano',
              onPressed: () => _regeneratePlan(ref, userProfile),
            ),
        ],
      ),
      body: mealPlan == null
          ? _buildEmptyState(context, ref, userProfile)
          : _buildPlanView(context, ref, mealPlan),
      floatingActionButton: mealPlan != null &&
              mealPlan.status == MealPlanStatus.draft
          ? FloatingActionButton.extended(
              onPressed: () {
                ref.read(currentMealPlanProvider.notifier).approvePlan();
                _generateShoppingList(ref, mealPlan);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Piano approvato! Lista spesa generata.')),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Approva e genera lista spesa'),
            )
          : null,
    );
  }

  Widget _buildEmptyState(
      BuildContext context, WidgetRef ref, UserProfile? userProfile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Nessun piano attivo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Genera il tuo piano settimanale!'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: userProfile != null
                ? () => _generatePlan(ref, userProfile)
                : null,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Genera Piano'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanView(BuildContext context, WidgetRef ref, MealPlan plan) {
    final dateFormat = DateFormat('EEEE d MMMM', 'it_IT');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plan.days.length,
      itemBuilder: (context, index) {
        final day = plan.days[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(day.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(),
                _buildMealRow(
                  context,
                  ref,
                  '🍽️ Pranzo',
                  day.lunch,
                  day.lunchStatus,
                  day.date,
                  true,
                  plan.status,
                ),
                const SizedBox(height: 8),
                _buildMealRow(
                  context,
                  ref,
                  '🌙 Cena',
                  day.dinner,
                  day.dinnerStatus,
                  day.date,
                  false,
                  plan.status,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealRow(
    BuildContext context,
    WidgetRef ref,
    String label,
    Recipe? recipe,
    MealStatus status,
    DateTime date,
    bool isLunch,
    MealPlanStatus planStatus,
  ) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: recipe != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        decoration: status == MealStatus.skipped
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      '${recipe.preparationMinutes} min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
              : const Text(
                  'Non cucino',
                  style: TextStyle(color: Colors.grey),
                ),
        ),
        if (recipe != null && planStatus == MealPlanStatus.approved)
          _buildMealStatusChip(status),
        if (recipe != null && planStatus == MealPlanStatus.approved)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'cooked') {
                ref.read(currentMealPlanProvider.notifier).updateMealStatus(
                      date, isLunch, MealStatus.cooked);
              } else if (value == 'skipped') {
                ref.read(currentMealPlanProvider.notifier).updateMealStatus(
                      date, isLunch, MealStatus.skipped);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'cooked',
                child: Text('✅ Cucinato'),
              ),
              const PopupMenuItem(
                value: 'skipped',
                child: Text('❌ Non cucino'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMealStatusChip(MealStatus status) {
    Color color;
    String label;
    switch (status) {
      case MealStatus.planned:
        color = Colors.blue;
        label = 'Pianificato';
        break;
      case MealStatus.cooked:
        color = Colors.green;
        label = 'Cucinato';
        break;
      case MealStatus.skipped:
        color = Colors.red;
        label = 'Saltato';
        break;
      case MealStatus.moved:
        color = Colors.orange;
        label = 'Spostato';
        break;
    }
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  void _generatePlan(WidgetRef ref, UserProfile userProfile) {
    final generator = ref.read(mealPlanGeneratorProvider);
    final recipes = ref.read(recipeCatalogProvider);
    final pantryItems = ref.read(pantryItemsProvider);

    final plan = generator.generateWeeklyPlan(
      userProfile: userProfile,
      recipeDatabase: recipes,
      planId: const Uuid().v4(),
      pantryItems: pantryItems,
    );

    ref.read(currentMealPlanProvider.notifier).setPlan(plan);
  }

  void _regeneratePlan(WidgetRef ref, UserProfile? userProfile) {
    if (userProfile == null) return;
    _generatePlan(ref, userProfile);
  }

  void _generateShoppingList(WidgetRef ref, MealPlan plan) {
    final generator = ref.read(shoppingListGeneratorProvider);
    final pantryItems = ref.read(pantryItemsProvider);

    final list = generator.generateFromMealPlan(
      mealPlan: plan,
      listId: const Uuid().v4(),
      pantryItems: pantryItems,
    );

    ref.read(currentShoppingListProvider.notifier).setList(list);
  }
}

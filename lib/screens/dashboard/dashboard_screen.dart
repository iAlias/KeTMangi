import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

/// Home dashboard screen showing key metrics and quick actions.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlan = ref.watch(currentMealPlanProvider);
    final shoppingList = ref.watch(currentShoppingListProvider);
    final urgentCount = ref.watch(urgentPantryCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KeTMangi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Benvenuto! 👋',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pianifica i pasti, riduci gli sprechi.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // This week summary
            Text(
              'Questa Settimana',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.restaurant,
                    label: 'Pasti pianificati',
                    value: '${mealPlan?.totalMeals ?? 0}',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Completati',
                    value: '${mealPlan?.completedMeals ?? 0}',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.cancel,
                    label: 'Saltati',
                    value: '${mealPlan?.skippedMeals ?? 0}',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Shopping list status
            if (shoppingList != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.green),
                  title: const Text('Lista della Spesa'),
                  subtitle: Text(
                    '${shoppingList.remainingCount} articoli da acquistare',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),

            // Pantry alerts
            if (urgentCount > 0)
              Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: Icon(Icons.warning, color: Colors.red.shade700),
                  title: const Text('Attenzione Dispensa'),
                  subtitle: Text(
                    '$urgentCount ingredienti in scadenza!',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

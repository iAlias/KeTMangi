import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

/// Settings screen for modifying user preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        children: [
          // Profile section
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profilo'),
            subtitle: Text(profile != null
                ? '${profile.numberOfPeople} persone · ${profile.planningDays} giorni'
                : 'Non configurato'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to edit profile
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Restrizioni Alimentari'),
            subtitle: Text(
              profile?.restrictions.isEmpty ?? true
                  ? 'Nessuna'
                  : profile!.restrictions
                      .map((r) => r.name)
                      .join(', '),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Piatti Preferiti'),
            subtitle: Text(
              '${profile?.favoriteRecipes.length ?? 0} piatti selezionati',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifiche'),
            subtitle: const Text('Gestisci le tue notifiche'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Informazioni'),
            subtitle: const Text('KeTMangi v1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Reset App',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text('Cancella tutti i dati'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset App'),
                  content: const Text(
                    'Sei sicuro di voler cancellare tutti i dati? Questa azione non è reversibile.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annulla'),
                    ),
                    FilledButton(
                      onPressed: () {
                        ref.read(userProfileProvider.notifier).clearProfile();
                        ref.read(currentMealPlanProvider.notifier).clearPlan();
                        ref.read(currentShoppingListProvider.notifier).clearList();
                        ref.read(pantryItemsProvider.notifier).setItems([]);
                        Navigator.of(context).pop();
                        context.go('/onboarding');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Conferma'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

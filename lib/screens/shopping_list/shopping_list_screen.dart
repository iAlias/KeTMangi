import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

/// Screen displaying the generated shopping list organized by category.
class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = ref.watch(currentShoppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista della Spesa'),
        actions: [
          if (shoppingList != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Condividi',
              onPressed: () {
                _shareList(context, shoppingList);
              },
            ),
        ],
      ),
      body: shoppingList == null
          ? _buildEmptyState(context)
          : _buildListView(context, ref, shoppingList),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Nessuna lista attiva',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Approva un piano settimanale per generare la lista.'),
        ],
      ),
    );
  }

  Widget _buildListView(
      BuildContext context, WidgetRef ref, ShoppingList list) {
    final grouped = list.itemsByCategory;
    final categories = grouped.keys.toList();

    return Column(
      children: [
        // Cost summary card
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Costo stimato',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '€${list.estimatedCostMin.toStringAsFixed(2)} - €${list.estimatedCostMax.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Da acquistare',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '${list.remainingCount} / ${list.items.length}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Items by category
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, catIndex) {
              final category = categories[catIndex];
              final items = grouped[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      _categoryLabel(category),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...items.asMap().entries.map((entry) {
                    final item = entry.value;
                    final actualIndex = list.items.indexOf(item);

                    return ListTile(
                      leading: Checkbox(
                        value: item.isPurchased || item.alreadyOwned,
                        onChanged: (value) {
                          if (!item.alreadyOwned) {
                            ref
                                .read(currentShoppingListProvider.notifier)
                                .togglePurchased(actualIndex);
                          }
                        },
                      ),
                      title: Text(
                        item.ingredient.name,
                        style: TextStyle(
                          decoration: (item.isPurchased || item.alreadyOwned)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        '${item.totalQuantity.toStringAsFixed(0)} ${item.displayUnit}',
                      ),
                      trailing: item.alreadyOwned
                          ? const Chip(
                              label: Text('In dispensa'),
                              visualDensity: VisualDensity.compact,
                            )
                          : item.suggestedShelfLifeDays != null
                              ? Text(
                                  '${item.suggestedShelfLifeDays}gg',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              : null,
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _categoryLabel(IngredientCategory category) {
    switch (category) {
      case IngredientCategory.fresh:
        return '🥬 Fresco';
      case IngredientCategory.pantry:
        return '🥫 Dispensa';
      case IngredientCategory.frozen:
        return '🧊 Surgelati';
      case IngredientCategory.staple:
        return '✅ Ingredienti base';
    }
  }

  void _shareList(BuildContext context, ShoppingList list) {
    final buffer = StringBuffer();
    buffer.writeln('🛒 Lista della Spesa - KeTMangi');
    buffer.writeln('');

    final grouped = list.itemsByCategory;
    for (final category in grouped.keys) {
      buffer.writeln(_categoryLabel(category));
      for (final item in grouped[category]!) {
        if (!item.alreadyOwned) {
          final check = item.isPurchased ? '✅' : '⬜';
          buffer.writeln(
              '$check ${item.ingredient.name} - ${item.totalQuantity.toStringAsFixed(0)} ${item.displayUnit}');
        }
      }
      buffer.writeln('');
    }

    buffer.writeln(
        'Costo stimato: €${list.estimatedCostMin.toStringAsFixed(2)} - €${list.estimatedCostMax.toStringAsFixed(2)}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lista copiata negli appunti!')),
    );
  }
}

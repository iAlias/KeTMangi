import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

/// Screen for managing the pantry, showing items organized by expiry urgency.
class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedItems = ref.watch(sortedPantryItemsProvider);
    final urgentCount = ref.watch(urgentPantryCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Dispensa'),
            if (urgentCount > 0) ...[
              const SizedBox(width: 8),
              Badge(
                label: Text('$urgentCount'),
                child: const Icon(Icons.warning_amber),
              ),
            ],
          ],
        ),
      ),
      body: sortedItems.isEmpty
          ? _buildEmptyState(context)
          : _buildPantryList(context, ref, sortedItems),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.kitchen_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Dispensa vuota',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Aggiungi ingredienti alla tua dispensa.'),
        ],
      ),
    );
  }

  Widget _buildPantryList(
      BuildContext context, WidgetRef ref, List<PantryItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: _urgencyColor(item.urgency),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _urgencyIconColor(item.urgency),
              child: Text(
                _urgencyEmoji(item.urgency),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(item.ingredient.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.quantityInStock} ${item.ingredient.defaultUnit}'),
                if (item.daysUntilExpiry != null)
                  Text(
                    item.isExpired
                        ? 'Scaduto!'
                        : item.daysUntilExpiry == 0
                            ? 'Scade oggi!'
                            : 'Scade tra ${item.daysUntilExpiry} giorni',
                    style: TextStyle(
                      color: item.urgency == ExpiryUrgency.critical
                          ? Colors.red
                          : item.urgency == ExpiryUrgency.warning
                              ? Colors.orange
                              : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'used') {
                  ref.read(pantryItemsProvider.notifier).markAsUsed(item.id);
                } else if (value == 'delete') {
                  ref.read(pantryItemsProvider.notifier).removeItem(item.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'used',
                  child: Text('✅ Segna come usato'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('🗑️ Elimina'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _urgencyColor(ExpiryUrgency urgency) {
    switch (urgency) {
      case ExpiryUrgency.critical:
        return Colors.red.shade50;
      case ExpiryUrgency.warning:
        return Colors.orange.shade50;
      case ExpiryUrgency.ok:
        return Colors.green.shade50;
    }
  }

  Color _urgencyIconColor(ExpiryUrgency urgency) {
    switch (urgency) {
      case ExpiryUrgency.critical:
        return Colors.red.shade100;
      case ExpiryUrgency.warning:
        return Colors.orange.shade100;
      case ExpiryUrgency.ok:
        return Colors.green.shade100;
    }
  }

  String _urgencyEmoji(ExpiryUrgency urgency) {
    switch (urgency) {
      case ExpiryUrgency.critical:
        return '🔴';
      case ExpiryUrgency.warning:
        return '🟡';
      case ExpiryUrgency.ok:
        return '🟢';
    }
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _AddPantryItemDialog(),
    );
  }
}

class _AddPantryItemDialog extends ConsumerStatefulWidget {
  const _AddPantryItemDialog();

  @override
  ConsumerState<_AddPantryItemDialog> createState() =>
      _AddPantryItemDialogState();
}

class _AddPantryItemDialogState extends ConsumerState<_AddPantryItemDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  IngredientCategory _category = IngredientCategory.fresh;
  DateTime? _expiryDate;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aggiungi alla Dispensa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome ingrediente',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Quantità',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<IngredientCategory>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Categoria',
              border: OutlineInputBorder(),
            ),
            items: IngredientCategory.values
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(_categoryLabel(c)),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_expiryDate != null
                ? 'Scadenza: ${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                : 'Data di scadenza (opzionale)'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _expiryDate = date);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.isEmpty) return;

            final item = PantryItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: 'user-1',
              ingredient: Ingredient(
                id: _nameController.text.toLowerCase().replaceAll(' ', '-'),
                name: _nameController.text,
                category: _category,
              ),
              quantityInStock:
                  double.tryParse(_quantityController.text) ?? 1,
              expiryDate: _expiryDate,
              addedAt: DateTime.now(),
            );

            ref.read(pantryItemsProvider.notifier).addItem(item);
            Navigator.of(context).pop();
          },
          child: const Text('Aggiungi'),
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
}

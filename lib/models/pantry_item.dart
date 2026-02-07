import 'ingredient.dart';

/// Represents an ingredient stored in the user's pantry.
class PantryItem {
  final String id;
  final String userId;
  final Ingredient ingredient;
  final double quantityInStock;
  final DateTime? expiryDate;
  final DateTime addedAt;
  final PantryStatus status;

  const PantryItem({
    required this.id,
    required this.userId,
    required this.ingredient,
    required this.quantityInStock,
    this.expiryDate,
    required this.addedAt,
    this.status = PantryStatus.available,
  });

  PantryItem copyWith({
    String? id,
    String? userId,
    Ingredient? ingredient,
    double? quantityInStock,
    DateTime? expiryDate,
    DateTime? addedAt,
    PantryStatus? status,
  }) {
    return PantryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ingredient: ingredient ?? this.ingredient,
      quantityInStock: quantityInStock ?? this.quantityInStock,
      expiryDate: expiryDate ?? this.expiryDate,
      addedAt: addedAt ?? this.addedAt,
      status: status ?? this.status,
    );
  }

  /// Days until the ingredient expires, or null if no expiry date is set.
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Whether the ingredient is expiring within 2 days.
  bool get isExpiringSoon {
    final days = daysUntilExpiry;
    return days != null && days >= 0 && days <= 2;
  }

  /// Whether the ingredient has already expired.
  bool get isExpired {
    final days = daysUntilExpiry;
    return days != null && days < 0;
  }

  /// Returns the urgency level based on expiry date.
  ExpiryUrgency get urgency {
    final days = daysUntilExpiry;
    if (days == null) return ExpiryUrgency.ok;
    if (days < 0) return ExpiryUrgency.critical;
    if (days <= 2) return ExpiryUrgency.critical;
    if (days <= 7) return ExpiryUrgency.warning;
    return ExpiryUrgency.ok;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'ingredient': ingredient.toJson(),
        'quantityInStock': quantityInStock,
        'expiryDate': expiryDate?.toIso8601String(),
        'addedAt': addedAt.toIso8601String(),
        'status': status.name,
      };

  factory PantryItem.fromJson(Map<String, dynamic> json) => PantryItem(
        id: json['id'] as String,
        userId: json['userId'] as String,
        ingredient:
            Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
        quantityInStock: (json['quantityInStock'] as num).toDouble(),
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'] as String)
            : null,
        addedAt: DateTime.parse(json['addedAt'] as String),
        status: PantryStatus.values.byName(json['status'] as String),
      );
}

/// Status of a pantry item.
enum PantryStatus {
  available,
  used,
  expired,
  wasted,
}

/// Urgency level for expiring ingredients.
enum ExpiryUrgency {
  critical,  // 🔴 In scadenza (0-2 giorni)
  warning,   // 🟡 Da usare presto (3-7 giorni)
  ok,        // 🟢 Dispensa stabile
}

import 'recipe.dart';

/// Represents a complete weekly meal plan.
class MealPlan {
  final String id;
  final String userId;
  final DateTime weekStartDate;
  final List<DayMeals> days;
  final MealPlanStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;

  const MealPlan({
    required this.id,
    required this.userId,
    required this.weekStartDate,
    required this.days,
    this.status = MealPlanStatus.draft,
    required this.createdAt,
    this.approvedAt,
  });

  MealPlan copyWith({
    String? id,
    String? userId,
    DateTime? weekStartDate,
    List<DayMeals>? days,
    MealPlanStatus? status,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      days: days ?? this.days,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  /// Total number of planned meals in this plan.
  int get totalMeals =>
      days.fold(0, (sum, day) => sum + (day.lunch != null ? 1 : 0) + (day.dinner != null ? 1 : 0));

  /// Number of completed meals.
  int get completedMeals => days.fold(
      0,
      (sum, day) =>
          sum +
          (day.lunchStatus == MealStatus.cooked ? 1 : 0) +
          (day.dinnerStatus == MealStatus.cooked ? 1 : 0));

  /// Number of skipped meals.
  int get skippedMeals => days.fold(
      0,
      (sum, day) =>
          sum +
          (day.lunchStatus == MealStatus.skipped ? 1 : 0) +
          (day.dinnerStatus == MealStatus.skipped ? 1 : 0));

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'weekStartDate': weekStartDate.toIso8601String(),
        'days': days.map((d) => d.toJson()).toList(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'approvedAt': approvedAt?.toIso8601String(),
      };

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
        id: json['id'] as String,
        userId: json['userId'] as String,
        weekStartDate: DateTime.parse(json['weekStartDate'] as String),
        days: (json['days'] as List)
            .map((d) => DayMeals.fromJson(d as Map<String, dynamic>))
            .toList(),
        status: MealPlanStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        approvedAt: json['approvedAt'] != null
            ? DateTime.parse(json['approvedAt'] as String)
            : null,
      );
}

/// Meals planned for a single day.
class DayMeals {
  final DateTime date;
  final Recipe? lunch;
  final Recipe? dinner;
  final MealStatus lunchStatus;
  final MealStatus dinnerStatus;

  const DayMeals({
    required this.date,
    this.lunch,
    this.dinner,
    this.lunchStatus = MealStatus.planned,
    this.dinnerStatus = MealStatus.planned,
  });

  DayMeals copyWith({
    DateTime? date,
    Recipe? lunch,
    Recipe? dinner,
    MealStatus? lunchStatus,
    MealStatus? dinnerStatus,
  }) {
    return DayMeals(
      date: date ?? this.date,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      lunchStatus: lunchStatus ?? this.lunchStatus,
      dinnerStatus: dinnerStatus ?? this.dinnerStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'lunch': lunch?.toJson(),
        'dinner': dinner?.toJson(),
        'lunchStatus': lunchStatus.name,
        'dinnerStatus': dinnerStatus.name,
      };

  factory DayMeals.fromJson(Map<String, dynamic> json) => DayMeals(
        date: DateTime.parse(json['date'] as String),
        lunch: json['lunch'] != null
            ? Recipe.fromJson(json['lunch'] as Map<String, dynamic>)
            : null,
        dinner: json['dinner'] != null
            ? Recipe.fromJson(json['dinner'] as Map<String, dynamic>)
            : null,
        lunchStatus: MealStatus.values.byName(json['lunchStatus'] as String),
        dinnerStatus: MealStatus.values.byName(json['dinnerStatus'] as String),
      );
}

/// Status of the meal plan.
enum MealPlanStatus {
  draft,
  approved,
  active,
  completed,
}

/// Status of an individual meal.
enum MealStatus {
  planned,
  cooked,
  skipped,
  moved,
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required int id,
    @JsonKey(name: 'user_id') required String userId,
    required String description,
    required double amount,
    required DateTime date,
    String? category,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
} 
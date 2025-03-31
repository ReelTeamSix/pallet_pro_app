// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Expense _$ExpenseFromJson(Map<String, dynamic> json) => _Expense(
  id: (json['id'] as num).toInt(),
  userId: json['user_id'] as String,
  description: json['description'] as String,
  amount: (json['amount'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  category: json['category'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ExpenseToJson(_Expense instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'description': instance.description,
  'amount': instance.amount,
  'date': instance.date.toIso8601String(),
  'category': instance.category,
  'created_at': instance.createdAt.toIso8601String(),
};

import 'dart:convert';

import 'package:stockflow_flutter_pro/models/inventory_item.dart';
import 'package:stockflow_flutter_pro/models/store_submission.dart';
import 'package:stockflow_flutter_pro/models/user_account.dart';

class AppStateBundle {
  AppStateBundle({
    required this.accounts,
    required this.items,
    required this.submissions,
  });

  final List<UserAccount> accounts;
  final List<InventoryItem> items;
  final List<StoreSubmission> submissions;

  factory AppStateBundle.fromJson(Map<String, dynamic> json) => AppStateBundle(
    accounts: (json['accounts'] as List<dynamic>)
        .map((item) => UserAccount.fromJson(item as Map<String, dynamic>))
        .toList(),
    items: (json['items'] as List<dynamic>)
        .map((item) => InventoryItem.fromJson(item as Map<String, dynamic>))
        .toList(),
    submissions: (json['submissions'] as List<dynamic>)
        .map((item) => StoreSubmission.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  factory AppStateBundle.fromRawJson(String value) =>
      AppStateBundle.fromJson(jsonDecode(value) as Map<String, dynamic>);

  String toRawJson() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
    'accounts': accounts.map((item) => item.toJson()).toList(),
    'items': items.map((item) => item.toJson()).toList(),
    'submissions': submissions.map((item) => item.toJson()).toList(),
  };

  AppStateBundle copyWith({
    List<UserAccount>? accounts,
    List<InventoryItem>? items,
    List<StoreSubmission>? submissions,
  }) {
    return AppStateBundle(
      accounts: accounts ?? this.accounts,
      items: items ?? this.items,
      submissions: submissions ?? this.submissions,
    );
  }
}

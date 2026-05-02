class SubmissionEntry {
  SubmissionEntry({required this.itemId, required this.quantity});

  final String itemId;
  final int quantity;

  factory SubmissionEntry.fromJson(Map<String, dynamic> json) =>
      SubmissionEntry(
        itemId: json['itemId'] as String,
        quantity: json['quantity'] as int,
      );

  Map<String, dynamic> toJson() => {'itemId': itemId, 'quantity': quantity};
}

class StoreSubmission {
  StoreSubmission({
    required this.id,
    required this.storeUsername,
    required this.note,
    required this.submittedAt,
    required this.entries,
  });

  final String id;
  final String storeUsername;
  final String note;
  final DateTime submittedAt;
  final List<SubmissionEntry> entries;

  factory StoreSubmission.fromJson(Map<String, dynamic> json) =>
      StoreSubmission(
        id: json['id'] as String,
        storeUsername: json['storeUsername'] as String,
        note: json['note'] as String? ?? '',
        submittedAt: DateTime.parse(json['submittedAt'] as String),
        entries: (json['entries'] as List<dynamic>)
            .map(
              (entry) =>
                  SubmissionEntry.fromJson(entry as Map<String, dynamic>),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'storeUsername': storeUsername,
    'note': note,
    'submittedAt': submittedAt.toIso8601String(),
    'entries': entries.map((entry) => entry.toJson()).toList(),
  };
}

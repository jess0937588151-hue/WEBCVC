class InventoryItem {
  InventoryItem({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.safetyStock,
    required this.leadTimeDays,
    required this.supplier,
  });

  final String id;
  final String sku;
  final String name;
  final String category;
  final String unit;
  final int currentStock;
  final int safetyStock;
  final int leadTimeDays;
  final String supplier;

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'] as String,
    sku: json['sku'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    unit: json['unit'] as String,
    currentStock: json['currentStock'] as int,
    safetyStock: json['safetyStock'] as int,
    leadTimeDays: json['leadTimeDays'] as int? ?? 0,
    supplier: json['supplier'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sku': sku,
    'name': name,
    'category': category,
    'unit': unit,
    'currentStock': currentStock,
    'safetyStock': safetyStock,
    'leadTimeDays': leadTimeDays,
    'supplier': supplier,
  };

  InventoryItem copyWith({
    String? id,
    String? sku,
    String? name,
    String? category,
    String? unit,
    int? currentStock,
    int? safetyStock,
    int? leadTimeDays,
    String? supplier,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      safetyStock: safetyStock ?? this.safetyStock,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      supplier: supplier ?? this.supplier,
    );
  }
}

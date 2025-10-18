class GiftSummary {
  final Map<String, GiftSummaryItem> items;
  final int total;

  GiftSummary({
    required this.items,
    required this.total,
  });

  factory GiftSummary.fromJson(Map<String, dynamic> json) {
    final items = <String, GiftSummaryItem>{};
    
    json.forEach((key, value) {
      if (key != 'total' && value is Map<String, dynamic>) {
        items[key] = GiftSummaryItem.fromJson(value);
      }
    });

    return GiftSummary(
      items: items,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    items.forEach((key, value) {
      json[key] = value.toJson();
    });
    
    json['total'] = total;
    
    return json;
  }

  List<GiftSummaryItem> get itemsList => items.values.toList();
}

class GiftSummaryItem {
  final String name;
  final String unit;
  final int qty;

  GiftSummaryItem({
    required this.name,
    required this.unit,
    required this.qty,
  });

  factory GiftSummaryItem.fromJson(Map<String, dynamic> json) {
    return GiftSummaryItem(
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      qty: json['qty'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'qty': qty,
    };
  }
}

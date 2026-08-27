class BillItem {
  const BillItem({
    this.name,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
  });

  final String? name;
  final int? quantity;
  final int? unitPrice;
  final int? totalPrice;

  BillItem copyWith({
    String? name,
    int? quantity,
    int? unitPrice,
    int? totalPrice,
  }) {
    return BillItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };

  @override
  List<Object?> get props => [name, quantity, unitPrice, totalPrice];
}

class BillParseResult {
  const BillParseResult({
    this.vendor,
    this.date,
    this.totalAmount,
    this.taxAmount,
    this.discountAmount,
    this.items = const [],
    this.categoryHint,
    this.rawOcrText,
    this.invoiceNumber,
  });

  final String? vendor;
  final DateTime? date;
  final int? totalAmount;
  final int? taxAmount;
  final int? discountAmount;
  final List<BillItem> items;
  final String? categoryHint;
  final String? rawOcrText;
  final String? invoiceNumber;

  BillParseResult copyWith({
    String? vendor,
    DateTime? date,
    int? totalAmount,
    int? taxAmount,
    int? discountAmount,
    List<BillItem>? items,
    String? categoryHint,
    String? rawOcrText,
    String? invoiceNumber,
  }) {
    return BillParseResult(
      vendor: vendor ?? this.vendor,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      items: items ?? this.items,
      categoryHint: categoryHint ?? this.categoryHint,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'vendor': vendor,
        'date': date?.toIso8601String(),
        'totalAmount': totalAmount,
        'taxAmount': taxAmount,
        'discountAmount': discountAmount,
        'items': items.map((i) => i.toJson()).toList(),
        'categoryHint': categoryHint,
        'rawOcrText': rawOcrText,
        'invoiceNumber': invoiceNumber,
      };

  bool get isEmpty =>
      vendor == null &&
      totalAmount == null &&
      items.isEmpty &&
      categoryHint == null;

  @override
  List<Object?> get props => [
        vendor,
        date,
        totalAmount,
        taxAmount,
        discountAmount,
        items,
        categoryHint,
        rawOcrText,
        invoiceNumber,
      ];
}

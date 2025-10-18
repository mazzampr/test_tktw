class CustomerListItem {
  final String name;
  final String custID;

  CustomerListItem({
    required this.name,
    required this.custID,
  });

  factory CustomerListItem.fromJson(Map<String, dynamic> json) {
    return CustomerListItem(
      name: json['name'] ?? '',
      custID: json['CustID'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'CustID': custID,
    };
  }
}

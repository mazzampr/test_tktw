class Customer {
  final String custID;
  final String name;
  final String? address;
  final String? branchCode;
  final String? phoneNo;
  final List<Gift>? gifts;

  Customer({
    required this.custID,
    required this.name,
    this.address,
    this.branchCode,
    this.phoneNo,
    this.gifts,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      custID: json['CustID'] ?? json['CustID'] ?? '',
      name: json['Name'] ?? json['name'] ?? '',
      address: json['Address'] as String?,
      branchCode: json['BranchCode'] as String?,
      phoneNo: json['PhoneNo'] as String?,
      gifts: json['gifts'] != null
          ? (json['gifts'] as List).map((e) => Gift.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CustID': custID,
      'Name': name,
      if (address != null) 'Address': address,
      if (branchCode != null) 'BranchCode': branchCode,
      if (phoneNo != null) 'PhoneNo': phoneNo,
      if (gifts != null) 'gifts': gifts!.map((e) => e.toJson()).toList(),
    };
  }
}

class Gift {
  final int id;
  final String tthNo;
  final String salesID;
  final String ttOTTPNo;
  final String custID;
  final String docDate;
  final bool received;
  final String? receivedDate;
  final String? failedReason;
  final List<GiftDetail>? detail;

  Gift({
    required this.id,
    required this.tthNo,
    required this.salesID,
    required this.ttOTTPNo,
    required this.custID,
    required this.docDate,
    required this.received,
    this.receivedDate,
    this.failedReason,
    this.detail,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['ID'] ?? 0,
      tthNo: json['TTHNo'] ?? '',
      salesID: json['SalesID'] ?? '',
      ttOTTPNo: json['TTOTTPNo'] ?? '',
      custID: json['CustID'] ?? '',
      docDate: json['DocDate'] ?? '',
      received: json['Received'] ?? false,
      receivedDate: json['ReceivedDate'] as String?,
      failedReason: json['FailedReason'] as String?,
      detail: json['detail'] != null
          ? (json['detail'] as List).map((e) => GiftDetail.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TTHNo': tthNo,
      'SalesID': salesID,
      'TTOTTPNo': ttOTTPNo,
      'CustID': custID,
      'DocDate': docDate,
      'Received': received,
      if (receivedDate != null) 'ReceivedDate': receivedDate,
      if (failedReason != null) 'FailedReason': failedReason,
      if (detail != null) 'detail': detail!.map((e) => e.toJson()).toList(),
    };
  }
}

class GiftDetail {
  final int id;
  final String tthNo;
  final String ttOTTPNo;
  final String jenis;
  final int qty;
  final String unit;

  GiftDetail({
    required this.id,
    required this.tthNo,
    required this.ttOTTPNo,
    required this.jenis,
    required this.qty,
    required this.unit,
  });

  factory GiftDetail.fromJson(Map<String, dynamic> json) {
    return GiftDetail(
      id: json['ID'] ?? 0,
      tthNo: json['TTHNo'] ?? '',
      ttOTTPNo: json['TTOTTPNo'] ?? '',
      jenis: json['Jenis'] ?? '',
      qty: json['Qty'] ?? 0,
      unit: json['Unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TTHNo': tthNo,
      'TTOTTPNo': ttOTTPNo,
      'Jenis': jenis,
      'Qty': qty,
      'Unit': unit,
    };
  }
}

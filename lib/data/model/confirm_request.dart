class ConfirmRequest {
  final String action; // "accept" or "reject"
  final String reason;

  ConfirmRequest({
    required this.action,
    this.reason = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'reason': reason,
    };
  }

  factory ConfirmRequest.fromJson(Map<String, dynamic> json) {
    return ConfirmRequest(
      action: json['action'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  // Helper factory methods
  factory ConfirmRequest.accept({String reason = ''}) {
    return ConfirmRequest(action: 'accept', reason: reason);
  }

  factory ConfirmRequest.reject({required String reason}) {
    return ConfirmRequest(action: 'reject', reason: reason);
  }
}

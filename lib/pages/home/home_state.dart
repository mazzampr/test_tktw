part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class CustomerListLoaded extends HomeState {
  final List<CustomerListItem> customers;
  final CustomerListItem? selectedCustomer;

  const CustomerListLoaded({
    required this.customers,
    this.selectedCustomer,
  });

  @override
  List<Object?> get props => [customers, selectedCustomer];

  CustomerListLoaded copyWith({
    List<CustomerListItem>? customers,
    CustomerListItem? selectedCustomer,
  }) {
    return CustomerListLoaded(
      customers: customers ?? this.customers,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
    );
  }
}

class CustomerDetailLoaded extends HomeState {
  final List<CustomerListItem> customers;
  final CustomerListItem selectedCustomer;
  final Customer customerDetail;

  const CustomerDetailLoaded({
    required this.customers,
    required this.selectedCustomer,
    required this.customerDetail,
  });

  @override
  List<Object?> get props => [customers, selectedCustomer, customerDetail];

  String get customerStatus {
    if (customerDetail.gifts == null || customerDetail.gifts!.isEmpty) {
      return 'Belum Diberikan';
    }

    bool allReceived = customerDetail.gifts!.every((gift) => gift.received);
    bool anyFailed = customerDetail.gifts!.any(
      (gift) =>
          !gift.received &&
          gift.failedReason != null &&
          gift.failedReason!.isNotEmpty,
    );

    if (allReceived) {
      return 'Sudah Diterima';
    } else if (anyFailed) {
      return 'Gagal Diterima';
    } else {
      return 'Belum Diberikan';
    }
  }
}

class AllCustomersLoaded extends HomeState {
  final List<CustomerListItem> customerList;
  final List<Customer> allCustomers;

  const AllCustomersLoaded({
    required this.customerList,
    required this.allCustomers,
  });

  @override
  List<Object?> get props => [customerList, allCustomers];
}

class AllCustomersWithGiftSummaryLoaded extends HomeState {
  final List<CustomerListItem> customerList;
  final List<Customer> allCustomers;
  final GiftSummary giftSummary;

  const AllCustomersWithGiftSummaryLoaded({
    required this.customerList,
    required this.allCustomers,
    required this.giftSummary,
  });

  @override
  List<Object?> get props => [customerList, allCustomers, giftSummary];
}

class GiftSummaryLoaded extends HomeState {
  final List<CustomerListItem> customers;
  final CustomerListItem selectedCustomer;
  final Customer customerDetail;
  final GiftSummary giftSummary;

  const GiftSummaryLoaded({
    required this.customers,
    required this.selectedCustomer,
    required this.customerDetail,
    required this.giftSummary,
  });

  @override
  List<Object?> get props => [
        customers,
        selectedCustomer,
        customerDetail,
        giftSummary,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

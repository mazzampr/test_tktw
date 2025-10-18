import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasource/remote_datasource.dart';
import '../../data/model/customer.dart';
import '../../data/model/customer_list_item.dart';
import '../../data/model/gift_summary.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final RemoteDatasource remoteDatasource;

  HomeBloc({required this.remoteDatasource}) : super(HomeInitial()) {
    on<LoadCustomerListEvent>(_onLoadCustomerList);
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<LoadAllCustomersEvent>(_onLoadAllCustomers);
    on<LoadGiftSummaryEvent>(_onLoadGiftSummary);
  }

  Future<void> _onLoadCustomerList(
    LoadCustomerListEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Load both customer list and detailed customers data
      final listResponse = await remoteDatasource.getListCustomers();
      if (listResponse.success && listResponse.data != null) {
        // Also load all customers with details for better performance when selecting
        try {
          final allCustomersResponse = await remoteDatasource.getAllCustomers();
          if (allCustomersResponse.success &&
              allCustomersResponse.data != null) {
            // We have both list and detailed data, emit AllCustomersLoaded
            emit(AllCustomersLoaded(
              customerList: listResponse.data!,
              allCustomers: allCustomersResponse.data!,
            ));
          } else {
            // Fallback to just customer list
            emit(CustomerListLoaded(customers: listResponse.data!));
          }
        } catch (e) {
          // Fallback to just customer list
          emit(CustomerListLoaded(customers: listResponse.data!));
        }
      } else {
        emit(HomeError(listResponse.message ?? 'Failed to load customers'));
      }
    } catch (e) {
      emit(HomeError('Error loading customers: $e'));
    }
  }

  Future<void> _onLoadAllCustomers(
    LoadAllCustomersEvent event,
    Emitter<HomeState> emit,
  ) async {
    List<CustomerListItem>? customerList;

    // Get customer list from current state or load it
    if (state is CustomerListLoaded) {
      customerList = (state as CustomerListLoaded).customers;
    } else if (state is CustomerDetailLoaded) {
      customerList = (state as CustomerDetailLoaded).customers;
    } else if (state is GiftSummaryLoaded) {
      customerList = (state as GiftSummaryLoaded).customers;
    } else if (state is AllCustomersLoaded) {
      customerList = (state as AllCustomersLoaded).customerList;
    }

    if (customerList == null) {
      // Load customer list first
      try {
        final listResponse = await remoteDatasource.getListCustomers();
        if (listResponse.success && listResponse.data != null) {
          customerList = listResponse.data!;
        } else {
          emit(HomeError(
              listResponse.message ?? 'Failed to load customer list'));
          return;
        }
      } catch (e) {
        emit(HomeError('Error loading customer list: $e'));
        return;
      }
    }

    emit(HomeLoading());
    try {
      final response = await remoteDatasource.getAllCustomers();
      if (response.success && response.data != null) {
        emit(AllCustomersLoaded(
          customerList: customerList,
          allCustomers: response.data!,
        ));
      } else {
        emit(HomeError(response.message ?? 'Failed to load all customers'));
      }
    } catch (e) {
      emit(HomeError('Error loading all customers: $e'));
    }
  }

  Future<void> _onSelectCustomer(
    SelectCustomerEvent event,
    Emitter<HomeState> emit,
  ) async {
    List<CustomerListItem>? customers;
    List<Customer>? allCustomersData;

    // Get customers list from current state
    if (state is CustomerListLoaded) {
      customers = (state as CustomerListLoaded).customers;
    } else if (state is CustomerDetailLoaded) {
      customers = (state as CustomerDetailLoaded).customers;
    } else if (state is GiftSummaryLoaded) {
      customers = (state as GiftSummaryLoaded).customers;
    } else if (state is AllCustomersLoaded) {
      customers = (state as AllCustomersLoaded).customerList;
      allCustomersData = (state as AllCustomersLoaded).allCustomers;
    } else if (state is AllCustomersWithGiftSummaryLoaded) {
      customers = (state as AllCustomersWithGiftSummaryLoaded).customerList;
      allCustomersData =
          (state as AllCustomersWithGiftSummaryLoaded).allCustomers;
    }

    if (customers != null) {
      final selectedCustomer =
          customers.firstWhere((customer) => customer.custID == event.custID);

      emit(HomeLoading());

      Customer? customerDetail;

      // Try to use existing detailed data first (from getAllCustomers)
      if (allCustomersData != null) {
        try {
          customerDetail = allCustomersData
              .firstWhere((customer) => customer.custID == event.custID);
        } catch (e) {
          customerDetail = null;
        }
      }

      // If we don't have detailed data, fetch it from API
      if (customerDetail == null) {
        try {
          final response =
              await remoteDatasource.getDetailCustomer(event.custID);
          if (response.success && response.data != null) {
            customerDetail = response.data!;
          } else {
            emit(HomeError(
                response.message ?? 'Failed to load customer detail'));
            return;
          }
        } catch (e) {
          emit(HomeError('Error loading customer detail: $e'));
          return;
        }
      }

      // Emit the state with the customer detail
      emit(CustomerDetailLoaded(
        customers: customers,
        selectedCustomer: selectedCustomer,
        customerDetail: customerDetail,
      ));
    }
  }

  Future<void> _onLoadGiftSummary(
    LoadGiftSummaryEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Handle different states differently
    if (state is AllCustomersLoaded) {
      final currentState = state as AllCustomersLoaded;
      try {
        final response = await remoteDatasource.getGiftSummary();
        if (response.success && response.data != null) {
          emit(AllCustomersWithGiftSummaryLoaded(
            customerList: currentState.customerList,
            allCustomers: currentState.allCustomers,
            giftSummary: response.data!,
          ));
        } else {
          emit(HomeError(response.message ?? 'Failed to load gift summary'));
        }
      } catch (e) {
        emit(HomeError('Error loading gift summary: $e'));
      }
    } else if (state is CustomerDetailLoaded || state is GiftSummaryLoaded) {
      List<CustomerListItem>? customers;
      CustomerListItem? selectedCustomer;
      Customer? customerDetail;

      // Get data from current state
      if (state is CustomerDetailLoaded) {
        final currentState = state as CustomerDetailLoaded;
        customers = currentState.customers;
        selectedCustomer = currentState.selectedCustomer;
        customerDetail = currentState.customerDetail;
      } else if (state is GiftSummaryLoaded) {
        final currentState = state as GiftSummaryLoaded;
        customers = currentState.customers;
        selectedCustomer = currentState.selectedCustomer;
        customerDetail = currentState.customerDetail;
      }

      if (customers != null &&
          selectedCustomer != null &&
          customerDetail != null) {
        try {
          final response = await remoteDatasource.getGiftSummary();
          if (response.success && response.data != null) {
            emit(GiftSummaryLoaded(
              customers: customers,
              selectedCustomer: selectedCustomer,
              customerDetail: customerDetail,
              giftSummary: response.data!,
            ));
          } else {
            emit(HomeError(response.message ?? 'Failed to load gift summary'));
          }
        } catch (e) {
          emit(HomeError('Error loading gift summary: $e'));
        }
      }
    }
  }
}

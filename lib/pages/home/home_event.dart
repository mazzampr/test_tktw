part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomerListEvent extends HomeEvent {}

class SelectCustomerEvent extends HomeEvent {
  final String custID;

  const SelectCustomerEvent(this.custID);

  @override
  List<Object?> get props => [custID];
}

class LoadAllCustomersEvent extends HomeEvent {}

class LoadGiftSummaryEvent extends HomeEvent {}

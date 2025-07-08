part of 'pemesanan_customer_bloc.dart';

sealed class PemesananCustomerState {}

final class PemesananCustomerInitial extends PemesananCustomerState {}

final class PemesananCustomerLoadingState extends PemesananCustomerState {}

final class PemesananCustomerErrorState extends PemesananCustomerState {
  final String errorMessage;

  PemesananCustomerErrorState(this.errorMessage);
}

final class PemesananCustomerSuccessState extends PemesananCustomerState {
  final GetAllPemesananCustomerModel responseModel;

  PemesananCustomerSuccessState(this.responseModel);
}

final class PemesananCustomerAddSuccessState extends PemesananCustomerState {
  final GetPemesananCustomerById responseModel;

  PemesananCustomerAddSuccessState(this.responseModel);
}

final class PemesananCustomerDetailSuccessState extends PemesananCustomerState {
  final GetPemesananCustomerById responseModel;

  PemesananCustomerDetailSuccessState(this.responseModel);
}

final class PemesananCustomerUpdateSuccessState extends PemesananCustomerState {
  final GetPemesananCustomerById responseModel;

  PemesananCustomerUpdateSuccessState(this.responseModel);
}

final class PemesananCustomerDeleteSuccessState extends PemesananCustomerState {
  final String message;

  PemesananCustomerDeleteSuccessState(this.message);
}
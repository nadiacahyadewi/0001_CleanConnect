part of 'pemesanan_customer_bloc.dart';

sealed class PemesananCustomerEvent {}

final class PemesananCustomerGetAllEvent extends PemesananCustomerEvent {}

final class PemesananCustomerAddEvent extends PemesananCustomerEvent {
  final PemesananCustomerRequestModel requestModel;

  PemesananCustomerAddEvent(this.requestModel);
}

final class PemesananCustomerGetByIdEvent extends PemesananCustomerEvent {
  final int id;

  PemesananCustomerGetByIdEvent(this.id);
}

final class PemesananCustomerUpdateStatusEvent extends PemesananCustomerEvent {
  final int id;
  final String status;

  PemesananCustomerUpdateStatusEvent(this.id, this.status);
}

final class PemesananCustomerDeleteEvent extends PemesananCustomerEvent {
  final int id;

  PemesananCustomerDeleteEvent(this.id);
}
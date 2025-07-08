import 'package:bloc/bloc.dart';
import 'package:cleanconnect/data/model/request/customer/customer_pemesanan_request_model.dart';
import 'package:cleanconnect/data/model/response/user/customer_pemesanan_response_model.dart';
import 'package:cleanconnect/data/repository/pemesanan_repository.dart';
import 'package:meta/meta.dart';

part 'pemesanan_customer_event.dart';
part 'pemesanan_customer_state.dart';

class PemesananCustomerBloc extends Bloc<PemesananCustomerEvent, PemesananCustomerState> {
  final PemesananCustomerRepository _repository;

  PemesananCustomerBloc(this._repository) : super(PemesananCustomerInitial()) {
    on<PemesananCustomerGetAllEvent>(_onGetAllPemesanan);
    on<PemesananCustomerAddEvent>(_onAddPemesanan);
    on<PemesananCustomerGetByIdEvent>(_onGetPemesananById);
    on<PemesananCustomerUpdateStatusEvent>(_onUpdateStatus);
    on<PemesananCustomerDeleteEvent>(_onDeletePemesanan);
  }

  Future<void> _onGetAllPemesanan(
    PemesananCustomerGetAllEvent event,
    Emitter<PemesananCustomerState> emit,
  ) async {
    emit(PemesananCustomerLoadingState());
    
    final result = await _repository.getAllPemesanan();
    
    result.fold(
      (failure) => emit(PemesananCustomerErrorState(failure)),
      (success) => emit(PemesananCustomerSuccessState(success)),
    );
  }

  Future<void> _onAddPemesanan(
    PemesananCustomerAddEvent event,
    Emitter<PemesananCustomerState> emit,
  ) async {
    emit(PemesananCustomerLoadingState());
    
    final result = await _repository.addPemesanan(event.requestModel);
    
    result.fold(
      (failure) => emit(PemesananCustomerErrorState(failure)),
      (success) => emit(PemesananCustomerAddSuccessState(success)),
    );
  }

  Future<void> _onGetPemesananById(
    PemesananCustomerGetByIdEvent event,
    Emitter<PemesananCustomerState> emit,
  ) async {
    emit(PemesananCustomerLoadingState());
    
    final result = await _repository.getPemesananById(event.id);
    
    result.fold(
      (failure) => emit(PemesananCustomerErrorState(failure)),
      (success) => emit(PemesananCustomerDetailSuccessState(success)),
    );
  }

  Future<void> _onUpdateStatus(
    PemesananCustomerUpdateStatusEvent event,
    Emitter<PemesananCustomerState> emit,
  ) async {
    emit(PemesananCustomerLoadingState());
    
    final result = await _repository.updatePemesananStatus(event.id, event.status);
    
    result.fold(
      (failure) => emit(PemesananCustomerErrorState(failure)),
      (success) => emit(PemesananCustomerUpdateSuccessState(success)),
    );
  }

  Future<void> _onDeletePemesanan(
    PemesananCustomerDeleteEvent event,
    Emitter<PemesananCustomerState> emit,
  ) async {
    emit(PemesananCustomerLoadingState());
    
    final result = await _repository.deletePemesanan(event.id);
    
    result.fold(
      (failure) => emit(PemesananCustomerErrorState(failure)),
      (success) => emit(PemesananCustomerDeleteSuccessState(success)),
    );
  }
}
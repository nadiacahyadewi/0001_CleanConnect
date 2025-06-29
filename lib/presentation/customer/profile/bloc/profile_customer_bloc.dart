import 'package:bloc/bloc.dart';
import 'package:cleanconnect/data/model/request/customer/customer_profile_request_model.dart';
import 'package:cleanconnect/data/model/response/user/customer_profile_response_model.dart';
import 'package:cleanconnect/data/repository/profile_customer_repository.dart';
import 'package:meta/meta.dart';

part 'profile_customer_event.dart';
part 'profile_customer_state.dart';

class ProfileBuyerBloc extends Bloc<ProfileBuyerEvent, ProfileBuyerState> {
  final ProfileBuyerRepository profileBuyerRepository;
  ProfileBuyerBloc({required this.profileBuyerRepository})
   : super(ProfileInitial()) {
    on<AddProfileBuyerEvent>(_addProfileBuyer);
    on<GetProfileBuyerEvent>(_getProfileBuyer);
    }

  
  Future<void> _addProfileBuyer(
    AddProfileBuyerEvent event,
    Emitter<ProfileBuyerState> emit,
  ) async {
    emit(ProfileBuyerLoading());
    final result = await profileBuyerRepository.addProfileBuyer(
      event.requestModel,
    );
    result.fold((error) => emit(ProfileBuyerAddError(message: error)), (
      profile,
    ) {
      emit(ProfileBuyerAdded(profile: profile));
    });
  }

  Future<void> _getProfileBuyer(
    GetProfileBuyerEvent event,
    Emitter<ProfileBuyerState> emit,
  ) async {
    emit(ProfileBuyerLoading());
    final result = await profileBuyerRepository.getProfileBuyer();
    result.fold(
      (error) => emit(ProfileBuyerError(message: error)),
      (profile) => emit(ProfileBuyerLoaded(profile: profile)),
    );
  }
}

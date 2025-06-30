import 'package:cleanconnect/data/model/response/admin_profile_response_model.dart';
import 'package:cleanconnect/data/repository/profile_admin_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'get_profile_event.dart';
part 'get_profile_state.dart';

class GetProfileBloc extends Bloc<GetProfileEvent, GetProfileState> {
  final PrifileAdminRepository adminRepository;
  GetProfileBloc(this.adminRepository) : super(GetProfileInitial()) {
    on<FetchProfileEvent>((event, emit) async {
      final result = await adminRepository.getProfile();
      result.fold(
        (l) => emit(GetProfileFailure(error: l)),
        (r) => emit(GetProfileSuccess(responseModel: r)),
      );
    });
  }
}

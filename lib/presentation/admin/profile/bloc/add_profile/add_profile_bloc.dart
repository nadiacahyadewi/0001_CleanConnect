import 'package:cleanconnect/data/model/request/admin/admin_profile_request.dart';
import 'package:cleanconnect/data/model/response/admin_profile_response_model.dart';
import 'package:cleanconnect/data/repository/profile_admin_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'add_profile_event.dart';
part 'add_profile_state.dart';

class AddProfileBloc extends Bloc<AddProfileEvent, AddProfileState> {
  final PrifileAdminRepository adminRepository;
  AddProfileBloc(this.adminRepository) : super(AddProfileInitial()) {
    on<AddProfileRequested>((event, emit) async {
      emit(AddProfileLoading());
      final result = await adminRepository.addProfile(event.requestModel);
      result.fold(
        (l) => emit(AddProfileFailure(error: l)),
        (r) => emit(AddProfileSuccess(responseModel: r)),
      );
    });
  }
}

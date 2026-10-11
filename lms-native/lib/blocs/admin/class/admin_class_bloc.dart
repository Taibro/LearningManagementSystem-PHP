import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/admin_repository.dart';
import 'admin_class_event.dart';
import 'admin_class_state.dart';

class AdminClassBloc extends Bloc<AdminClassEvent, AdminClassState> {
  final AdminRepository _repository;

  AdminClassBloc(this._repository) : super(AdminClassInitial()) {
    on<AdminClassFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
      AdminClassFetchRequested event, Emitter<AdminClassState> emit) async {
    emit(AdminClassLoading());
    try {
      final classes = await _repository.getAllClasses();
      emit(AdminClassLoadSuccess(classes));
    } catch (e) {
      emit(AdminClassLoadFailure(e.toString()));
    }
  }
}

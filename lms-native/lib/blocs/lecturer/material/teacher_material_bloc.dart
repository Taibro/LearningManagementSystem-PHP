import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/teacher_repository.dart';
import 'teacher_material_event.dart';
import 'teacher_material_state.dart';

class TeacherMaterialBloc extends Bloc<TeacherMaterialEvent, TeacherMaterialState> {
  final TeacherRepository repository;

  TeacherMaterialBloc({required this.repository}) : super(TeacherMaterialInitial()) {
    on<TeacherMaterialFetchRequested>(_onFetchMaterials);
    on<TeacherMaterialUploadRequested>(_onUploadMaterial);
  }

  Future<void> _onFetchMaterials(
    TeacherMaterialFetchRequested event,
    Emitter<TeacherMaterialState> emit,
  ) async {
    emit(TeacherMaterialLoading());
    try {
      final materials = await repository.getMaterials(event.teacherId);
      emit(TeacherMaterialLoadSuccess(materials));
    } catch (e) {
      emit(TeacherMaterialLoadFailure(e.toString()));
    }
  }

  Future<void> _onUploadMaterial(
    TeacherMaterialUploadRequested event,
    Emitter<TeacherMaterialState> emit,
  ) async {
    emit(TeacherMaterialUploadInProgress());
    try {
      await repository.uploadMaterial(event.request);
      emit(const TeacherMaterialUploadSuccess('Tải lên tài liệu thành công'));
      // Sau khi upload thành công, tự động fetch lại danh sách tài liệu
      add(TeacherMaterialFetchRequested(teacherId: event.teacherId));
    } catch (e) {
      emit(TeacherMaterialUploadFailure(e.toString()));
      // Vẫn cần phục hồi lại trạng thái danh sách nếu lỗi (hoặc có thể giữ nguyên cache)
      add(TeacherMaterialFetchRequested(teacherId: event.teacherId));
    }
  }
}

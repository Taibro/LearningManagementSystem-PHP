import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/school_admin_repository.dart';
import '../../../models/admin/semester.dart';
import 'admin_semester_event.dart';
import 'admin_semester_state.dart';

class AdminSemesterBloc extends Bloc<AdminSemesterEvent, AdminSemesterState> {
  final SchoolAdminRepository _repository;

  AdminSemesterBloc(this._repository) : super(AdminSemesterInitial()) {
    on<AdminSemesterFetchRequested>(_onFetchRequested);
    on<AdminSemesterCreated>(_onCreated);
    on<AdminSemesterEnded>(_onEnded);
  }

  Future<void> _onFetchRequested(AdminSemesterFetchRequested event, Emitter<AdminSemesterState> emit) async {
    emit(AdminSemesterLoading());
    try {
      final allSemesters = await _repository.getAllSemesters();
      
      // Lọc học kỳ hiện tại (isActive = true)
      Semester? current;
      List<Semester> past = [];
      for (var s in allSemesters) {
        if (s.isActive == true) {
          current = s;
        } else {
          past.add(s);
        }
      }
      // Sắp xếp lịch sử (thường theo ID giảm dần hoặc startDate giảm dần)
      past.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      
      emit(AdminSemesterLoadSuccess(currentSemester: current, pastSemesters: past));
    } catch (e) {
      emit(AdminSemesterLoadFailure(e.toString()));
    }
  }

  Future<void> _onCreated(AdminSemesterCreated event, Emitter<AdminSemesterState> emit) async {
    emit(AdminSemesterActionInProgress());
    try {
      // 1. Fetch AcademicYears to check if academicYearName exists
      final years = await _repository.getAllAcademicYears(event.schoolId);
      int? targetYearId;
      for (var y in years) {
        if (y.name == event.academicYearName) {
          targetYearId = y.id;
          break;
        }
      }

      // 2. If not found, create new AcademicYear
      if (targetYearId == null) {
        final newYear = await _repository.createAcademicYear({
          'schoolId': event.schoolId,
          'name': event.academicYearName,
          'startDate': event.startDate,
          'endDate': event.endDate,
          'isActive': true,
        });
        targetYearId = newYear.id;
      }

      // 3. Create Semester
      await _repository.createSemester({
        'academicYearId': targetYearId,
        'name': event.name,
        'startDate': event.startDate,
        'endDate': event.endDate,
        'isActive': true,
      });

      emit(const AdminSemesterActionSuccess('Tạo học kỳ mới thành công'));
      add(const AdminSemesterFetchRequested());
    } catch (e) {
      emit(AdminSemesterActionFailure(e.toString()));
    }
  }

  Future<void> _onEnded(AdminSemesterEnded event, Emitter<AdminSemesterState> emit) async {
    emit(AdminSemesterActionInProgress());
    try {
      if (event.semester.id == null) {
        emit(const AdminSemesterActionFailure('Học kỳ không hợp lệ'));
        return;
      }
      await _repository.updateSemester(event.semester.id!, {
        'academicYearId': event.semester.academicYearId,
        'name': event.semester.name,
        'startDate': event.semester.startDate,
        'endDate': event.semester.endDate,
        'isActive': false,
      });
      emit(const AdminSemesterActionSuccess('Đã kết thúc học kỳ'));
      add(const AdminSemesterFetchRequested());
    } catch (e) {
      emit(AdminSemesterActionFailure(e.toString()));
    }
  }
}

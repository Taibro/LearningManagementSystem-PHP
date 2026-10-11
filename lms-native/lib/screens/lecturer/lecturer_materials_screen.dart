import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/shared/lecturer_custom_app_bar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/lecturer/material/teacher_material_bloc.dart';
import '../../blocs/lecturer/material/teacher_material_event.dart';
import '../../blocs/lecturer/material/teacher_material_state.dart';
import '../../models/lecturer/teacher_material.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../repositories/teacher_repository.dart';
import '../../models/lecturer/active_class_schedule.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';

const Color _kPrimary = Color(0xFF6B4FA0);
const Color _kBg = Color(0xFFF8F9FA);

class LecturerMaterialsScreen extends StatefulWidget {
  const LecturerMaterialsScreen({super.key});

  @override
  State<LecturerMaterialsScreen> createState() =>
      _LecturerMaterialsScreenState();
}

class _LecturerMaterialsScreenState extends State<LecturerMaterialsScreen> {
  String? _selectedClassInfo;
  
  int _teacherId = 0;
  List<ActiveClassSchedule>? _activeClasses;
  
  // Controllers for upload dialog
  final _titleController = TextEditingController();
  ActiveClassSchedule? _uploadSelectedClass;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _teacherId = authState.user.id ?? 0;
    }
    context.read<TeacherMaterialBloc>().add(TeacherMaterialFetchRequested(teacherId: _teacherId));
    
    try {
      final repo = context.read<TeacherRepository>();
      final classes = await repo.getActiveClasses();
      if (mounted) {
        setState(() {
          _activeClasses = classes;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải danh sách lớp: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeacherMaterialBloc, TeacherMaterialState>(
      listener: (context, state) {
        if (state is TeacherMaterialUploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is TeacherMaterialUploadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải lên: ${state.message}'), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        backgroundColor: _kBg,
        body: Column(
          children: [
            const LecturerCustomAppBar(title: 'Tài liệu bài giảng'),
            Expanded(
              child: BlocBuilder<TeacherMaterialBloc, TeacherMaterialState>(
                builder: (context, state) {
                  if (state is TeacherMaterialLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TeacherMaterialLoadFailure) {
                    return Center(child: Text('Lỗi: ${state.message}', style: const TextStyle(color: Colors.red)));
                  } else if (state is TeacherMaterialLoadSuccess) {
                    final materials = state.materials;
                    final uniqueClasses = materials.map((m) => m.classInfo).whereType<String>().toSet().toList();
                    if (_selectedClassInfo != null && !uniqueClasses.contains(_selectedClassInfo)) {
                      _selectedClassInfo = null;
                    }
                    
                    return Column(
                      children: [
                        if (uniqueClasses.isNotEmpty) _buildClassFilter(uniqueClasses),
                        Expanded(child: _buildMaterialList(materials)),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showUploadDialog(context);
          },
          backgroundColor: _kPrimary,
          elevation: 4,
          highlightElevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 20),
          label: Text(
            'Tải lên',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ).animate().scale(curve: Curves.easeOutBack, delay: 500.ms),
      ),
    );
  }

  Widget _buildClassFilter(List<String> classes) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedClassInfo,
          hint: Text('Tất cả các lớp', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('Tất cả các lớp', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            ...classes.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                ))
          ],
          onChanged: (val) {
            setState(() {
              _selectedClassInfo = val;
            });
          },
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildMaterialList(List<TeacherMaterial> allMaterials) {
    final filtered = _selectedClassInfo == null
        ? allMaterials
        : allMaterials.where((m) => m.classInfo == _selectedClassInfo).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Chưa có tài liệu',
              style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.1),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final m = filtered[i];
        return _buildMaterialCard(m).animate().fadeIn(delay: (i * 100).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildMaterialCard(TeacherMaterial material) {
    IconData typeIcon;
    Color typeColor;
    final typeLower = (material.docType ?? '').toLowerCase();
    if (typeLower.contains('slide') || typeLower.contains('ppt')) {
      typeIcon = Icons.slideshow_rounded;
      typeColor = const Color(0xFFF59E0B);
    } else if (typeLower.contains('video') || typeLower.contains('mp4')) {
      typeIcon = Icons.play_circle_fill_rounded;
      typeColor = const Color(0xFFEF4444);
    } else {
      typeIcon = Icons.description_rounded;
      typeColor = const Color(0xFF3B82F6);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(typeIcon, color: typeColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.title ?? 'Không có tiêu đề',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${material.classInfo ?? '?'}  ·  ${material.fileSize ?? '?'}',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  material.uploadDate ?? '',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    if (_activeClasses == null || _activeClasses!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có lớp học nào khả dụng để tải lên.')),
      );
      return;
    }

    if (_uploadSelectedClass == null) {
      _uploadSelectedClass = _activeClasses!.first;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (innerContext, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.cloud_upload_rounded, color: _kPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tải lên tài liệu',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: const Color(0xFF1E293B)),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Tên tài liệu',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ActiveClassSchedule>(
                    decoration: InputDecoration(
                      labelText: 'Chọn lớp',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    value: _uploadSelectedClass,
                    isExpanded: true,
                    items: _activeClasses!.map((c) => DropdownMenuItem(
                      value: c, 
                      child: Text('${c.classCode} - ${c.courseName}', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        _uploadSelectedClass = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () async {
                        try {
                          final result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt', 'zip', 'rar', 'mp4'],
                          );
                          if (result != null && result.files.isNotEmpty) {
                            setDialogState(() {
                              _selectedFile = result.files.single;
                            });
                          }
                        } catch (e) {
                          if (innerContext.mounted) {
                            ScaffoldMessenger.of(innerContext).showSnackBar(
                              SnackBar(content: Text('Lỗi chọn tệp: $e')),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _selectedFile != null ? Icons.check_circle_rounded : Icons.upload_file, 
                              size: 32, 
                              color: _selectedFile != null ? Colors.green : Colors.grey.shade400
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFile != null ? _selectedFile!.name : 'Nhấn để chọn tệp', 
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: _selectedFile != null ? Colors.green.shade700 : Colors.grey.shade600,
                                fontWeight: _selectedFile != null ? FontWeight.w600 : FontWeight.w500,
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _titleController.clear();
                  _selectedFile = null;
                },
                child: Text('Hủy', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_titleController.text.trim().isEmpty || _uploadSelectedClass == null || _selectedFile == null) {
                     ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin và chọn tệp')));
                     return;
                  }
                  
                  final ext = _selectedFile!.extension?.toLowerCase() ?? '';
                  String docType = 'Tài liệu tham khảo';
                  if (['ppt', 'pptx'].contains(ext)) docType = 'Bài giảng (Slide)';
                  else if (['mp4'].contains(ext)) docType = 'Video bài giảng';
                  else if (['doc', 'docx', 'pdf'].contains(ext)) docType = 'Đề cương/Giáo trình';
                  
                  final formData = FormData.fromMap({
                    'classId': _uploadSelectedClass!.classId,
                    'teacherId': _teacherId,
                    'title': _titleController.text.trim(),
                    'docType': docType,
                    'uploadDate': DateTime.now().toIso8601String().split('T')[0],
                    'file': await MultipartFile.fromFile(_selectedFile!.path!, filename: _selectedFile!.name),
                  });
                  
                  if (!mounted) return;
                  
                  this.context.read<TeacherMaterialBloc>().add(TeacherMaterialUploadRequested(request: formData, teacherId: _teacherId));
                  
                  Navigator.pop(ctx);
                  _titleController.clear();
                  _selectedFile = null;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Tải lên', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ).animate().scale(curve: Curves.easeOutBack, duration: 300.ms);
        }
      ),
    );
  }
}

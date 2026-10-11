import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/shared/lecturer_custom_app_bar.dart';

class RequestMakeupScreen extends StatelessWidget {
  const RequestMakeupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      body: Column(
        children: [
          const LecturerCustomAppBar(title: 'Đề xuất dạy bù', icon: Icons.add_circle_outline_rounded),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF10B981).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_circle_rounded, color: Color(0xFF10B981), size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Thông tin đề xuất',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTextField('Lớp học phần', Icons.class_rounded),
                    const SizedBox(height: 16),
                    _buildTextField('Buổi học gốc đã nghỉ', Icons.event_busy_rounded),
                    const SizedBox(height: 16),
                    _buildTextField('Thời gian dạy bù dự kiến', Icons.access_time_rounded),
                    const SizedBox(height: 16),
                    _buildTextField('Phòng học dự kiến', Icons.room_rounded),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Đã gửi đề xuất!'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('GỬI ĐỀ XUẤT', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        prefixIcon: maxLines == 1 ? Icon(icon, color: const Color(0xFF10B981), size: 20) : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
      ),
    );
  }
}

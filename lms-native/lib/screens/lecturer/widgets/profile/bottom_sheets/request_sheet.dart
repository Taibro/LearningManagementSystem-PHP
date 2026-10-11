import 'package:flutter/material.dart';
import 'shared_sheet_helpers.dart';

class RequestSheet extends StatefulWidget {
  final String type;
  const RequestSheet({super.key, required this.type});

  @override
  State<RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<RequestSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.type) {
      case 'dayBu': return 'Đề xuất dạy bù';
      case 'dayThay': return 'Đề xuất dạy thay';
      default: return 'Đề xuất tạm ngừng lịch dạy';
    }
  }

  final List<Map<String, dynamic>> _history = [
    {'class': '14DHTH04', 'date': '15/03/2026', 'reason': 'Tham dự hội thảo khoa học', 'status': 'approved'},
    {'class': '14DHTH03', 'date': '22/02/2026', 'reason': 'Ốm, có giấy tờ y tế', 'status': 'pending'},
    {'class': '16DHTH10', 'date': '10/01/2026', 'reason': 'Việc gia đình', 'status': 'rejected'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          buildSheetHandle(),
          buildSheetHeader(_title, 'Quản lý đề xuất', const Color(0xFFE65100)),
          TabBar(
            controller: _tab,
            labelColor: const Color(0xFF6B4FA0),
            unselectedLabelColor: const Color(0xFF9E9E9E),
            indicatorColor: const Color(0xFF6B4FA0),
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: const [Tab(text: 'Tạo đề xuất'), Tab(text: 'Lịch sử')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _buildCreateForm(),
                _buildHistory(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormField('Lớp học phần', '010110195604 - 14DHTH04', isDropdown: true),
          const SizedBox(height: 12),
          _buildFormField('Ngày xin ngừng / bù', '25/04/2026', isDate: true),
          const SizedBox(height: 12),
          _buildFormField('Ca học', 'Sáng (Tiết 1–3)', isDropdown: true),
          const SizedBox(height: 12),
          if (widget.type == 'dayBu') ...[
            _buildFormField('Ngày dạy bù đề xuất', '28/04/2026', isDate: true),
            const SizedBox(height: 12),
            _buildFormField('Phòng học đề xuất', 'VD: A401'),
            const SizedBox(height: 12),
          ],
          const Text('Lý do',
              style: TextStyle(fontSize: 12, color: Color(0xFF616161))),
          const SizedBox(height: 4),
          Container(
            height: 80,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0D8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Align(
              alignment: Alignment.topLeft,
              child: Text('Nhập lý do đề xuất...',
                  style: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD))),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B4FA0), Color(0xFF8B6BBF)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B4FA0).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text('📤  Gửi đề xuất',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint,
      {bool isDropdown = false, bool isDate = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF616161))),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0D8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hint,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF424242))),
              if (isDropdown)
                const Icon(Icons.keyboard_arrow_down,
                    color: Color(0xFF6B4FA0), size: 18)
              else if (isDate)
                const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF6B4FA0), size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _history.map((item) {
        Color statusColor;
        String statusLabel;
        switch (item['status']) {
          case 'approved':
            statusColor = const Color(0xFF4CAF50);
            statusLabel = 'Đã duyệt';
            break;
          case 'rejected':
            statusColor = const Color(0xFFC62828);
            statusLabel = 'Từ chối';
            break;
          default:
            statusColor = const Color(0xFFE65100);
            statusLabel = 'Chờ duyệt';
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F7FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0D8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item['class']} · ${item['date']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Lý do: ${item['reason']}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF616161))),
            ],
          ),
        );
      }).toList(),
    );
  }
}

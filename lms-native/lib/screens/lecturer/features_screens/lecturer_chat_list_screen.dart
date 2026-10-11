import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/storage/secure_storage.dart';
import 'lecturer_realtime_chat_screen.dart';

class LecturerChatListScreen extends StatefulWidget {
  const LecturerChatListScreen({super.key});

  @override
  State<LecturerChatListScreen> createState() => _LecturerChatListScreenState();
}

class _LecturerChatListScreenState extends State<LecturerChatListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentChats = [];
  
  // Bulk selection state
  bool _isSelectionMode = false;
  final Set<String> _selectedEmails = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final token = await SecureStorage.getToken();
      final url = Uri.parse('http://localhost:8080/api/chat/recent');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _recentChats = data.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('Error loading chat list: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _togglePin(String email) async {
    try {
      final token = await SecureStorage.getToken();
      final url = Uri.parse('http://localhost:8080/api/chat/conversations/$email/pin');
      await http.post(url, headers: {'Authorization': 'Bearer $token'});
      _loadData();
    } catch (e) {
      debugPrint('Error pinning chat: $e');
    }
  }

  Future<void> _deleteChat(String email) async {
    try {
      final token = await SecureStorage.getToken();
      final url = Uri.parse('http://localhost:8080/api/chat/conversations/$email');
      await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      _loadData();
    } catch (e) {
      debugPrint('Error deleting chat: $e');
    }
  }

  Future<void> _bulkDelete() async {
    if (_selectedEmails.isEmpty) return;
    try {
      final token = await SecureStorage.getToken();
      final url = Uri.parse('http://localhost:8080/api/chat/conversations/bulk-delete');
      await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(_selectedEmails.toList()),
      );
      setState(() {
        _isSelectionMode = false;
        _selectedEmails.clear();
      });
      _loadData();
    } catch (e) {
      debugPrint('Error bulk deleting chats: $e');
    }
  }

  void _toggleSelection(String email) {
    setState(() {
      if (_selectedEmails.contains(email)) {
        _selectedEmails.remove(email);
        if (_selectedEmails.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedEmails.add(email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pinnedChats = _recentChats.where((chat) => chat['pinned'] == true).toList();
    final otherChats = _recentChats.where((chat) => chat['pinned'] != true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSelectionMode
            ? Text(
                'Đã chọn ${_selectedEmails.length}',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF1E293B),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              )
            : Text(
                'Trò chuyện',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF1E293B),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: _bulkDelete,
            )
          else
            IconButton(
              icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
              onPressed: () {},
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _recentChats.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        if (pinnedChats.isNotEmpty) ...[
                          _buildSectionHeader('Đã ghim', Icons.push_pin_rounded),
                          ...pinnedChats.map((chat) => _buildChatItem(chat, isPinned: true)),
                          const SizedBox(height: 16),
                        ],
                        if (otherChats.isNotEmpty) ...[
                          _buildSectionHeader('Gần đây', Icons.access_time_rounded),
                          ...otherChats.map((chat) => _buildChatItem(chat, isPinned: false)),
                        ],
                      ],
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Color(0xFF4F46E5)),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            'Hộp thư trống',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Chưa có cuộc trò chuyện nào gần đây',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ).animate().fadeIn().slideX(begin: -0.1),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat, {required bool isPinned}) {
    final String email = chat['email'];
    final String specificCode = chat['specificCode'] ?? '';
    final String fullName = chat['fullName'] ?? email;
    final String name = specificCode.isNotEmpty ? "$fullName - $specificCode" : fullName;
    final String lastMessage = chat['lastMessage'] ?? '';
    final String timestamp = chat['timestamp'] ?? '';
    final bool isRead = chat['read'] ?? true;
    final String initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
    final bool isSelected = _selectedEmails.contains(email);

    return Dismissible(
      key: Key(email),
      direction: _isSelectionMode ? DismissDirection.none : DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        color: isPinned ? const Color(0xFF94A3B8) : const Color(0xFFF59E0B),
        child: Icon(
          isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red,
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _togglePin(email);
          return false;
        } else if (direction == DismissDirection.endToStart) {
          _deleteChat(email);
          return true; // Return true to remove from list immediately
        }
        return false;
      },
      child: InkWell(
        onLongPress: () {
          setState(() {
            _isSelectionMode = true;
            _toggleSelection(email);
          });
        },
        onTap: () {
          if (_isSelectionMode) {
            _toggleSelection(email);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LecturerRealtimeChatScreen(
                  studentEmail: email,
                  studentName: fullName,
                ),
              ),
            ).then((_) => _loadData());
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: isSelected 
              ? const Color(0xFF4F46E5).withOpacity(0.1) 
              : (!isRead ? const Color(0xFFEEF2FF) : Colors.transparent),
          child: Row(
            children: [
              if (_isSelectionMode) ...[
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                ),
                const SizedBox(width: 16),
              ],
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4F46E5).withOpacity(0.8),
                          const Color(0xFF4F46E5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (!isRead)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(timestamp),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                            color: isRead ? const Color(0xFF94A3B8) : const Color(0xFF4F46E5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isRead ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                              fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPinned)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.push_pin_rounded, size: 16, color: Color(0xFFCBD5E1)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
    );
  }

  String _formatTime(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      return '${date.day}/${date.month}';
    } catch (e) {
      return '';
    }
  }
}

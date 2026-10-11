import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/shared/mesh_background.dart';
import 'widgets/home_header.dart';
import 'widgets/current_class_card.dart';
import 'widgets/function_section.dart';
import 'chatbot_screen.dart';
import '../../core/widgets/draggable_chatbot_button.dart';
import '../../core/widgets/mascot_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Nền sáng Slate cực sang
      body: Stack(
        children: [
          MeshBackground(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const HomeHeader(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        // Simulate a network request
                        await Future.delayed(const Duration(seconds: 1));
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      color: const Color(0xFF1565C0),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CurrentClassCard().animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                            const SizedBox(height: 28),
                            const FunctionSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableChatbotButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotScreen()),
              );
            },
            iconData: Icons.smart_toy_rounded,
            backgroundColor: const Color(0xFF1565C0),
          ),
          const MascotWidget(
            lottieAsset: 'assets/lottie/student.json',
            isMoving: true, // Học sinh di chuyển ngẫu nhiên
          ),
        ],
      ),
    );
  }
}

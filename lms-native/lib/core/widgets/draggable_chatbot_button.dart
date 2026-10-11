import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DraggableChatbotButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData iconData;
  final Color backgroundColor;
  final Offset initialOffset;

  const DraggableChatbotButton({
    super.key,
    required this.onPressed,
    required this.iconData,
    required this.backgroundColor,
    this.initialOffset = const Offset(0, 0),
  });

  @override
  State<DraggableChatbotButton> createState() => _DraggableChatbotButtonState();
}

class _DraggableChatbotButtonState extends State<DraggableChatbotButton> {
  Offset _offset = Offset.zero;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final size = MediaQuery.of(context).size;
      // Vị trí mặc định ở góc dưới bên phải, cách bottom nav bar một khoảng
      if (widget.initialOffset == Offset.zero) {
        _offset = Offset(size.width - 72, size.height - 150);
      } else {
        _offset = widget.initialOffset;
      }
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        onPanEnd: (details) {
          // Giới hạn trong màn hình khi thả ra
          final size = MediaQuery.of(context).size;
          double x = _offset.dx;
          double y = _offset.dy;

          if (x < 16) x = 16;
          if (x > size.width - 72) x = size.width - 72;
          if (y < 16) y = 16;
          // Có tính bottom nav bar (~100px)
          if (y > size.height - 100) y = size.height - 100;

          setState(() {
            _offset = Offset(x, y);
          });
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // Nền trắng để làm nổi bật Lottie màu tím
              border: Border.all(
                color: const Color(0xFF8B5CF6), // Đổi thành màu tím cao cấp đồng bộ
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.4), // Đổ bóng tím
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Lottie.asset(
                'assets/lottie/chatbot.json',
                width: 55,
                height: 55,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(widget.iconData, color: widget.backgroundColor, size: 32);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

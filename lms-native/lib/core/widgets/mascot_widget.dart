import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

class MascotWidget extends StatefulWidget {
  final String lottieAsset;
  final bool isMoving;
  final Offset? initialPosition;
  final VoidCallback? onTap;

  const MascotWidget({
    super.key,
    required this.lottieAsset,
    this.isMoving = false,
    this.initialPosition,
    this.onTap,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget> {
  late double topPos;
  late double leftPos;
  bool isFacingRight = true;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final size = MediaQuery.of(context).size;
      
      if (widget.initialPosition != null) {
        topPos = widget.initialPosition!.dy;
        leftPos = widget.initialPosition!.dx;
      } else {
        // Vị trí mặc định: góc dưới bên trái (trên bottom nav bar một chút)
        topPos = size.height - 180;
        leftPos = 16.0;
      }
      
      _isInit = true;

      if (widget.isMoving) {
        _moveRandomly();
      }
    }
  }

  void _moveRandomly() {
    if (!mounted || !widget.isMoving) return;
    
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      
      setState(() {
        final random = Random();
        final size = MediaQuery.of(context).size;
        
        // Đi qua đi lại bên dưới màn hình, hơi nhấp nhô nhẹ theo trục Y
        double baseTop = size.height - 180;
        double newTopPos = baseTop + (random.nextDouble() * 20 - 10); 
        double newLeftPos = random.nextDouble() * (size.width - 100);

        // LOGIC LẬT MẶT: Nếu điểm mới nằm bên phải điểm cũ -> Quay mặt sang phải
        if (newLeftPos > leftPos) {
          isFacingRight = true;
        } else {
          isFacingRight = false;
        }

        // Cập nhật vị trí mới
        topPos = newTopPos;
        leftPos = newLeftPos;
      });
      
      _moveRandomly(); // Lặp lại vòng tuần hoàn
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isMoving) {
      return Positioned(
        top: topPos,
        left: leftPos,
        child: IgnorePointer(
          child: Transform.scale(
            scaleX: isFacingRight ? 1 : -1,
            alignment: Alignment.center,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Lottie.asset(
                widget.lottieAsset,
                fit: BoxFit.contain,
                repeat: true,
                errorBuilder: (context, error, stackTrace) => const SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedPositioned(
      duration: const Duration(seconds: 3), // Thời gian chạy mượt mà
      curve: Curves.easeInOut,
      top: topPos,
      left: leftPos,
      child: IgnorePointer(
        child: Transform.scale(
          scaleX: isFacingRight ? 1 : -1,
          alignment: Alignment.center,
          child: SizedBox(
            width: 100,
            height: 100,
            child: Lottie.asset(
              widget.lottieAsset,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      ),
    );
  }
}

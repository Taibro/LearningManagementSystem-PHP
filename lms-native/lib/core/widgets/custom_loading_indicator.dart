import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double size;

  const CustomLoadingIndicator({super.key, this.size = 60.0});

  @override
  Widget build(BuildContext context) {
    return Lottie.network(
      'https://assets-v2.lottiefiles.com/a/5e08b0dd-f863-4b30-9898-2706d509ff9b/o4VygOMtb8.json',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

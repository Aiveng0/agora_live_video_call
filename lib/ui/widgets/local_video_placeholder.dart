import 'package:flutter/material.dart';

class LocalVideoPlaceholder extends StatelessWidget {
  const LocalVideoPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF444444),
      child: const Icon(
        Icons.videocam_off_outlined,
        color: Colors.white,
        size: 80,
      ),
    );
  }
}

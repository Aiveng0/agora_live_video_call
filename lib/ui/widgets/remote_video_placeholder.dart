import 'package:flutter/material.dart';

class RemoteVideoPlaceholder extends StatelessWidget {
  const RemoteVideoPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF444444),
      child: const Icon(
        Icons.account_circle_outlined,
        color: Colors.white,
        size: 80,
      ),
    );
  }
}

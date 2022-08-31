import 'package:flutter/material.dart';

class RowView1 extends StatelessWidget {
  const RowView1({
    Key? key,
    required this.views,
  }) : super(key: key);

  final List<Widget> views;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 40,
        left: 10,
        bottom: 100,
      ),
      child: Column(
        children: List.generate(
          views.length,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: views[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
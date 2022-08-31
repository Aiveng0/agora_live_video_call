import 'package:flutter/material.dart';

class RowView2 extends StatelessWidget {
  const RowView2({
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
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(
          views.length,
          (index) => SizedBox(
            width: (MediaQuery.of(context).size.width - 30) / 2,
            height: (MediaQuery.of(context).size.height - 100 - 40 - 30) / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: views[index],
            ),
          ),
        ),
      ),
    );
  }
}
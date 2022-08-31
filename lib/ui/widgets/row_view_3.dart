import 'package:flutter/material.dart';

class RowView3 extends StatelessWidget {
  const RowView3({
    Key? key,
    required this.views,
  }) : super(key: key);

  final List<Widget> views;

  @override
  Widget build(BuildContext context) {
    final List<Widget> newViews = views.take(5).toList();
    newViews.add(
      Container(
        width: double.infinity,
        color: const Color(0xFF444444),
        child: Center(
          child: Text(
            '+${views.length - 5}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(
        top: 40,
        left: 10,
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(
          newViews.length,
          (index) => SizedBox(
            width: (MediaQuery.of(context).size.width - 30) / 2,
            height: (MediaQuery.of(context).size.height - 100 - 40 - 30) / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: newViews[index],
            ),
          ),
        ),
      ),
    );
  }
}

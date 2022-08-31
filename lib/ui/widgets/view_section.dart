import 'package:agora_live_video_call/ui/widgets/row_view_1.dart';
import 'package:agora_live_video_call/ui/widgets/row_view_2.dart';
import 'package:agora_live_video_call/ui/widgets/row_view_3.dart';
import 'package:flutter/material.dart';

class ViewSection extends StatelessWidget {
  const ViewSection({
    Key? key,
    required this.views,
  }) : super(key: key);

  final List<Widget> views;

  Widget _getViewRow() {
    if (views.length > 3 && views.length <= 6) {
      return RowView2(
        views: views,
      );
    }

    if (views.length > 6) {
      return RowView3(
        views: views,
      );
    }

    return RowView1(
      views: views,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getViewRow();
  }
}

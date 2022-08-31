import 'package:flutter/material.dart';

class LogsPanel extends StatelessWidget {
  const LogsPanel({
    Key? key,
    required this.show,
    required this.logsList,
  }) : super(key: key);

  final bool show;
  final List<String> logsList;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: show,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: ListView.builder(
              reverse: true,
              itemCount: logsList.length,
              itemBuilder: (BuildContext context, int index) {
                if (logsList.isEmpty) {
                  return const Text('null, _infoStrings.isEmpty');
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(128),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            logsList[index],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

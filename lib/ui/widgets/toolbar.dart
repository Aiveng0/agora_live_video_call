import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({
    Key? key,
    required this.role,
    required this.isCameraEnabled,
    required this.isMicrophoneMuted,
    required this.onEndCallButtonPressed,
    required this.onMicButtonPressed,
    required this.onSwitchCameraButtonPressed,
    required this.onCameraButtonPressed,
  }) : super(key: key);

  final ClientRole role;
  final bool isCameraEnabled;
  final bool isMicrophoneMuted;
  final void Function()? onEndCallButtonPressed;
  final void Function()? onMicButtonPressed;
  final void Function()? onSwitchCameraButtonPressed;
  final void Function()? onCameraButtonPressed;

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  Widget _getToolbar() {
    if (widget.role == ClientRole.Audience) {
      return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: _CallEndButton(
          onEndCallButtonPressed: widget.onEndCallButtonPressed,
        ),
      );
    }

    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: widget.onMicButtonPressed,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: widget.isMicrophoneMuted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              widget.isMicrophoneMuted ? Icons.mic_off : Icons.mic,
              color: widget.isMicrophoneMuted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
          ),
          _CallEndButton(
            onEndCallButtonPressed: widget.onEndCallButtonPressed,
          ),
          RawMaterialButton(
            onPressed: widget.onSwitchCameraButtonPressed,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: const Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: widget.onCameraButtonPressed,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: widget.isCameraEnabled ? Colors.white : Colors.blueAccent,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              widget.isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              color: widget.isCameraEnabled ? Colors.blueAccent : Colors.white,
              size: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getToolbar();
  }
}

class _CallEndButton extends StatefulWidget {
  const _CallEndButton({
    Key? key,
    required this.onEndCallButtonPressed,
  }) : super(key: key);

  final void Function()? onEndCallButtonPressed;

  @override
  State<_CallEndButton> createState() => _CallEndButtonState();
}

class _CallEndButtonState extends State<_CallEndButton> {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: widget.onEndCallButtonPressed,
      shape: const CircleBorder(),
      elevation: 2.0,
      fillColor: Colors.redAccent,
      padding: const EdgeInsets.all(15.0),
      child: const Icon(
        Icons.call_end,
        color: Colors.white,
        size: 35.0,
      ),
    );
  }
}

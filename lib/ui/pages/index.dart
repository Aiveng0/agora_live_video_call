// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:agora_live_video_call/ui/pages/call.dart';
import 'package:agora_live_video_call/utils/settings.dart' as settings;
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexState();
}

class _IndexState extends State<IndexPage> {
  final _channelController = TextEditingController(text: 'flutterappchannel');
  final _tokenController = TextEditingController();
  bool _useNewToken = false;
  bool _validateError = false;
  ClientRole? _role = ClientRole.Broadcaster;

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  void _unfocus(BuildContext context) {
    final FocusScopeNode focusScope = FocusScope.of(context);
    if (focusScope.hasFocus) {
      focusScope.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora live video call'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => _unfocus(context),
        onLongPress: () => _unfocus(context),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: _channelController,
                  decoration: InputDecoration(
                    errorText: _validateError ? 'Channel name is required' : null,
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                      ),
                    ),
                    hintText: 'Channel name',
                    labelText: 'Channel name',
                  ),
                ),
                Visibility(
                  visible: _useNewToken,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TextField(
                        controller: _tokenController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                            ),
                          ),
                          hintText: 'RTC token',
                          labelText: 'RTC token',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: const Text('Use new RTC token'),
                  value: _useNewToken,
                  subtitle: const Text('Temp token for audio/video call'),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      _useNewToken = !_useNewToken;
                      _tokenController.clear();
                    });
                  },
                ),
                const SizedBox(height: 10),
                RadioListTile(
                  title: const Text('Broadcaster'),
                  subtitle: const Text(
                      'You can use your video camera and microphone. Other participants will be able to see and hear you.'),
                  onChanged: (ClientRole? value) {
                    setState(() {
                      _role = value;
                    });
                  },
                  value: ClientRole.Broadcaster,
                  groupValue: _role,
                ),
                const SizedBox(height: 5),
                RadioListTile(
                  title: const Text('Audience'),
                  subtitle: const Text('You can only watch. You cannot use your video camera or microphone'),
                  onChanged: (ClientRole? value) {
                    setState(() {
                      _role = value;
                    });
                  },
                  value: ClientRole.Audience,
                  groupValue: _role,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onJoin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Join'),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    const Text(
                      'Available channel name: ',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _channelController.text = 'flutterappchannel';
                        });
                      },
                      child: const Text(
                        'flutterappchannel',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    setState(() {
      _channelController.text.isEmpty ? _validateError = true : _validateError = false;
    });

    if (_useNewToken == true && _tokenController.text.isNotEmpty) {
      settings.token = _tokenController.text;
    }

    if (_channelController.text.isNotEmpty) {
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: _channelController.text,
            role: _role,
          ),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log(status.toString());
  }
}

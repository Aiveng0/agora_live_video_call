import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:agora_live_video_call/utils/settings.dart' as settings;

class CallPage extends StatefulWidget {
  const CallPage({
    Key? key,
    this.channelName,
    this.role,
  }) : super(key: key);

  final String? channelName; // flutterappchanel
  final ClientRole? role;

  @override
  State<CallPage> createState() => _CallPageState();
}

// class UserModel {
//   UserModel({
//     required this.uid,
//     this.showVideo = false,
//   });

//   int uid;
//   bool? showVideo;
// }

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  // final _usersModel = <UserModel>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool showVideo = false;
  bool viewPanel = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _users.clear();
    // _usersModel.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Future<void> initialize() async {
    if (settings.appId.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
      });
      return;
    }

    // _initAgoraRtcEngine
    _engine = await RtcEngine.create(settings.appId);
    await _engine.enableVideo();
    await _engine.muteLocalVideoStream(!showVideo);
    await _engine.enableLocalVideo(showVideo);
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);
    // _addAgoraEventHandlers
    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = const VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(settings.token, widget.channelName!, null, 0);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final String info = 'Error: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final String info = 'Join Channel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('Leave Channel');
          _users.clear();
          // _usersModel.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final String info = 'User Joined: uid = $uid';
          _infoStrings.add(info);
          _users.add(uid);
          // _usersModel.add(UserModel(uid: uid, showVideo: false));
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          final String info = 'User Offline: uid = $uid';
          _infoStrings.add(info);
          _users.remove(uid);
          // _usersModel.map((e) {
          //   if (e.uid == uid) {
          //     e.showVideo = false;
          //   }
          // });
        });
      },
      firstLocalVideoFrame: (width, height, elapsed) {
        setState(() {
          final String info = 'First Remote Video: ${width}x$height';
          _infoStrings.add(info);
        });
      },
      remoteVideoStateChanged: (uid, state, reason, elapsed) {
        if (state == VideoRemoteState.Stopped) {
          if (_users.contains(uid)) {
            _users.remove(uid);
            // _usersModel.map((e) {
            //   if (e.uid == uid) {
            //     e.showVideo = false;
            //   }
            // });
          }
        } else {
          if (!_users.contains(uid)) {
            _users.add(uid);
            // _usersModel.map((e) {
            //   if (e.uid == uid) {
            //     e.showVideo = true;
            //   }
            // });
          }
        }
        setState(() {
          final String info = 'remoteVideoStateChanged: uid= $uid, state = $state';
          _infoStrings.add(info);
        });
      },
    ));
  }

  /// Show all users videos in a row
  Widget _viewRows() {
    final List list = [];
    if (widget.role == ClientRole.Broadcaster && showVideo) {
      list.add(
        const rtc_local_view.SurfaceView(),
      );
    }
    for (var uid in _users) {
      list.add(rtc_remote_view.SurfaceView(
        uid: uid,
        channelId: widget.channelName!,
      ));
    }
    // for (var item in _usersModel) {
    //   if (item.showVideo!) {
    //     list.add(rtc_remote_view.SurfaceView(
    //       uid: item.uid,
    //       channelId: widget.channelName!,
    //     ));
    //   } else {
    //     list.add(
    //       Container(
    //         color: Colors.blueGrey,
    //       ),
    //     );
    //   }
    // }

    final views = list;

    if (views.length > 3) {
      return Padding(
        padding: const EdgeInsets.only(
          top: 10,
          left: 10,
        ),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(
            views.length,
            (index) => SizedBox(
              width: (MediaQuery.of(context).size.width - 30) / 2,
              height: (MediaQuery.of(context).size.height - 56) / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: views[index],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
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

  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) {
      return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: RawMaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          shape: const CircleBorder(),
          elevation: 2.0,
          fillColor: Colors.redAccent,
          padding: const EdgeInsets.all(15.0),
          child: const Icon(
            Icons.call_end,
            color: Colors.white,
            size: 35.0,
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () {
              setState(() {
                muted = !muted;
              });
              _engine.muteLocalAudioStream(muted);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              _engine.switchCamera();
            },
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
            onPressed: () async {
              setState(() {
                showVideo = !showVideo;
                _engine.muteLocalVideoStream(!showVideo);
                _engine.enableLocalVideo(showVideo);
              });
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: showVideo ? Colors.white : Colors.blueAccent,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              showVideo ? Icons.videocam : Icons.videocam_off,
              color: showVideo ? Colors.blueAccent : Colors.white,
              size: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Show logs
  Widget _panel() {
    return Visibility(
      visible: viewPanel,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: ListView.builder(
              reverse: true,
              itemCount: _infoStrings.length,
              itemBuilder: (BuildContext context, int index) {
                if (_infoStrings.isEmpty) {
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
                            _infoStrings[index],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora live Video Call'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                viewPanel = !viewPanel;
              });
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF202124),
      body: Center(
        child: Stack(children: [
          _viewRows(),
          _panel(),
          _toolbar(),
        ]),
      ),
    );
  }
}

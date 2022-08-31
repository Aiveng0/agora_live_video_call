import 'dart:async';
import 'dart:developer';

import 'package:agora_live_video_call/ui/widgets/local_video_placeholder.dart';
import 'package:agora_live_video_call/ui/widgets/remote_video_placeholder.dart';
import 'package:agora_live_video_call/ui/widgets/toolbar.dart';
import 'package:agora_live_video_call/ui/widgets/view_section.dart';
import 'package:agora_live_video_call/utils/settings.dart' as settings;
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:flutter/material.dart';

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

class _CallPageState extends State<CallPage> {
  final _allUsers = <int>[];
  final _usersWithVideo = <int>[];

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
    _allUsers.clear();
    _usersWithVideo.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Future<void> initialize() async {
    if (settings.appId.isEmpty) {
      return;
    }

    /// _initAgoraRtcEngine
    _engine = await RtcEngine.create(settings.appId);

    await _engine.enableVideo();
    await _engine.muteLocalVideoStream(!showVideo);
    await _engine.enableLocalVideo(showVideo);
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);

    /// _addAgoraEventHandlers
    _addAgoraEventHandlers();
    
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = const VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);

    /// Enables the reporting of users' volume indication.
    await _engine.enableAudioVolumeIndication(300, 5, true);
    await _engine.joinChannel(settings.token, widget.channelName!, null, 0);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        error: (code) {
          log('Error: $code');
        },

        /// Occurs when I join to channel
        joinChannelSuccess: (channel, uid, elapsed) {
          setState(() {});
        },

        /// Occurs when I leave from channel.
        leaveChannel: (stats) {
          setState(() {
            _usersWithVideo.clear();
            _allUsers.clear();
          });
        },

        /// Occurs when a remote user (COMMUNICATION)/ host (LIVE_BROADCASTING) joins the channel.
        userJoined: (uid, elapsed) {
          log('userJoined: $uid');
          setState(() {
            _allUsers.add(uid);
          });
        },

        /// Occurs when a remote user (COMMUNICATION)/ host (LIVE_BROADCASTING) leaves the channel.
        userOffline: (uid, reason) {
          log('userOffline: $uid');
          setState(() {
            _usersWithVideo.remove(uid);
            _allUsers.remove(uid);
          });
        },

        /// Occurs when the remote video state changes. This callback does not work properly when the number of users (in the voice/video call channel) or hosts (in the live streaming channel) in the channel exceeds 17.
        remoteVideoStateChanged: (uid, state, reason, elapsed) {
          log('remoteVideoStateChanged: uid => $uid, state => $state');
          setState(() {
            if (state == VideoRemoteState.Stopped) {
              if (_usersWithVideo.contains(uid)) {
                _usersWithVideo.remove(uid);
              }
            }
            if (state == VideoRemoteState.Starting) {
              if (!_usersWithVideo.contains(uid)) {
                _usersWithVideo.add(uid);
              }
            }
          });
        },

        /// Occurs when the remote audio state changes. This callback does not work properly when the number of users (in the voice/video call channel) or hosts (in the live streaming channel) in the channel exceeds 17.
        // remoteAudioStateChanged: (uid, state, reason, elapsed) {
        //   setState(() {
        //     if (state == AudioRemoteState.Starting) {
        //       if (_usersWithVideo.contains(uid)) {
        //         if (_usersWithVideo.contains(uid)) {
        //           log("_usersWithVideo => ${_usersWithVideo.toString()}");
        //           _usersWithVideo.remove(uid);
        //           _usersWithVideo.insert(0, uid);
        //           log("_usersWithVideo => ${_usersWithVideo.toString()}");
        //         }
        //       }
        //     }
        //   });
        // },

        /// Occurs when the most active speaker is detected. After a successful call of enableAudioVolumeIndication , the SDK continuously detects which remote user has the loudest volume.
        activeSpeaker: (uid) {
          setState(() {
            log("activeSpeaker => $uid");

            if (_usersWithVideo.contains(uid)) {
              log("_usersWithVideo => ${_usersWithVideo.toString()}");
              _usersWithVideo.remove(uid);
              _usersWithVideo.insert(0, uid);
              log("_usersWithVideo => ${_usersWithVideo.toString()}");
            }
          });
        },
      ),
    );
  }

  /// Return all users videos
  List<Widget> _getViewList() {
    final List<Widget> list = [];
    final int usersWithoutVideoCount = _allUsers.length - _usersWithVideo.length;

    /// 1: Add my local video to the list
    if (widget.role == ClientRole.Broadcaster) {
      if (showVideo == true) {
        list.add(const rtc_local_view.SurfaceView());
      } else {
        list.add(const LocalVideoPlaceholder());
      }
    }

    /// 2: Add users with video to the list
    for (var uid in _usersWithVideo) {
      list.add(rtc_remote_view.SurfaceView(
        uid: uid,
        channelId: widget.channelName!,
      ));
    }

    /// 3: Add users without video to the list
    for (var i = 0; i < usersWithoutVideoCount; i++) {
      list.add(const RemoteVideoPlaceholder());
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(true);
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF202124),
        body: Center(
          child: Stack(
            children: [
              /// Show all videos on the screen
              ViewSection(
                views: _getViewList(),
              ),
              Toolbar(
                role: widget.role!,
                isCameraEnabled: showVideo,
                isMicrophoneMuted: muted,
                onEndCallButtonPressed: () {
                  // _engine.destroy();
                  Navigator.pop(context);
                },
                onMicButtonPressed: () {
                  setState(() {
                    muted = !muted;
                  });
                  _engine.muteLocalAudioStream(muted);
                },
                onSwitchCameraButtonPressed: () {
                  _engine.switchCamera();
                },
                onCameraButtonPressed: () async {
                  setState(() {
                    showVideo = !showVideo;
                    _engine.muteLocalVideoStream(!showVideo);
                    _engine.enableLocalVideo(showVideo);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

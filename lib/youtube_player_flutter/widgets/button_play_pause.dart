import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

import '../controllers/youtube_controller_getx.dart';
import '../enums/player_state.dart';
import '../controllers/youtube_player_controller.dart';

/// A widget to display play/pause button.
class ButtonPlayPause extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;

  /// Defines placeholder widget to show when player is in buffering state.
  final Widget? bufferIndicator;

  /// Creates [ButtonPlayPause] widget.
  ButtonPlayPause({
    this.controller,
    this.bufferIndicator,
  });

  @override
  _ButtonPlayPauseState createState() => _ButtonPlayPauseState();
}

class _ButtonPlayPauseState extends State<ButtonPlayPause> {
  late YoutubePlayerController _controller;
  final YoutubeController youtubeController = Get.put(YoutubeController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = YoutubePlayerController.of(context);
    if (controller == null) {
      assert(
        widget.controller != null,
        '\n\nNo controller could be found in the provided context.\n\n'
        'Try passing the controller explicitly.',
      );
      _controller = widget.controller!;
    } else {
      _controller = controller;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  toggle(isPlaying) {
    if (isPlaying) {
      _controller.pause();
      youtubeController.togglePlaying(false);
    } else {
      _controller.play();
      youtubeController.togglePlaying(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _playerState = youtubeController.playerState;
    return GetBuilder<YoutubeController>(
      builder: (s) => Visibility(
        visible: s.playerState == PlayerState.cued || s.isControlsVisible,
        child: youtubeController.isReady ||
                _playerState == PlayerState.playing ||
                _playerState == PlayerState.paused
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50.0),
                  onTap: () {
                    toggle(s.isPlaying);
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(55),
                    height: ScreenUtil().setWidth(55),
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                    ),
                    child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, anim) => RotationTransition(
                              turns: Tween<double>(begin: 0.75, end: 1)
                                  .animate(anim),
                              child:
                                  FadeTransition(opacity: anim, child: child),
                            ),
                        child: !s.isPlaying
                            ? Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                key: ValueKey('icon1'),
                                size: ScreenUtil().setWidth(30),
                              )
                            : Icon(Icons.pause_rounded,
                                color: Colors.white,
                                key: ValueKey('icon2'),
                                size: ScreenUtil().setWidth(30))),
                  ),
                ),
              )
            : youtubeController.errorCode != 0
                ? const SizedBox()
                : Container(
                    // width: 60.0,
                    // height: 60.0,
                    // child: const CircularProgressIndicator(
                    //   valueColor: AlwaysStoppedAnimation(
                    //       Color.fromARGB(255, 219, 219, 219)),
                    // ),
                    ),
      ),
    );
  }
}

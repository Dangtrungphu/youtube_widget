import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/instance_manager.dart';
import '../controllers/youtube_controller_getx.dart';
import '../controllers/youtube_player_controller.dart';
import '../youtube_custom_widget.dart';
import 'button_close.dart';
import 'button_open_by_link.dart';
import 'duration_widgets.dart';
import 'button_play_pause.dart';
import 'progress_bar.dart';

class TouchShutter extends StatefulWidget {
  final YoutubePlayerController? controller;

  const TouchShutter({
    this.controller,
  });

  @override
  _TouchShutterState createState() => _TouchShutterState();
}

class _TouchShutterState extends State<TouchShutter> {
  Timer? _timer;

  late YoutubePlayerController _controller;
  final YoutubeController youtubeController = Get.put(YoutubeController());

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
    _timer?.cancel();
    super.dispose();
  }

  /**
   * Ẩn hiện các nút bấm
   */
  void _toggleControls() {
    youtubeController.toggleControl();
    if (youtubeController.isControlsVisible &&
        !youtubeController.isHide &&
        !youtubeController.isDragging) {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 3), () {
        if (youtubeController.isControlsVisible &&
            !youtubeController.isHide &&
            !youtubeController.isDragging) {
          youtubeController.toggleControl();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        width: ScreenUtil().setWidth(200),
        height: ScreenUtil().setWidth(200),
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              top: 0,
              right: 0,
              left: 0,
              duration: const Duration(milliseconds: 150),
              child: GetBuilder<YoutubeController>(
                builder: (s) => Visibility(
                  visible: s.isControlsVisible ? true : false,
                  child: Container(
                    height: ScreenUtil().setWidth(40),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(120, 0, 0, 0),
                          Color.fromARGB(80, 0, 0, 0),
                          Color.fromARGB(50, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        ButtonClose(
                          onTap: () {
                            ActionYoutubeController().closePopup();
                          },
                        ),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Expanded(
                          child: Text(
                            youtubeController.metaData.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setWidth(11),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        ButtonOpenByLink(url: youtubeController.urlId),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ButtonPlayPause(),
            ),
            GetBuilder<YoutubeController>(
              builder: (s) => AnimatedPositioned(
                bottom: 0,
                right: 0,
                left: 0,
                duration: const Duration(milliseconds: 150),
                child: Visibility(
                  visible: s.isReady && s.isControlsVisible ? true : false,
                  maintainState: true,
                  maintainAnimation: true,
                  child: Container(
                    height: s.isFullScreen
                        ? ScreenUtil().setWidth(65)
                        : ScreenUtil().setWidth(35),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(120, 0, 0, 0),
                          Color.fromARGB(80, 0, 0, 0),
                          Color.fromARGB(50, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: ScreenUtil().setWidth(14)),
                        const CurrentPosition(),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        s.metaData.duration.inMilliseconds != 0
                            ? ProgressBar(
                                isExpanded: true,
                                colors: const ProgressBarColors(
                                  backgroundColor:
                                      Color.fromARGB(197, 216, 216, 216),
                                  bufferedColor:
                                      Color.fromARGB(185, 245, 245, 245),
                                  handleColor: Colors.red,
                                  playedColor: Colors.red,
                                ),
                              )
                            : Container(),
                        const RemainingDuration(),
                        SizedBox(width: ScreenUtil().setWidth(14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

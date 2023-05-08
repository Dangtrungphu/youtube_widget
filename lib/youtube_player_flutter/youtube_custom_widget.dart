import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/instance_manager.dart';
import 'controllers/process_controller_getx.dart';
import 'controllers/youtube_controller_getx.dart';
import 'widgets/draggable_widget.dart';
import './player/youtube_player.dart';
import 'controllers/youtube_player_controller.dart';
import './widgets/draggable_widget.dart';
import 'widgets/youtube_player_builder.dart';

class YoutubeCustomWidget extends StatefulWidget {
  ///
  final double? bottomMargin;

  final double? topMargin;

  final Widget child;
  const YoutubeCustomWidget({
    Key? key,
    required this.child,
    this.bottomMargin,
    this.topMargin,
  }) : super(
          key: key,
        );

  @override
  State<YoutubeCustomWidget> createState() => _YoutubeCustomWidgetState();
}

class _YoutubeCustomWidgetState extends State<YoutubeCustomWidget>
    with TickerProviderStateMixin {
  late YoutubePlayerController _controller;
  final dragController = DragController();

  bool visible = false;
  bool isVideoVertical = false;
  final ActionYoutubeController ybController = ActionYoutubeController();

  /// Dùng Getx
  final YoutubeController youtubeController = Get.put(YoutubeController());

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController();
    ybController._addState(
      this,
    );
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  /**
   * Mở video
   */
  _openPopup(url, isVertical) async {
    if (isVertical != null) {
      youtubeController.toggleFullSrceen(value: isVertical);
    }
    youtubeController.toggleDrag(false, url: url);
    var check = await checkReady();
    _controller.load(YoutubePlayer.convertUrlToId(url) ?? '');
  }

  /**
   * Tắt video
   */
  _closePopup() async {
    _controller.pause();
    await Future.delayed(const Duration(milliseconds: 50));
    youtubeController.toggleDrag(true);
    youtubeController.toggleFullSrceen(value: false);
    Get.find<ProcessController>().refresh();
  }

  /**
   * Tải lại video khi chạy hết
   */
  _reload() {
    _controller
        .load(YoutubePlayer.convertUrlToId(youtubeController.urlId) ?? '');
  }

  // Đệ quy để kiểm tra trang web đã được mở lên chưa
  checkReady() async {
    if (youtubeController.isReady) {
      return true;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return checkReady();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          widget.child,
          YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                onEnded: (data) {
                  _reload();
                },
              ),
              builder: (context, player) {
                return GetBuilder<YoutubeController>(
                  builder: (s) => Visibility(
                    visible: !s.isHide,
                    maintainState: true,
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                        DraggableWidget(
                          horizontalSpace: ScreenUtil().setWidth(10),
                          bottomMargin:
                              widget.bottomMargin ?? ScreenUtil().setWidth(70),
                          topMargin:
                              widget.topMargin ?? ScreenUtil().setWidth(65),
                          child: SizedBox(
                            height: s.isFullScreen
                                ? MediaQuery.of(context).size.height - 20
                                : ScreenUtil().setHeight(173),
                            child: player,
                          ),
                          initialPosition: AnchoringPosition.topLeft,
                          dragController: dragController,
                          isVideoVertical: isVideoVertical,
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}

class ActionYoutubeController {
  _YoutubeCustomWidgetState? _widgetState;
  ActionYoutubeController._privateConstructor();
  static final _instance = ActionYoutubeController._privateConstructor();
  factory ActionYoutubeController() => _instance;

  void _addState(_YoutubeCustomWidgetState _widgetState) {
    this._widgetState = _widgetState;
  }

  /// Mở popup video
  void openPopup(url, {isVideoVertical = false}) {
    _widgetState?._openPopup(url, isVideoVertical);
  }

  /// Tắt popup video
  void closePopup() {
    _widgetState?._closePopup();
  }
}

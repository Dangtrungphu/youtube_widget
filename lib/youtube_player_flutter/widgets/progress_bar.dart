// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

import '../controllers/process_controller_getx.dart';
import '../controllers/youtube_controller_getx.dart';
import '../controllers/youtube_player_controller.dart';

/// Defines different colors for [ProgressBar].
class ProgressBarColors {
  /// Defines background color of the [ProgressBar].
  final Color? backgroundColor;

  /// Defines color for played portion of the [ProgressBar].
  final Color? playedColor;

  /// Defines color for buffered portion of the [ProgressBar].
  final Color? bufferedColor;

  /// Defines color for handle of the [ProgressBar].
  final Color? handleColor;

  /// Creates [ProgressBarColors].
  const ProgressBarColors({
    this.backgroundColor,
    this.playedColor,
    this.bufferedColor,
    this.handleColor,
  });

  ///
  ProgressBarColors copyWith({
    Color? backgroundColor,
    Color? playedColor,
    Color? bufferedColor,
    Color? handleColor,
  }) =>
      ProgressBarColors(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        handleColor: handleColor ?? this.handleColor,
        bufferedColor: bufferedColor ?? this.bufferedColor,
        playedColor: playedColor ?? this.playedColor,
      );
}

/// A widget to display video progress bar.
class ProgressBar extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;

  /// Defines colors for the progress bar.
  final ProgressBarColors? colors;

  /// Set true to get expanded [ProgressBar].
  ///
  /// Default is false.
  final bool isExpanded;

  /// Creates [ProgressBar] widget.
  ProgressBar({
    this.controller,
    this.colors,
    this.isExpanded = false,
  });

  @override
  _ProgressBarState createState() {
    return _ProgressBarState();
  }
}

class _ProgressBarState extends State<ProgressBar> {
  late YoutubePlayerController _controller;

  // Offset processController.touchPoint = Offset.zero;

  // double _playedValue = 0.0;
  // double _bufferedValue = 0.0;

  // bool _touchDown = false;
  // late Duration processController.position;
  final YoutubeController youtubeController = Get.put(YoutubeController());
  final ProcessController processController = Get.put(ProcessController());

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
    positionListener();
  }

  @override
  void dispose() {
    processController.removeListener(positionListener);
    super.dispose();
  }

  void positionListener() {
    var _totalDuration = youtubeController.metaData.duration.inMilliseconds;
    if (mounted && !_totalDuration.isNaN && _totalDuration != 0) {
      processController.updatePlayedValue(
          value:
              youtubeController.position.inMilliseconds / _totalDuration);
      processController.updateBufferedValue(
          value: youtubeController.buffered);
    }
  }

  void _setValue() {
    processController.updatePlayedValue(
        value: processController.touchPoint.dx / context.size!.width);
  }

  /**
   * Kiểm tra vị trí
   */
  void _checkTouchPoint() {
    if (processController.touchPoint.dx <= 0) {
      processController.touchPoint = Offset(0, processController.touchPoint.dy);
    }
    if (processController.touchPoint.dx >= context.size!.width) {
      processController.touchPoint =
          Offset(context.size!.width, processController.touchPoint.dy);
    }
  }

  /**
   * Đặt vị trí timeline khi kéo
   */
  void _seekToRelativePosition(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox;
    processController.touchPoint = box.globalToLocal(globalPosition);
    
    // Kiểm tra vị trí
    _checkTouchPoint();
    final relative = processController.touchPoint.dx / box.size.width;
    processController.position = youtubeController.metaData.duration * relative;
    _controller.seekTo(processController.position, allowSeekAhead: false);
  }

  /**
   * Kết thúc kéo timeline
   */
  void _dragEndActions() {
    youtubeController.toggleDragging(false);
    _controller.seekTo(processController.position, allowSeekAhead: true);
    processController.touchDown = false;
    _controller.play();
  }

  Widget _buildBar() {
    return GestureDetector(
      onHorizontalDragDown: (details) {
        youtubeController.toggleDragging(true);
        _seekToRelativePosition(details.globalPosition);
        _setValue();
        processController.touchDown = true;
      },
      onHorizontalDragUpdate: (details) {
        _seekToRelativePosition(details.globalPosition);
        _setValue;
      },
      onHorizontalDragEnd: (details) {
        _dragEndActions();
      },
      onHorizontalDragCancel: _dragEndActions,
      child: Container(
        color: Colors.transparent,
        constraints:
            BoxConstraints.expand(height: ScreenUtil().setWidth(7.0 * 2)),
        child: GetBuilder<ProcessController>(
          builder: (s) => CustomPaint(
            painter: _ProgressBarPainter(
              progressWidth: ScreenUtil().setWidth(1),
              handleRadius: ScreenUtil().setWidth(6),
              playedValue: s.playedValue,
              bufferedValue: s.bufferedValue,
              colors: widget.colors,
              touchDown: s.touchDown,
              themeData: Theme.of(context),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      widget.isExpanded ? Expanded(child: _buildBar()) : _buildBar();
}

class _ProgressBarPainter extends CustomPainter {
  final double progressWidth;
  final double handleRadius;
  final double playedValue;
  final double bufferedValue;
  final ProgressBarColors? colors;
  final bool touchDown;
  final ThemeData themeData;

  _ProgressBarPainter({
    required this.progressWidth,
    required this.handleRadius,
    required this.playedValue,
    required this.bufferedValue,
    this.colors,
    required this.touchDown,
    required this.themeData,
  });

  @override
  bool shouldRepaint(_ProgressBarPainter old) {
    return playedValue != old.playedValue ||
        bufferedValue != old.bufferedValue ||
        touchDown != old.touchDown;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.square
      ..strokeWidth = progressWidth;

    final centerY = size.height / 2.0;
    final barLength = size.width - handleRadius * 2.0;

    final startPoint = Offset(handleRadius, centerY);
    final endPoint = Offset(size.width - handleRadius, centerY);
    final progressPoint = Offset(
      barLength * playedValue + handleRadius,
      centerY,
    );
    final secondProgressPoint = Offset(
      barLength * bufferedValue + handleRadius,
      centerY,
    );

    final secondaryColor = themeData.colorScheme.secondary;

    paint.color = colors?.backgroundColor ?? secondaryColor.withOpacity(0.38);
    canvas.drawLine(startPoint, endPoint, paint);

    paint.color = colors?.bufferedColor ?? Colors.white70;
    canvas.drawLine(startPoint, secondProgressPoint, paint);

    paint.color = colors?.playedColor ?? secondaryColor;
    canvas.drawLine(startPoint, progressPoint, paint);

    final handlePaint = Paint()..isAntiAlias = true;

    handlePaint.color = Colors.transparent;
    canvas.drawCircle(progressPoint, centerY, handlePaint);

    final _handleColor = colors?.handleColor ?? secondaryColor;

    if (touchDown) {
      handlePaint.color = _handleColor.withOpacity(0.4);
      canvas.drawCircle(progressPoint, handleRadius * 3, handlePaint);
    }

    handlePaint.color = _handleColor;
    canvas.drawCircle(progressPoint, handleRadius, handlePaint);
  }
}

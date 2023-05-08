import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../controllers/youtube_controller_getx.dart';
import '../utils/duration_formatter.dart';
import '../controllers/youtube_player_controller.dart';

/// A widget which displays the current position of the video.
class CurrentPosition extends StatefulWidget {
  const CurrentPosition({Key? key}) : super(key: key);

  @override
  _CurrentPositionState createState() => _CurrentPositionState();
}

class _CurrentPositionState extends State<CurrentPosition> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<YoutubeController>(
      builder: (s) => Text(
        durationFormatter(
          s.position.inMilliseconds,
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: ScreenUtil().setWidth(11),
        ),
      ),
    );
  }
}

/// A widget which displays the remaining duration of the video.
class RemainingDuration extends StatefulWidget {
  const RemainingDuration({Key? key}) : super(key: key);


  @override
  _RemainingDurationState createState() => _RemainingDurationState();
}

class _RemainingDurationState extends State<RemainingDuration> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<YoutubeController>(
      builder: (s) => Text(
        "- ${durationFormatter(
          (s.metaData.duration.inMilliseconds) - (s.position.inMilliseconds),
        )}",
        style: TextStyle(
          color: Colors.white,
          fontSize: ScreenUtil().setWidth(11),
        ),
      ),
    );
  }
}

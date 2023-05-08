import 'package:flutter/widgets.dart';
import 'package:get/instance_manager.dart';

import 'youtube_controller_getx.dart';

class YoutubePlayerController {

  YoutubePlayerController._privateConstructor();
  static final _instance = YoutubePlayerController._privateConstructor();
  factory YoutubePlayerController() => _instance;

  /// Finds [YoutubePlayerController] in the provided context.
  static YoutubePlayerController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedYoutubePlayer>()
        ?.controller;
  }

  final YoutubeController youtubeController = Get.put(YoutubeController());

  _callMethod(String methodString) {
    if (youtubeController.isReady) {
      youtubeController.webViewController
          ?.evaluateJavascript(source: methodString);
    } else {
      print('The controller is not ready for method calls.');
    }
  }

  /// Plays the video.
  void play() => _callMethod('play()');

  /// Pauses the video.
  void pause() => _callMethod('pause()');

  /// Loads the video as per the [videoId] provided.
  void load(String videoId, {int startAt = 0, int? endAt}) {
    var loadParams = 'videoId:"$videoId",startSeconds:$startAt';
    if (endAt != null && endAt > startAt) {
      loadParams += ',endSeconds:$endAt';
    }
    _updateValues(videoId);
    if (youtubeController.errorCode == 1) {
      pause();
    } else {
      // youtubeController.toggleThumb(true);
      _callMethod('loadById({$loadParams})');
    }
  }

  void _updateValues(String id) {
    if (id.length != 11) {
      youtubeController.updateCodeError(1);
      return;
    }
    youtubeController.updateCodeError(0);

  }

  /// Mutes the player.
  void mute() => _callMethod('mute()');

  /// Un mutes the player.
  void unMute() => _callMethod('unMute()');

  /// Sets the volume of player.
  /// Max = 100 , Min = 0
  void setVolume(int volume) => volume >= 0 && volume <= 100
      ? _callMethod('setVolume($volume)')
      : throw Exception("Volume should be between 0 and 100");

  /// Seek to any position. Video auto plays after seeking.
  /// The optional allowSeekAhead parameter determines whether the player will make a new request to the server
  /// if the seconds parameter specifies a time outside of the currently buffered video data.
  /// Default allowSeekAhead = true
  void seekTo(Duration position, {bool allowSeekAhead = true}) {
    _callMethod('seekTo(${position.inMilliseconds / 1000},$allowSeekAhead)');
    play();
  }

  /// Sets the size in pixels of the player.
  void setSize(Size size) =>
      _callMethod('setSize(${size.width}, ${size.height})');

  /// Fits the video to screen width.
  void fitWidth(Size screenSize) {
    var adjustedHeight = 9 / 16 * screenSize.width;
    setSize(Size(screenSize.width, adjustedHeight));
    _callMethod(
      'setTopMargin("-${((adjustedHeight - screenSize.height) / 2 * 100).abs()}px")',
    );
  }

  /// Fits the video to screen height.
  void fitHeight(Size screenSize) {
    setSize(screenSize);
    _callMethod('setTopMargin("0px")');
  }

  /// Sets the playback speed for the video.
  void setPlaybackRate(double rate) => _callMethod('setPlaybackRate($rate)');
}

/// An inherited widget to provide [YoutubePlayerController] to it's descendants.
class InheritedYoutubePlayer extends InheritedWidget {
  /// Creates [InheritedYoutubePlayer]
  const InheritedYoutubePlayer({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  /// A [YoutubePlayerController] which controls the player.
  final YoutubePlayerController controller;

  @override
  bool updateShouldNotify(InheritedYoutubePlayer oldPlayer) =>
      oldPlayer.controller.hashCode != controller.hashCode;
}

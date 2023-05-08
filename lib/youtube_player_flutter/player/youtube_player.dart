import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

import '../controllers/youtube_controller_getx.dart';
import '../enums/thumbnail_quality.dart';
import '../utils/errors.dart';
import '../utils/youtube_meta_data.dart';
import '../controllers/youtube_player_controller.dart';
import '../widgets/touch_shutter.dart';
import 'raw_youtube_player.dart';

class YoutubePlayer extends StatefulWidget {
  final Key? key;
  final YoutubePlayerController controller;
  final double aspectRatio;
  final VoidCallback? onReady;
  final void Function(YoutubeMetaData metaData)? onEnded;

  const YoutubePlayer({
    this.key,
    required this.controller,
    this.aspectRatio = 16 / 9,
    this.onReady,
    this.onEnded,
  });

  /// Converts fully qualified YouTube Url to video id.
  ///
  /// If videoId is passed as url then no conversion is done.
  static String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
    if ((!url.contains("http") || !url.contains("https")) && (url.length == 11))
      return url;
    if (trimWhitespaces) url = url.trim();

    for (var exp in [
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
    ]) {
      Match? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

  /// Grabs YouTube video's thumbnail for provided video id.
  static String getThumbnail({
    required String videoId,
    String quality = ThumbnailQuality.medium,
    bool webp = true,
  }) =>
      webp
          ? 'https://i3.ytimg.com/vi_webp/$videoId/$quality.webp'
          : 'https://i3.ytimg.com/vi/$videoId/$quality.jpg';

  @override
  _YoutubePlayerState createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  late YoutubePlayerController controller;

  late double _aspectRatio;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    _aspectRatio = widget.aspectRatio;
  }

  @override
  void didUpdateWidget(YoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

  }

  void listener() async {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  final YoutubeController youtubeController = Get.put(YoutubeController());

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.black,
      child: InheritedYoutubePlayer(
        controller: controller,
        child: Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width,
          child: _buildPlayer(),
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          RawYoutubePlayer(
            key: widget.key,
            onEnded: (YoutubeMetaData metaData) {
              controller.load(youtubeController.urlId);
              widget.onEnded?.call(metaData);
            },
          ),
          GetBuilder<YoutubeController>(
            builder: (s) => AnimatedOpacity(
              opacity: s.isReady || !s.isShowThumbnail ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: s.urlId != '' ? _thumbnail : Container(),
            ),
          ),
          TouchShutter(controller: controller),
          if (youtubeController.errorCode != 0)
            Container(
              color: Colors.black87,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          errorString(
                            youtubeController.errorCode,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Error Code: ${youtubeController.errorCode}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget get _thumbnail => Image.network(
        YoutubePlayer.getThumbnail(
          videoId: youtubeController.metaData.videoId.isEmpty
              ? youtubeController.urlId
              : youtubeController.metaData.videoId,
        ),
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                color: Colors.black,
              ),
        errorBuilder: (context, _, __) => Image.network(
          YoutubePlayer.getThumbnail(
            videoId: youtubeController.metaData.videoId.isEmpty
                ? youtubeController.urlId
                : youtubeController.metaData.videoId,
            webp: false,
          ),
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : Container(
                  color: Colors.black,
                ),
          errorBuilder: (context, _, __) => Container(),
        ),
      );
}

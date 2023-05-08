import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import '../enums/player_state.dart';
import '../utils/youtube_meta_data.dart';
import '../utils/youtube_player_flags.dart';
import 'process_controller_getx.dart';

class YoutubeController extends GetxController {
  YoutubeController._privateConstructor();
  static final _instance = YoutubeController._privateConstructor();
  factory YoutubeController() => _instance;

  String urlId = '';
  late final InAppWebViewController? webViewController;

  bool isReady = false;
  bool isHide = true;
  bool isShowThumbnail = true;
  bool isControlsVisible = false;
  YoutubeMetaData metaData = const YoutubeMetaData();

  // Status video
  PlayerState? playerState = PlayerState.unknown;
  final YoutubePlayerFlags flags = const YoutubePlayerFlags();

  bool isPlaying = false;

  int errorCode = 0;
  Duration position = const Duration();
  double buffered = 0.0;
  bool isDragging = false;

  // Dragable
  bool isFullScreen = false;
  double top = 0.0;

  toggleFullSrceen({value}) {
    isFullScreen = value ?? !isFullScreen;
    update();
  }

  toggleDragging(value) {
    isDragging = value;
    update();
  }

  updateWebControler(value) {
    webViewController = value;
    update();
  }

  /**
   * true: sẵn sàng, false: chưa sẵn sàng
   */
  toggleReady(value) {
    isReady = value;
    update();
  }

  /**
   * true: mở, false: đóng
   */
  toggleThumb(value) {
    isShowThumbnail = value;
    update();
  }

  /**
   * true: đóng, false: mở
   */
  toggleDrag(value, {url = ''}) {
    // Cập nhật lại id video
    if (!value) {
      urlId = url;
    }
    isHide = value;
    update();
  }

  /**
   * true: đóng, false: mở
   */
  toggleControl({value}) {
    isControlsVisible = value ?? !isControlsVisible;
    update();
  }

  togglePlaying(value) {
    isPlaying = value;
    update();
  }

  updateMetaData(data) {
    metaData = YoutubeMetaData.fromRawData(data);
    update();
  }

  changeStatusVideo(PlayerState data) {
    playerState = data;
    update();
  }

  updateCodeError(code) {
    errorCode = code;
    update();
  }

  final ProcessController processController = Get.put(ProcessController());

  updateTimeLine({valuePosition, valueBuffer}) {
    position = valuePosition;
    buffered = valueBuffer;

    processController.playedValue =
        valuePosition.inMilliseconds / metaData.duration.inMilliseconds;
    processController.bufferedValue = valueBuffer;
    update();
  }

  // Update vị trí Drag
  updatePointDragable({value}) {
    top = value;
    update();
  }
}

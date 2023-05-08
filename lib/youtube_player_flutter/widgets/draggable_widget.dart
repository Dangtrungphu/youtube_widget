import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

import '../controllers/youtube_controller_getx.dart';

enum AnchoringPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

class DraggableWidget extends StatefulWidget {
  /// The widget that will be displayed as dragging widget
  final Widget child;

  /// The horizontal padding around the widget
  final double horizontalSpace;

  /// The vertical padding around the widget
  final double verticalSpace;

  /// Intial location of the widget, default to [AnchoringPosition.bottomRight]
  final AnchoringPosition initialPosition;

  /// The top bottom pargin to create the bottom boundary for the widget, for example if you have a [BottomNavigationBar],
  /// then you may need to set the bottom boundary so that the draggable button can't get on top of the [BottomNavigationBar]
  final double? bottomMargin;

  /// The top bottom pargin to create the top boundary for the widget, for example if you have a [AppBar],
  /// then you may need to set the bottom boundary so that the draggable button can't get on top of the [AppBar]
  final double? topMargin;

  /// Status bar's height, default to 24
  final double statusBarHeight;

  /// A drag controller to show/hide or move the widget around the screen
  final DragController? dragController;

  final bool isVideoVertical;

  DraggableWidget({
    Key? key,
    required this.child,
    this.horizontalSpace = 0,
    this.verticalSpace = 0,
    this.initialPosition = AnchoringPosition.bottomRight,
    this.bottomMargin = 0,
    this.topMargin = 0,
    this.statusBarHeight = 24,
    this.dragController,
    this.isVideoVertical = false,
  })  : assert(statusBarHeight >= 0),
        assert(horizontalSpace >= 0),
        assert(verticalSpace >= 0),
        assert(bottomMargin! >= 0),
        super(key: key);
  @override
  _DraggableWidgetState createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget>
    with SingleTickerProviderStateMixin {
  double top = 0;
  double boundary = 0;
  late AnimationController animationController;
  late Animation animation;
  double hardLeft = 0, hardTop = 0;
  bool offstage = true;
  AnchoringPosition? currentDocker;
  double widgetHeight = 18;
  double widgetWidth = 50;
  final key = GlobalKey();
  bool dragging = false;
  late AnchoringPosition currentlyDocked;
  bool isStillTouching = false;
  final YoutubeController youtubeController = Get.put(YoutubeController());

  @override
  void initState() {
    currentlyDocked = widget.initialPosition;
    hardTop = widget.topMargin!;
    animationController = AnimationController(
      value: 1,
      vsync: this,
      duration: const Duration(milliseconds: 10),
    )
      ..addListener(() {
        if (currentDocker != null) {
          animateWidget(currentDocker!);
        }
      })
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            hardTop = top;
          }
        },
      );

    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    widget.dragController?._addState(this);

    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
        final widgetSize = getWidgetSize(key);
        if (widgetSize != null) {
          setState(() {
            widgetHeight = widgetSize.height;
            widgetWidth = widgetSize.width;
          });
        }

        await Future.delayed(const Duration(
          milliseconds: 100,
        ));
        setState(() {
          offstage = false;
          boundary = MediaQuery.of(context).size.height - widget.bottomMargin!;

          top = widget.topMargin!;
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DraggableWidget oldWidget) {
    if (offstage == false && WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        final widgetSize = getWidgetSize(key);
        if (widgetSize != null) {
          setState(() {
            widgetHeight = widgetSize.height;
            widgetWidth = widgetSize.width;
          });
        }
        setState(() {
          boundary = MediaQuery.of(context).size.height - widget.bottomMargin!;
          // animateWidget(currentlyDocked);
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<YoutubeController>(
      builder: (s) => AnimatedPositioned(
        duration: const Duration(
          milliseconds: 150,
        ),
        curve: Curves.linearToEaseOut,
        top: s.isFullScreen
            ? 0
            : top > 0.0
                ? top
                : ScreenUtil().setWidth(65),
        left: 0,
        right: 0,
        child: Listener(
          onPointerUp: (v) {
            if (!isStillTouching ||
                youtubeController.isDragging ||
                youtubeController.isFullScreen) {
              return;
            }
            isStillTouching = false;

            final p = v.position;
            currentDocker = determineDocker(p.dx, p.dy);
            setState(() {
              dragging = false;
            });
            if (animationController.isAnimating) {
              animationController.stop();
            }
            animationController.reset();
            animationController.forward();
          },
          onPointerDown: (v) async {
            isStillTouching = false;
            await Future.delayed(const Duration(milliseconds: 0));
            isStillTouching = true;
          },
          onPointerMove: (v) async {
            if (!isStillTouching ||
                youtubeController.isDragging ||
                youtubeController.isFullScreen) {
              return;
            }
            if (animationController.isAnimating) {
              animationController.stop();
              animationController.reset();
            }

            setState(() {
              // dragging = true;
              if (v.position.dy < boundary &&
                  v.position.dy > widget.topMargin!) {
                top = max(v.position.dy - (widgetHeight) / 2, 0);
              }
              hardTop = top;
            });
          },
          child: Offstage(
            offstage: offstage,
            child: Container(
              key: key,
              padding: s.isFullScreen
                  ? null
                  : EdgeInsets.symmetric(
                      horizontal: widget.horizontalSpace,
                      vertical: widget.verticalSpace,
                    ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  AnchoringPosition determineDocker(double x, double y) {
    final double totalHeight = boundary;
    final double totalWidth = MediaQuery.of(context).size.width;
    if (y <= totalHeight / 2) {
      return AnchoringPosition.topLeft;
    } else if (y > totalHeight / 2) {
      return AnchoringPosition.bottomLeft;
    } else {
      return AnchoringPosition.topLeft;
    }
  }

  void animateWidget(AnchoringPosition docker) {
    final double totalHeight = boundary;
    final double totalWidth = MediaQuery.of(context).size.width;

    switch (docker) {
      case AnchoringPosition.topLeft:
        setState(() {
          if (animation.value == 0) {
            top = hardTop;
          } else {
            top = ((1 - animation.value) * hardTop +
                (widget.topMargin! * (animation.value)));
          }
          currentlyDocked = AnchoringPosition.topLeft;
        });
        break;
      case AnchoringPosition.bottomLeft:
        double remaingDistanceY = (totalHeight - widgetHeight - hardTop);
        setState(() {
          top = hardTop +
              (animation.value) * remaingDistanceY +
              (widget.statusBarHeight * animation.value);
          currentlyDocked = AnchoringPosition.bottomLeft;
        });
        break;
      default:
    }
  }

  Size? getWidgetSize(GlobalKey key) {
    final keyContext = key.currentContext;
    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      return box.size;
    } else {
      return null;
    }
  }
}

class DragController {
  _DraggableWidgetState? _widgetState;

  void _addState(_DraggableWidgetState _widgetState) {
    this._widgetState = _widgetState;
  }
}

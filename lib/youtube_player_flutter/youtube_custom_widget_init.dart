import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'youtube_custom_widget.dart';

final GlobalKey _key = GlobalKey();

typedef PopTestFunc = bool Function();

class YoutubeCustomWidgetsBindingObserver with WidgetsBindingObserver {
  YoutubeCustomWidgetsBindingObserver._() : _listener = <PopTestFunc>[] {
    //Compatible with flutter 3.x
    (WidgetsBinding.instance as dynamic).addObserver(this);
  }

  final List<PopTestFunc> _listener;

  static final YoutubeCustomWidgetsBindingObserver _singleton =
      YoutubeCustomWidgetsBindingObserver._();

  static YoutubeCustomWidgetsBindingObserver get singleton => _singleton;

  VoidCallback registerPopListener(PopTestFunc popTestFunc) {
    _listener.add(popTestFunc);
    return () {
      _listener.remove(popTestFunc);
    };
  }

  @override
  Future<bool> didPopRoute() async {
    if (_listener.isNotEmpty) {
      final clone = _listener.reversed.toList(growable: false);
      for (PopTestFunc popTest in clone) {
        if (popTest()) return true;
      }
    }
    return super.didPopRoute();
  }
}

// ignore: non_constant_identifier_names
TransitionBuilder YoutubeCustomInit() {
  //确保提前初始化,保证WidgetsBinding.instance.addObserver(this);的顺序

  //ignore: unnecessary_statements
  YoutubeCustomWidgetsBindingObserver._singleton;

  return (_, Widget? child) {
    ScreenUtil.init(_, designSize: const Size(360, 690));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return YoutubeCustomWidget(key: _key, child: child!);
  };
}

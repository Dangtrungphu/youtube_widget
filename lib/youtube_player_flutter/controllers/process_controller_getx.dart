import 'package:get/state_manager.dart';
import 'package:flutter/material.dart';

class ProcessController extends GetxController {
  ProcessController._privateConstructor();
  static final _instance = ProcessController._privateConstructor();
  factory ProcessController() => _instance;

  Offset touchPoint = Offset.zero;
  double playedValue = 0.0;
  double bufferedValue = 0.0;
  bool touchDown = false;
  late Duration position;


  reset() {
    touchPoint = Offset.zero;
    playedValue = 0.0;
    bufferedValue = 0.0;
    touchDown = false;
    position = const Duration();
    update();
  }

  updateTouchPoint({
    value,
  }) {
    touchPoint = value;
    update();
  }

  updatePlayedValue({
    value,
  }) {
    playedValue = value;
    update();
  }

  updateBufferedValue({
    value,
  }) {
    bufferedValue = value;
    update();
  }

  updateTouchDown({
    value,
  }) {
    touchDown = value;
    update();
  }

  updatePosition({
    value,
  }) {
    position = value;
    update();
  }
}

import 'dart:async';
import 'package:flutter/services.dart';

class NativeCallService {
  static const _channel = MethodChannel('com.example.todo_list/call_service');

  static Future<void> startCallService() async {
    await _channel.invokeMethod('startCallService');
  }

  static Future<void> stopCallService() async {
    await _channel.invokeMethod('stopCallService');
  }
}

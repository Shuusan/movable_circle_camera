import 'package:circle_camera_desktop/camera_views.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
      minimumSize: Size(300, 300),
      size: Size(300, 300),
      alwaysOnTop: true,
      titleBarStyle: TitleBarStyle.hidden,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: "Shuusan - CircleCamera");

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setResizable(true);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const GetMaterialApp(
    home: CameraView(),
  ));
}

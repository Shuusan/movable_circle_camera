import 'package:circle_camera_desktop/camera_views.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GetMaterialApp(
    home: CameraView(),
  ));
}

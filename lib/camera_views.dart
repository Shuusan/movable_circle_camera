import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'camera_controller.dart';

class CameraView extends GetView<CameraController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CameraController());
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.transparent.withOpacity(0.2),
        body: Obx(() => WindowBorder(
              color: Colors.transparent,
              width: 0,
              child: GestureDetector(
                onTap: () {
                  controller.switchCamera();
                },
                child: MoveWindow(
                  child: controller.isInitialized.value &&
                          controller.cameraId.value > 0 &&
                          controller.previewSize != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: Align(
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 500,
                              ),
                              child: AspectRatio(
                                aspectRatio: controller.previewSize!.width /
                                    controller.previewSize!.height,
                                child: controller.buildPreview(),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ),
            )),
      ),
    );
  }
}

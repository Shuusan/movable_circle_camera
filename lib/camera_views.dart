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
        floatingActionButton: Stack(
          alignment: Alignment.bottomRight,
          children: [
            FloatingActionButton(onPressed: () {}),
            Padding(
              padding: const EdgeInsets.only(bottom: 800.0),
              child: FloatingActionButton(onPressed: () {}),
            ),
          ],
        ),
        body: Obx(() => MoveWindow(
              child: ListView(
                children: <Widget>[
                  if (controller.cameras.isEmpty)
                    ElevatedButton(
                      onPressed: controller.fetchCameras,
                      child: const Text('Re-check available cameras'),
                    ),
                  if (controller.cameras.isNotEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: controller.isInitialized.value ? controller.disposeCurrentCamera : controller.initializeCamera,
                          child: Text(controller.isInitialized.value ? 'Dispose camera' : 'Create camera'),
                        ),
                        const SizedBox(height: 5),
                        if (controller.cameras.length > 1) ...<Widget>[
                          const SizedBox(width: 5),
                          ElevatedButton(
                            onPressed: controller.switchCamera,
                            child: const Text(
                              'Switch camera',
                            ),
                          ),
                        ]
                      ],
                    ),
                  const SizedBox(height: 5),
                  if (controller.isInitialized.value && controller.cameraId.value > 0 && controller.previewSize != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Align(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxHeight: 500,
                          ),
                          child: AspectRatio(
                            aspectRatio: controller.previewSize!.width / controller.previewSize!.height,
                            child: controller.buildPreview(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )),
      ),
    );
  }
}

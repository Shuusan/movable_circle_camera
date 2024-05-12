import 'package:camera_platform_interface/camera_platform_interface.dart';
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
        body: Obx(() => ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Text(controller.cameraInfo.value),
                ),
                if (controller.cameras.isEmpty)
                  ElevatedButton(
                    onPressed: controller.fetchCameras,
                    child: const Text('Re-check available cameras'),
                  ),
                if (controller.cameras.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton<ResolutionPreset>(
                        value: controller.mediaSettings.value.resolutionPreset,
                        onChanged: (ResolutionPreset? value) {
                          if (value != null) {
                            controller.onResolutionChange(value);
                          }
                        },
                        items: ResolutionPreset.values.map<DropdownMenuItem<ResolutionPreset>>((ResolutionPreset value) {
                          return DropdownMenuItem<ResolutionPreset>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: controller.isInitialized.value ? controller.disposeCurrentCamera : controller.initializeCamera,
                        child: Text(controller.isInitialized.value ? 'Dispose camera' : 'Create camera'),
                      ),
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
                if (controller.previewSize != null)
                  Center(
                    child: Text(
                      'Preview size: ${controller.previewSize!.width.toStringAsFixed(0)}x${controller.previewSize!.height.toStringAsFixed(0)}',
                    ),
                  ),
              ],
            )),
      ),
    );
  }
}

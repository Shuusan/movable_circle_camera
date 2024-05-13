import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CameraController extends GetxController {
  final cameraInfo = 'Unknown'.obs;
  final List<CameraDescription> cameras = <CameraDescription>[].obs;
  final cameraIndex = 0.obs;
  final cameraId = (-1).obs;
  final isInitialized = false.obs;
  Size? previewSize;

  final mediaSettings = const MediaSettings(
    resolutionPreset: ResolutionPreset.max,
    fps: 60,
    videoBitrate: 200000,
    audioBitrate: 32000,
    enableAudio: false,
  ).obs;

  StreamSubscription<CameraErrorEvent>? errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? cameraClosingStreamSubscription;

  @override
  void onInit() async {
    super.onInit();
    await fetchCameras();
    await initializeCamera();
  }

  @override
  void onClose() {
    disposeCurrentCamera();
    errorStreamSubscription?.cancel();
    cameraClosingStreamSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchCameras() async {
    String mCameraInfo;
    List<CameraDescription> mCameras = <CameraDescription>[];
    int mCameraIndex = 0;

    try {
      mCameras = await CameraPlatform.instance.availableCameras();
      if (mCameras.isEmpty) {
        mCameraInfo = 'No available cameras';
      } else {
        mCameraIndex = cameraIndex.value % mCameras.length;
        mCameraInfo =
            'Found camera: ${mCameras[mCameraIndex].name.split("<")[0]}';
      }
    } on PlatformException catch (e) {
      mCameraInfo = 'Failed to get cameras: ${e.code}: ${e.message}';
    }

    cameraIndex.value = mCameraIndex;
    cameras.assignAll(mCameras);
    cameraInfo.value = mCameraInfo;
  }

  Future<void> initializeCamera() async {
    assert(!isInitialized.value);

    if (cameras.isEmpty) {
      return;
    }

    int mCameraId = -1;
    try {
      final int mCameraIndex = cameraIndex.value % cameras.length;
      final CameraDescription mCamera = cameras[mCameraIndex];

      mCameraId = await CameraPlatform.instance.createCameraWithSettings(
        mCamera,
        mediaSettings.value,
      );

      unawaited(errorStreamSubscription?.cancel());
      errorStreamSubscription = CameraPlatform.instance
          .onCameraError(mCameraId)
          .listen(onCameraError);

      unawaited(cameraClosingStreamSubscription?.cancel());
      cameraClosingStreamSubscription = CameraPlatform.instance
          .onCameraClosing(mCameraId)
          .listen(onCameraClosing);

      final Future<CameraInitializedEvent> initialized =
          CameraPlatform.instance.onCameraInitialized(mCameraId).first;

      await CameraPlatform.instance.initializeCamera(
        mCameraId,
      );

      final CameraInitializedEvent event = await initialized;
      previewSize = Size(
        event.previewWidth,
        event.previewHeight,
      );

      isInitialized.value = true;
      cameraId.value = mCameraId;
      cameraIndex.value = mCameraIndex;
      cameraInfo.value = 'Capturing camera: ${mCamera.name.split("<")[0]}';
    } on CameraException catch (e) {
      if (mCameraId >= 0) {
        await CameraPlatform.instance.dispose(mCameraId);
      }

      isInitialized.value = false;
      cameraId.value = -1;
      cameraIndex.value = 0;
      previewSize = null;
      cameraInfo.value =
          'Failed to initialize camera: ${e.code}: ${e.description}';
    }
  }

  Future<void> disposeCurrentCamera() async {
    if (cameraId.value >= 0 && isInitialized.value) {
      try {
        await CameraPlatform.instance.dispose(cameraId.value);
        isInitialized.value = false;
        cameraId.value = -1;
        previewSize = null;
        cameraInfo.value = 'Camera disposed';
      } on CameraException catch (e) {
        cameraInfo.value =
            'Failed to dispose camera: ${e.code}: ${e.description}';
      }
    }
  }

  void onCameraError(CameraErrorEvent event) {
    Get.snackbar('Error', event.description);
    disposeCurrentCamera();
    fetchCameras();
  }

  void onCameraClosing(CameraClosingEvent event) {
    // Get.snackbar('Camera Closing', 'Camera is closing');
  }

  Future<void> switchCamera() async {
    if (cameras.isNotEmpty) {
      cameraIndex.value = (cameraIndex.value + 1) % cameras.length;
      if (isInitialized.value && cameraId.value >= 0) {
        await disposeCurrentCamera();
        await fetchCameras();
        if (cameras.isNotEmpty) {
          await initializeCamera();
        }
      } else {
        await fetchCameras();
      }
    }
  }

  Future<void> onResolutionChange(ResolutionPreset newValue) async {
    mediaSettings.value = MediaSettings(
      resolutionPreset: newValue,
      fps: mediaSettings.value.fps,
      videoBitrate: mediaSettings.value.videoBitrate,
      audioBitrate: mediaSettings.value.audioBitrate,
      enableAudio: mediaSettings.value.enableAudio,
    );
    if (isInitialized.value && cameraId.value >= 0) {
      await disposeCurrentCamera();
      await initializeCamera();
    }
  }

  Widget buildPreview() {
    return CameraPlatform.instance.buildPreview(cameraId.value);
  }
}

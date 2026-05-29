

import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:mask_detector/mask_detector.dart';
import 'package:mask_detector/models/mask_detection_result.dart';
import 'package:sample_liveness_app/models/camera_stream_payload.dart';
import 'package:sample_liveness_app/models/model_type.dart';
import 'package:sample_liveness_app/widgets/camera_view.dart';
import 'package:sample_liveness_app/widgets/face_detector_painter.dart';
import 'package:sample_liveness_app/widgets/result_view.dart';



class MaskDetectionPage extends StatefulWidget {
  const MaskDetectionPage({super.key});

  @override
  State<MaskDetectionPage> createState() => _MaskDetectionPageState();
}

class _MaskDetectionPageState extends State<MaskDetectionPage> {

  MaskDetectionResult? _maskResult;
  Size? _screenSize;
  late FaceDetector _faceDetector;
  bool isNoFaceDetected = true;
  bool _maskDetectorInitialized = false;
  CustomPaint? _customPaint;
  bool _isWidgetDestroyed = false;
  Map<ModelType,int?> _dims = {};



  final GlobalKey<CameraViewState> _cameraViewKey = GlobalKey();

  void _handleDetectMask(CameraStreamPayload payload) async {
    
    if(_isWidgetDestroyed) return;
    
    // 
    final startAt = DateTime.now();
    try {

      _dims = {};

      final faces = await _faceDetector.processImage(payload.inputImage);
      if(faces.isEmpty) {
        isNoFaceDetected = true;
        _customPaint = null;
        throw Exception("No face detected");
      }

      _dims[ModelType.googleMLKit] = DateTime.now().difference(startAt).inMilliseconds;


      isNoFaceDetected = false;

      final bx = faces[0].boundingBox;

      final faceContour = Rect.fromLTRB(bx.left, bx.top, bx.right,bx.bottom);

      final painter = FaceDetectorPainter(
        faces,
        Size(payload.cameraImage.width.toDouble(), payload.cameraImage.height.toDouble()),
        payload.inputImage.metadata!.rotation,
        CameraLensDirection.front
      );
      _customPaint = CustomPaint(painter: painter);

      _maskResult = await MaskDetector.detect(
        payload.yuvBytes,
        imageWidth: payload.imageWidth.toDouble(),
        imageHeight: payload.imageHeight.toDouble(),
        faceCountour: faceContour,
        rotation: payload.rotation,
        bytesPerRow: payload.bytesPerRow
      );
      final total = DateTime.now().difference(startAt).inMilliseconds;
      _dims[ModelType.maskDetector] = total - (_dims[ModelType.googleMLKit] ?? 0);
      print("data : $_maskResult");
    }
    catch (e){
      _maskResult = null;
      _dims = {};
      log("Error while detect mask : $e");
    } finally {
      log("========> Duration : ${DateTime.now().difference(startAt).inMilliseconds} ms");
      if(mounted) setState(() {});
    }
  }

  void _initDetection() async {
    
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.3
      ),
    );

    final result = await MaskDetector.initialize();
    _maskDetectorInitialized = result['status'] ?? false;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initDetection();
  }

  @override
  void dispose() {
    _isWidgetDestroyed = true;
    super.dispose();
    MaskDetector.destroy();
    _faceDetector.close();
  }


  @override
  Widget build(BuildContext context) {

    if(!_maskDetectorInitialized) {
      return Scaffold(
        body: Center(
          child: Text("Failed to initialize mask detector!."),
        ),
      );
    }

    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Mask Detection"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Mask Detection",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2
                      ),
                    ),
                    const SizedBox(height: 50),
                    Center(
                      child: SizedBox(
                        width: _screenSize!.width * .9,
                        height: _screenSize!.width * .9,
                        child: CameraView(
                          key: _cameraViewKey,
                          onImage: _handleDetectMask,
                          customPaint: _customPaint,
                          cameraStreamProcessDelay: const Duration(milliseconds: 200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ResultView(
                  fields: {
                    "Result : " : _maskResult == null ? "N/A" : _maskResult!.hasMask ? "Mask" : "No Mask",
                    "Score :" : _maskResult == null ? "N/A" :  _maskResult!.confidenceScore,
                  },
                  dims: _dims,
                  w: _screenSize!.width,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:face_anti_spoofing_detector/face_anti_spoofing_detector.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:sample_liveness_app/models/camera_stream_payload.dart';
import 'package:sample_liveness_app/models/model_type.dart';
import 'package:sample_liveness_app/widgets/camera_view.dart';
import 'package:sample_liveness_app/widgets/face_detector_painter.dart';
import 'package:sample_liveness_app/widgets/result_view.dart';

class FaceAntiSpoofingPage extends StatefulWidget {
  const FaceAntiSpoofingPage({super.key});

  @override
  State<FaceAntiSpoofingPage> createState() => _FaceAntiSpoofingPageState();
}

class _FaceAntiSpoofingPageState extends State<FaceAntiSpoofingPage> {
  String? message = "Real";
  Size? _screenSize;
  late FaceDetector _faceDetector;
  double? _confidenceScore;
  bool isNoFaceDetected = false;
  CustomPaint? _customPaint;
  final _confidenceThreshold = .95;
  bool _isWidgetDestroyed = false;
  bool _modelInitialized = false;
  Map<ModelType,int?> _dims = {};

  final GlobalKey<CameraViewState> _cameraViewKey = GlobalKey();

  void _handleDetectLiveness(CameraStreamPayload payload) async {
    
    if(_isWidgetDestroyed) return;

    try {

      _dims = {};

      final startAt = DateTime.now();

      final faces = await _faceDetector.processImage(payload.inputImage);

      _dims[ModelType.googleMLKit] = DateTime.now().difference(startAt).inMilliseconds;


      if (faces.isEmpty) throw Exception("No Face detected!.");
      
      final box = faces[0].boundingBox;
      final faceContour = Rect.fromLTRB(box.left, box.top, box.right, box.bottom);
      
      // Create painter with proper coordinate transformation
      final painter = FaceDetectorPainter(
        faces,
        Size(payload.cameraImage.width.toDouble(), payload.cameraImage.height.toDouble()),
        payload.inputImage.metadata!.rotation,
        CameraLensDirection.front
      );
      _customPaint = CustomPaint(painter: painter);
      
      _confidenceScore = await FaceAntiSpoofingDetector.detect(
        yuvBytes: payload.yuvBytes,
        previewWidth: payload.imageWidth,
        previewHeight: payload.imageHeight,
        faceContour: faceContour,
        orientation: 7,
      );
      final total = DateTime.now().difference(startAt).inMilliseconds;
      _dims[ModelType.faceAntiSpoofingDetector] = total - (_dims[ModelType.googleMLKit] ?? 0);

    } catch (e) {
      _confidenceScore = null;
      _customPaint = null;
      _dims = {};
      log(e.toString());
    } finally {
      if(mounted) setState(() {});
    }
  }

  void _initDetection() async {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableContours: false,
        minFaceSize: 0.3,
      ),
    );
    await FaceAntiSpoofingDetector.initialize();
    _modelInitialized = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _initDetection();
  }

  @override
  void dispose() {
    _isWidgetDestroyed = true;
    FaceAntiSpoofingDetector.destroy();
    _faceDetector.close();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    if(!_modelInitialized) {
      return Text("Model not initialized!.");
    }

    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Liveness Detection Exploration"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(                          // ← replaces Expanded
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Face Anti Spoofing",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Center(
                      child: SizedBox(
                        width: _screenSize!.width * .9,
                        height: _screenSize!.width * .9,
                        child: CameraView(
                          key: _cameraViewKey,
                          onImage: _handleDetectLiveness,
                          customPaint: _customPaint,
                          cameraStreamProcessDelay: const Duration(milliseconds: 100),
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
                    "Result : " : _confidenceScore == null ? 'N/A' : _confidenceScore! > _confidenceThreshold ? "Real" : "Fake",
                    "Score : " : _confidenceScore?.toStringAsFixed(4) ?? 'N/A',
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
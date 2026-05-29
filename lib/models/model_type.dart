

enum ModelType {
  googleMLKit,
  maskDetector,
  faceAntiSpoofingDetector;

  String get label => switch (this) {
    ModelType.googleMLKit => "Google ML Kit",
    ModelType.maskDetector => "Mask Detector",
    ModelType.faceAntiSpoofingDetector => "Face Anti Spoofing Detector",
  };
}
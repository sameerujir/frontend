import 'package:image_picker/image_picker.dart';

class PredictionResult {
  final String label;
  final double confidence;
  final String plantType;
  final String diseaseName;
  final String description;
  final String treatment;
  final String severity;
  final String timestamp;
  final XFile? imageFile;

  PredictionResult({
    required this.label,
    required this.confidence,
    required this.plantType,
    required this.diseaseName,
    required this.description,
    required this.treatment,
    required this.severity,
    required this.timestamp,
    this.imageFile,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json, XFile? image) {
    return PredictionResult(
      label: json['label'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      plantType: json['plant_type'] ?? 'Unknown',
      diseaseName: json['disease_name'] ?? 'Unknown',
      description: json['description'] ?? '',
      treatment: json['treatment'] ?? '',
      severity: json['severity'] ?? 'Unknown',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      imageFile: image,
    );
  }
  
  bool get isHealthy => label.toLowerCase().contains('healthy') || diseaseName.toLowerCase().contains('healthy');
}
class HistoryItem {
  final String predictionId;
  final String label;
  final double confidence;
  final String plantType;
  final String diseaseName;
  final String timestamp;
  final String? imageUrl; // Added support for network images

  HistoryItem({
    required this.predictionId,
    required this.label,
    required this.confidence,
    required this.plantType,
    required this.diseaseName,
    required this.timestamp,
    this.imageUrl,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      predictionId: json['prediction_id'] ?? '',
      label: json['label'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      plantType: json['plant_type'] ?? 'Unknown Plant',
      diseaseName: json['disease_name'] ?? 'Unknown',
      timestamp: json['timestamp'] ?? '',
      imageUrl: json['image_url'], // Ensure backend sends this
    );
  }

  bool get isHealthy => diseaseName.toLowerCase().contains('healthy');
}
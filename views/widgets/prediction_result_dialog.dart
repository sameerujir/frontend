import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/prediction_result.dart';
import '../../theme/app_theme.dart';

class PredictionResultDialog extends StatelessWidget {
  final PredictionResult prediction;
  const PredictionResultDialog({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: prediction.isHealthy ? AppTheme.emeraldLight : Colors.orange[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      prediction.isHealthy ? Icons.check : Icons.warning_amber,
                      color: prediction.isHealthy ? AppTheme.emeraldPrimary : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Diagnosis", style: TextStyle(fontSize: 12, color: Colors.grey[500], letterSpacing: 1)),
                        Text(prediction.diseaseName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.emeraldDark)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (prediction.imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: _buildImage(prediction.imageFile!),
                  ),
                ),
              const SizedBox(height: 24),
              Text("RECOMMENDED CARE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[400])),
              const SizedBox(height: 8),
              Text(
                prediction.treatment,
                style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.emeraldDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Understood"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImage(XFile file) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) return Image.memory(snapshot.data!, fit: BoxFit.cover);
        return Container(color: Colors.grey[200]);
      },
    );
  }
}
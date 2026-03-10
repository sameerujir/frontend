import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:plant_app/views/widgets/prediction_result_dialog.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _scaleAnim;
  final TextEditingController _symptomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  Future<void> _handleScan(BuildContext context, ImageSource source) async {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    final result = await viewModel.scanPlant(source, userNote: _symptomController.text);

    if (result != null && mounted) {
      await showDialog(
        context: context,
        builder: (_) => PredictionResultDialog(prediction: result),
      );
      viewModel.clearLastPrediction();
      _symptomController.clear();
    } else if (viewModel.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.error!), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeVM = Provider.of<ThemeViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    
    // UI Variables
    final String displayName = authVM.username?.isNotEmpty == true ? authVM.username! : "Gardener";
    final toggleText = themeVM.isDarkMode ? "Light Mode" : "Dark Mode";
    final toggleIcon = themeVM.isDarkMode ? Icons.light_mode : Icons.dark_mode;
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          
                          // --- HEADER ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Hi $displayName,", style: Theme.of(context).textTheme.bodyLarge),
                                  Text("Your Garden", style: Theme.of(context).textTheme.headlineMedium),
                                ],
                              ),
                              // DYNAMIC THEME BUTTON
                              TextButton.icon(
                                onPressed: () => themeVM.toggleTheme(),
                                icon: Icon(toggleIcon, size: 20),
                                label: Text(toggleText),
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  backgroundColor: Theme.of(context).cardTheme.color,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              )
                            ],
                          ),
                          
                          const SizedBox(height: 40),

                          // --- SCANNER ---
                          Center(
                            child: _buildBreathingScanner(
                              context, 
                              () => _handleScan(context, kIsWeb ? ImageSource.gallery : ImageSource.camera)
                            )
                          ),
                          
                          const SizedBox(height: 32),

                          // --- ACTION BUTTONS ---
                          if (kIsWeb)
                             _buildActionButton(context, icon: Icons.cloud_upload_outlined, label: "Upload Image", onTap: () => _handleScan(context, ImageSource.gallery))
                          else
                            Row(
                              children: [
                                Expanded(child: _buildActionButton(context, icon: Icons.camera_alt_outlined, label: "Camera", onTap: () => _handleScan(context, ImageSource.camera))),
                                const SizedBox(width: 16),
                                Expanded(child: _buildActionButton(context, icon: Icons.photo_library_outlined, label: "Gallery", isOutlined: true, onTap: () => _handleScan(context, ImageSource.gallery))),
                              ],
                            ),

                          const SizedBox(height: 32),

                          // --- SYMPTOMS INPUT ---
                          const Text("Describe Symptoms", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 8),
                          _buildSymptomInput(context),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),

                if (viewModel.isLoading)
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreathingScanner(BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Theme.of(context).primaryColor.withOpacity(0.1), Theme.of(context).primaryColor.withOpacity(0.0)],
                ),
              ),
              child: Center(
                child: Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(kIsWeb ? Icons.cloud_upload : Icons.qr_code_scanner, size: 48, color: Theme.of(context).primaryColor),
                      const SizedBox(height: 8),
                      Text(kIsWeb ? "Click to Upload" : "Tap to Scan", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSymptomInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        controller: _symptomController,
        maxLines: 2,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: "e.g., Yellow spots on leaves...",
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, bool isOutlined = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final onSurface = Theme.of(context).textTheme.bodyLarge?.color;
    
    return Material(
      color: isOutlined ? Colors.transparent : primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isOutlined ? Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isOutlined ? onSurface : Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isOutlined ? onSurface : Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
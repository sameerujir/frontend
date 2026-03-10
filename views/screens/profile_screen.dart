import 'package:flutter/material.dart';
import 'package:plant_app/viewmodels/theme_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'auth_gate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileViewModel>(context, listen: false).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.emeraldLight,
                          child: Text(viewModel.username.isNotEmpty ? viewModel.username[0].toUpperCase() : 'U', style: TextStyle(fontSize: 40, color: isDark ? AppTheme.darkPrimary : AppTheme.emeraldPrimary, fontWeight: FontWeight.w300)),
                        ),
                        const SizedBox(height: 12),
                        Text(viewModel.username, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (viewModel.stats != null) _buildStats(viewModel.stats!, context),
                    const SizedBox(height: 32),
                    Text("PREFERENCES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                    const SizedBox(height: 16),
                    _buildMenuTile(Icons.help_outline, "Help & Support", context),
                    const SizedBox(height: 24),
                    // ... inside your ProfileScreen build method ...

                    Center(
                      child: TextButton(
                        onPressed: () async {
                          // 1. Get both ViewModels
                          final authVM = Provider.of<AuthViewModel>(context, listen: false);
                          final themeVM = Provider.of<ThemeViewModel>(context, listen: false);

                          // 2. Reset Theme to Light Mode FIRST
                          await themeVM.resetTheme();

                          // 3. Then Logout
                          await authVM.logout();

                          // 4. Navigate back to Login
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context, 
                              MaterialPageRoute(builder: (_) => const AuthGate()), 
                              (r) => false
                            );
                          }
                        },
                        child: Text("Sign Out", style: TextStyle(color: Colors.red[300], fontSize: 16)),
                      ),
                    ),
                    
                    // ... rest of your code ...
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStats(Map<String, dynamic> stats, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(stats['total_predictions']?.toString() ?? '0', "Scans", context),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _statItem(stats['healthy_count']?.toString() ?? '0', "Healthy", context),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildMenuTile(IconData icon, String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).iconTheme.color),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
          trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
        ),
      ),
    );
  }
}
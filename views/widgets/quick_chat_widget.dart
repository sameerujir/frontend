import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class QuickChatWidget extends StatelessWidget {
  const QuickChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: AppTheme.emeraldPrimary),
                const SizedBox(width: 8),
                const Text("Quick Assist", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.emeraldDark)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: Center(child: Text("Quick Questions coming soon...", style: TextStyle(color: Colors.grey[400]))),
          ),
        ],
      ),
    );
  }
}
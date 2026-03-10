import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:plant_app/views/widgets/history_item_card.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/history_viewmodel.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryViewModel>(context, listen: false).loadHistory();
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            title: Text("Collection", style: TextStyle(color: AppTheme.emeraldDark, fontWeight: FontWeight.bold)),
          ),
          Consumer<HistoryViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childCount: viewModel.history.length,
                  itemBuilder: (context, index) {
                    return HistoryItemCard(item: viewModel.history[index]);
                  },
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
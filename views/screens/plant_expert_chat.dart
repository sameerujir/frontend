import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/chat_viewmodel.dart';

class PlantExpertChat extends StatefulWidget {
  const PlantExpertChat({super.key});

  @override
  State<PlantExpertChat> createState() => _PlantExpertChatState();
}

class _PlantExpertChatState extends State<PlantExpertChat> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Plant Expert", style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: textColor),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final msg = viewModel.messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 2, height: 24, margin: const EdgeInsets.only(top: 4, right: 16), color: msg.isUser ? Colors.grey[300] : primaryColor),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(msg.isUser ? "You" : "Plant Expert", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: msg.isUser ? Colors.grey : primaryColor)),
                                  const SizedBox(height: 4),
                                  Text(msg.text, style: TextStyle(fontSize: 16, height: 1.6, color: textColor)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(30)),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: "Ask about your plants...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.arrow_upward_rounded, color: primaryColor),
                            onPressed: () {
                              viewModel.sendMessage(_controller.text);
                              _controller.clear();
                            },
                          ),
                        ),
                        onSubmitted: (val) { viewModel.sendMessage(val); _controller.clear(); },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
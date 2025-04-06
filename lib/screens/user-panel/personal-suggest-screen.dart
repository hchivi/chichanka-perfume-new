import 'package:chichanka_perfume/screens/user-panel/suggest-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonalizedSuggestionsScreen extends StatelessWidget {
  final List<String> suggestions;

  const PersonalizedSuggestionsScreen({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gợi ý nước hoa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstant.navy,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                'Nước hoa mùi ${suggestions[index]}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Phù hợp với sở thích của bạn'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Chuyển hướng sang SuggestionsScreen với mùi hương được chọn
                Get.to(
                    () => SuggestionsScreen(selectedScent: suggestions[index]));
              },
            ),
          );
        },
      ),
    );
  }
}

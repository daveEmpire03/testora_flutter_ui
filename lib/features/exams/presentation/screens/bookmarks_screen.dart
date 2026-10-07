import 'package:flutter/material.dart';
import 'package:testora_flutter_ui/shared/testora_widgets.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: const TestoraEmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'No bookmarks',
        message:
            'Questions you bookmark during practice sessions will appear here.',
      ),
    );
  }
}

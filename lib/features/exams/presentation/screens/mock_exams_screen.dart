import 'package:flutter/material.dart';
import 'package:testora_flutter_ui/shared/testora_widgets.dart';

class MockExamsScreen extends StatelessWidget {
  const MockExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Exams')),
      body: const TestoraEmptyState(
        icon: Icons.timer_outlined,
        title: 'No mock exams yet',
        message:
            'Timed mock exam sessions will appear here once they are available.',
      ),
    );
  }
}

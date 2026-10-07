import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  static const _subjects = [
    _Subject('mathematics', 'Mathematics', Icons.functions_rounded),
    _Subject('english', 'English Language', Icons.translate_rounded),
    _Subject('physics', 'Physics', Icons.science_outlined),
    _Subject('chemistry', 'Chemistry', Icons.biotech_outlined),
    _Subject('biology', 'Biology', Icons.eco_outlined),
    _Subject('government', 'Government', Icons.gavel_rounded),
    _Subject('economics', 'Economics', Icons.trending_up_rounded),
    _Subject('literature', 'Literature', Icons.menu_book_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _subjects.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final s = _subjects[i];
          final theme = Theme.of(context);

          return Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap:
                  () => context.pushNamed(
                    'exam-details',
                    pathParameters: {'examId': s.id},
                  ),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: .5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(s.icon, color: AppColors.purple, size: 22),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Subject {
  final String id;
  final String name;
  final IconData icon;

  const _Subject(this.id, this.name, this.icon);
}

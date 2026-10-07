import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';
import '../../../exams/application/exam_catalog_providers.dart';
import '../../../exams/domain/entities/exam_subject.dart';
import '../../domain/quiz_configuration.dart';
import '../../providers/quiz_providers.dart';

class QuizSetupScreen extends ConsumerStatefulWidget {
  const QuizSetupScreen({super.key, required this.subjectId});

  final String subjectId;

  @override
  ConsumerState<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends ConsumerState<QuizSetupScreen> {
  @override
  void initState() {
    super.initState();
    final categoryId = ref.read(selectedExamCategoryProvider);
    ref
        .read(quizSetupProvider.notifier)
        .resetForExam(categoryId, subjectId: widget.subjectId);
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(quizSetupProvider);
    final categories = ref.watch(examCategoriesProvider);
    final subjects = ref.watch(examSubjectsProvider(config.examCategoryId));
    final controller = ref.read(quizSetupProvider.notifier);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Customize quiz')),
      body: SafeArea(
        child: subjects.when(
          loading: () => const TestoraLoading(message: 'Loading quiz setup...'),
          error:
              (error, _) => TestoraEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Could not load quiz setup',
                message: '$error',
              ),
          data: (availableSubjects) {
            final selectedSubject = _findSubject(
              availableSubjects,
              config.subjectId,
            );

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sp40,
              ),
              children: [
                Text(
                  'Build your practice session',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Choose the number of questions, time limit and content you want to practise.',
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                _SetupSection(
                  icon: Icons.tune_rounded,
                  title: 'Quiz configuration',
                  child: Column(
                    children: [
                      _ValueSlider(
                        label: 'Questions',
                        valueLabel: '\${config.questionCount}',
                        value: config.questionCount.toDouble().clamp(1, 5),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        onChanged:
                            (value) =>
                                controller.setQuestionCount(value.round()),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _ModeSelector(
                        selected: config.mode,
                        onSelected: controller.setMode,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _ValueSlider(
                        label: 'Time limit',
                        valueLabel: '\${config.durationMinutes} min',
                        value:
                            config.durationMinutes.toDouble().clamp(5, 120),
                        min: 5,
                        max: 120,
                        divisions: 23,
                        onChanged:
                            (value) =>
                                controller.setDurationMinutes(value.round()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _SetupSection(
                  icon: Icons.library_books_outlined,
                  title: 'Content selection',
                  child: Column(
                    children: [
                      categories.when(
                        loading: () => const _FieldSkeleton(),
                        error: (_, _) => const SizedBox.shrink(),
                        data:
                            (items) => _SelectField(
                              label: 'Question source',
                              value: config.examCategoryId,
                              items: {
                                for (final item in items) item.id: item.name,
                              },
                              onChanged: (value) {
                                ref
                                    .read(
                                      selectedExamCategoryProvider.notifier,
                                    )
                                    .select(value);
                                controller.setExamCategory(value);
                              },
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SelectField(
                        label: 'Subject',
                        value:
                            availableSubjects.any(
                                  (subject) =>
                                      subject.id == config.subjectId,
                                )
                                ? config.subjectId
                                : (availableSubjects.isEmpty
                                    ? ''
                                    : availableSubjects.first.id),
                        items: {
                          for (final subject in availableSubjects)
                            subject.id: subject.name,
                        },
                        onChanged: controller.setSubject,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SelectField(
                        label: 'Topic',
                        value: config.topic ?? '',
                        items: {
                          '': 'All topics',
                          for (final topic
                              in selectedSubject?.topics ?? const <String>[])
                            topic: topic,
                        },
                        onChanged:
                            (value) => controller.setTopic(
                              value.isEmpty ? null : value,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SelectField(
                        label: 'Year',
                        value: config.year?.toString() ?? '',
                        items: {
                          '': 'All years',
                          for (final year
                              in selectedSubject?.years ?? const <int>[])
                            '\$year': '\$year',
                        },
                        onChanged:
                            (value) => controller.setYear(
                              value.isEmpty ? null : int.tryParse(value),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TestoraButton(
                  label: 'Take quiz',
                  icon: Icons.play_arrow_rounded,
                  onTap: () => _confirmStart(config),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  ExamSubject? _findSubject(List<ExamSubject> subjects, String id) {
    for (final subject in subjects) {
      if (subject.id == id) return subject;
    }
    return subjects.isEmpty ? null : subjects.first;
  }

  Future<void> _confirmStart(QuizConfiguration config) async {
    final shouldStart = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            icon: const Icon(Icons.timer_outlined, size: 34),
            title: const Text('Quiz ready'),
            content: Text(
              'You are about to start a \${config.durationMinutes}-minute '
              'quiz with \${config.questionCount} question'
              '\${config.questionCount == 1 ? '' : 's'}.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Start'),
              ),
            ],
          ),
    );

    if (shouldStart != true || !mounted) return;

    ref.invalidate(quizControllerProvider);
    final current = ref.read(quizSetupProvider);

    context.pushNamed(
      'quiz',
      pathParameters: {'examId': current.subjectId},
    );
  }
}

class _SetupSection extends StatelessWidget {
  const _SetupSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: tokens.border),
                ),
                child: Icon(icon, size: 19, color: tokens.textPrimary),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}

class _ValueSlider extends StatelessWidget {
  const _ValueSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TestoraBadge(label: valueLabel),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selected,
    required this.onSelected,
  });

  final QuizMode selected;
  final ValueChanged<QuizMode> onSelected;

  @override
  Widget build(BuildContext context) {
    const options = <(QuizMode, IconData, String)>[
      (QuizMode.multiple, Icons.library_books_outlined, 'Multiple'),
      (QuizMode.single, Icons.notes_rounded, 'Single'),
      (QuizMode.flash, Icons.style_outlined, 'Flash'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz type',
          style: TextStyle(
            color: context.tokens.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (var index = 0; index < options.length; index++) ...[
              if (index > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ModeCard(
                  icon: options[index].\$2,
                  label: options[index].\$3,
                  selected: selected == options[index].\$1,
                  onTap: () => onSelected(options[index].\$1),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Material(
      color: selected ? tokens.textPrimary : tokens.surfaceSecondary,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: selected ? tokens.textPrimary : tokens.border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? tokens.background : tokens.textPrimary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: selected ? tokens.background : tokens.textPrimary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final safeValue =
        items.containsKey(value)
            ? value
            : (items.isEmpty ? null : items.keys.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: safeValue,
          isExpanded: true,
          items: [
            for (final entry in items.entries)
              DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }
}

class _FieldSkeleton extends StatelessWidget {
  const _FieldSkeleton();

  @override
  Widget build(BuildContext context) {
    return const TestoraSkeleton(height: 54);
  }
}

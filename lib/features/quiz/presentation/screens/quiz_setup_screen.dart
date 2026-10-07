import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../exams/application/exam_catalog_providers.dart';
import '../../../exams/domain/entities/exam_subject.dart';
import '../../domain/quiz_configuration.dart';
import '../../providers/quiz_providers.dart';

class QuizSetupScreen extends ConsumerStatefulWidget {
  const QuizSetupScreen({
    super.key,
    required this.subjectId,
  });

  final String subjectId;

  @override
  ConsumerState<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends ConsumerState<QuizSetupScreen> {
  @override
  void initState() {
    super.initState();
    final category = ref.read(selectedExamCategoryProvider);
    ref
        .read(quizSetupProvider.notifier)
        .resetForExam(category, subjectId: widget.subjectId);
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(quizSetupProvider);
    final categories = ref.watch(examCategoriesProvider);
    final subjects = ref.watch(examSubjectsProvider(config.examCategoryId));
    final controller = ref.read(quizSetupProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.brandDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Customize Your Quiz',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.brandDeepPurple,
              AppColors.brandPlum,
              AppColors.brandDeep,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: subjects.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (error, _) => _SetupError(message: '$error'),
            data: (availableSubjects) {
              final selectedSubject = _subjectFor(
                availableSubjects,
                config.subjectId,
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  const _SetupHeader(),
                  const SizedBox(height: 18),
                  _GlassSection(
                    icon: Icons.tune_rounded,
                    title: 'Quiz Configuration',
                    child: Column(
                      children: [
                        _ValueSlider(
                          label: 'Number of questions',
                          valueLabel: '${config.questionCount}',
                          value: config.questionCount.toDouble(),
                          min: 1,
                          max: 50,
                          divisions: 49,
                          onChanged:
                              (value) =>
                                  controller.setQuestionCount(value.round()),
                        ),
                        const SizedBox(height: 18),
                        _ModeSelector(
                          selected: config.mode,
                          onSelected: controller.setMode,
                        ),
                        const SizedBox(height: 18),
                        _ValueSlider(
                          label: 'Time in minutes',
                          valueLabel: '${config.durationMinutes} mins',
                          value: config.durationMinutes.toDouble(),
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
                  const SizedBox(height: 14),
                  _GlassSection(
                    icon: Icons.library_books_outlined,
                    title: 'Content Selection',
                    child: Column(
                      children: [
                        categories.when(
                          loading: () => const _FieldSkeleton(),
                          error: (_, _) => const SizedBox.shrink(),
                          data:
                              (items) => _DropdownField<String>(
                                label: 'Question Source',
                                value: config.examCategoryId,
                                items: [
                                  for (final item in items)
                                    DropdownMenuItem(
                                      value: item.id,
                                      child: Text(item.name.toUpperCase()),
                                    ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  ref
                                      .read(selectedExamCategoryProvider.notifier)
                                      .select(value);
                                  controller.setExamCategory(value);
                                },
                              ),
                        ),
                        const SizedBox(height: 14),
                        _DropdownField<String>(
                          label: 'Subjects',
                          value:
                              availableSubjects.any(
                                    (subject) =>
                                        subject.id == config.subjectId,
                                  )
                                  ? config.subjectId
                                  : availableSubjects.isEmpty ? null : availableSubjects.first.id,
                          items: [
                            for (final subject in availableSubjects)
                              DropdownMenuItem(
                                value: subject.id,
                                child: Text(subject.name),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) controller.setSubject(value);
                          },
                        ),
                        const SizedBox(height: 14),
                        _DropdownField<String?>(
                          label: 'Topic',
                          value: config.topic,
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All topics'),
                            ),
                            for (final topic
                                in selectedSubject?.topics ?? const <String>[])
                              DropdownMenuItem<String?>(
                                value: topic,
                                child: Text(topic),
                              ),
                          ],
                          onChanged: controller.setTopic,
                        ),
                        const SizedBox(height: 14),
                        _DropdownField<int?>(
                          label: 'Year',
                          value: config.year,
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All years'),
                            ),
                            for (final year
                                in selectedSubject?.years ?? const <int>[])
                              DropdownMenuItem<int?>(
                                value: year,
                                child: Text('$year'),
                              ),
                          ],
                          onChanged: controller.setYear,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _TakeQuizButton(
                    onPressed: () => _showReadyDialog(config),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  ExamSubject? _subjectFor(List<ExamSubject> subjects, String id) {
    for (final subject in subjects) {
      if (subject.id == id) return subject;
    }
    return subjects.isEmpty ? null : subjects.first;
  }

  Future<void> _showReadyDialog(QuizConfiguration config) async {
    final start = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.timer_outlined,
            size: 38,
            color: AppColors.brandPurple,
          ),
          title: const Text('Quiz Timer'),
          content: Text(
            'Your ${config.durationMinutes}-minute quiz with '
            '${config.questionCount} question'
            '${config.questionCount == 1 ? '' : 's'} is ready.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Start'),
            ),
          ],
        );
      },
    );

    if (start != true || !mounted) return;

    ref.invalidate(quizControllerProvider);
    final current = ref.read(quizSetupProvider);
    context.pushNamed(
      'quiz',
      pathParameters: {'examId': current.subjectId},
    );
  }
}

class _SetupHeader extends StatelessWidget {
  const _SetupHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Color(0x33FFFFFF),
          child: Icon(
            Icons.alarm_on_rounded,
            color: AppColors.brandGold,
            size: 30,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Customize Your Quiz',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Configure your perfect practice session',
          style: TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.brandGold, size: 19),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                valueLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.brandGold,
          inactiveColor: Colors.white24,
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
    const items = <(QuizMode, IconData, String)>[
      (QuizMode.multiple, Icons.library_books_outlined, 'Multiple'),
      (QuizMode.single, Icons.notes_rounded, 'Single'),
      (QuizMode.flash, Icons.style_outlined, 'Flash'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiz Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              if (index > 0) const SizedBox(width: 8),
              Expanded(
                child: _ModeCard(
                  icon: items[index].$2,
                  label: items[index].$3,
                  selected: selected == items[index].$1,
                  onTap: () => onSelected(items[index].$1),
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
    return Material(
      color:
          selected
              ? AppColors.brandPurple.withValues(alpha: 0.65)
              : Colors.white.withValues(alpha: 0.055),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected
                      ? Colors.white.withValues(alpha: 0.65)
                      : Colors.white.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xCCFFFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.brandPlum,
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.045),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _TakeQuizButton extends StatelessWidget {
  const _TakeQuizButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.send_rounded, size: 18),
        label: const Text('Take Quiz'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}

class _FieldSkeleton extends StatelessWidget {
  const _FieldSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _SetupError extends StatelessWidget {
  const _SetupError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

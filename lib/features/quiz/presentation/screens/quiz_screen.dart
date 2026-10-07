import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/quiz_models.dart';
import '../../providers/quiz_providers.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String examId;
  const QuizScreen({super.key, required this.examId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _autoSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizControllerProvider);
    final controller = ref.read(quizControllerProvider.notifier);

    ref.listen(quizControllerProvider, (prev, next) {
      if (next.remaining == Duration.zero &&
          !_autoSubmitted &&
          prev?.remaining != Duration.zero) {
        _autoSubmitted = true;
        _submit(autoSubmit: true);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog(controller);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Exit quiz',
            onPressed: () => _showExitDialog(controller),
            icon: const Icon(Icons.close_rounded),
          ),
          title: _TimerDisplay(
            time: _fmt(state.remaining),
            warning: state.isTimeWarning,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip:
                  state.isBookmarked ? 'Remove bookmark' : 'Bookmark question',
              onPressed: controller.toggleBookmark,
              icon: Icon(
                state.isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color:
                    state.isBookmarked
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
            ),
            const SizedBox(width: 5),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress bar
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: state.progress),
                          duration: const Duration(milliseconds: 300),
                          builder:
                              (_, v, _) => LinearProgressIndicator(
                                value: v,
                                minHeight: 7,
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    InkWell(
                      onTap: () => _showNavigator(state, controller),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 5,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${state.currentIndex + 1}/${state.questions.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              Icons.grid_view_rounded,
                              size: 17,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Question
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
                  child: _QuestionBody(
                    key: ValueKey(state.currentQuestion.id),
                    question: state.currentQuestion,
                    currentIndex: state.currentIndex,
                    selectedOption: state.selectedOption,
                    onSelect: controller.selectAnswer,
                    onClear: controller.clearAnswer,
                  ),
                ),
              ),

              // Bottom bar
              _BottomBar(
                isFirst: state.isFirstQuestion,
                isLast: state.isLastQuestion,
                onPrev: controller.previous,
                onNext: controller.next,
                onFinish: () => _handleFinish(state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _handleFinish(QuizState state) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Submit Quiz?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Are you sure you want to submit your answers?'),
                const SizedBox(height: 18),
                _DialogStat(
                  label: 'Answered',
                  value: '${state.answeredCount}',
                  color: AppColors.success,
                ),
                const SizedBox(height: 8),
                _DialogStat(
                  label: 'Unanswered',
                  value: '${state.unansweredCount}',
                  color:
                      state.unansweredCount > 0
                          ? Colors.orange
                          : AppColors.success,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Continue Quiz'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Submit'),
              ),
            ],
          ),
    );
    if (ok == true) _submit();
  }

  void _submit({bool autoSubmit = false}) {
    final controller = ref.read(quizControllerProvider.notifier);
    final result = controller.submit();
    ref.read(lastQuizResultProvider.notifier).set(result);

    if (autoSubmit && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time is up. Your quiz has been submitted.'),
        ),
      );
    }

    if (mounted) {
      context.goNamed(
        'result',
        pathParameters: {'examId': widget.examId, 'attemptId': 'current'},
      );
    }
  }

  Future<void> _showExitDialog(QuizController controller) async {
    final exit = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Leave Quiz?'),
            content: const Text(
              'Your current progress may be lost if you leave before submitting.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Continue Quiz'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('Leave'),
              ),
            ],
          ),
    );
    if (exit == true && mounted) {
      controller.submit();
      context.go('/home');
    }
  }

  void _showNavigator(QuizState state, QuizController controller) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (sheetCtx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Question Navigator',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${state.answeredCount} answered • '
                    '${state.unansweredCount} unanswered',
                    style: TextStyle(
                      color: Theme.of(sheetCtx).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.questions.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) {
                      final q = state.questions[index];
                      return _NumberButton(
                        number: index + 1,
                        answered: state.answers.containsKey(q.id),
                        bookmarked: state.bookmarked.contains(q.id),
                        current: index == state.currentIndex,
                        onTap: () {
                          controller.goTo(index);
                          Navigator.of(sheetCtx).pop();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// =============================================================================
// QUESTION BODY
// =============================================================================

class _QuestionBody extends StatelessWidget {
  final QuizQuestion question;
  final int currentIndex;
  final int? selectedOption;
  final ValueChanged<int> onSelect;
  final VoidCallback onClear;

  const _QuestionBody({
    super.key,
    required this.question,
    required this.currentIndex,
    required this.selectedOption,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                question.subject,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Question ${currentIndex + 1}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 250.ms),
        const SizedBox(height: 20),
        Text(
          question.question,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.45,
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: .08, end: 0),
        const SizedBox(height: 26),
        ...List.generate(question.options.length, (i) {
          final opt = question.options[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _AnswerOption(
                  option: opt,
                  selected: selectedOption == i,
                  onTap: () => onSelect(i),
                )
                .animate(delay: (60 * i).ms)
                .fadeIn(duration: 250.ms)
                .slideY(begin: .06, end: 0),
          );
        }),
        if (selectedOption != null) ...[
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: onClear,
              child: const Text('Clear Answer'),
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// ANSWER OPTION
// =============================================================================

class _AnswerOption extends StatelessWidget {
  final QuizOption option;
  final bool selected;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color:
          selected ? primary.withValues(alpha: .07) : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  selected
                      ? primary
                      : theme.colorScheme.outlineVariant.withValues(alpha: .6),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? primary : primary.withValues(alpha: .07),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  option.label,
                  style: TextStyle(
                    color: selected ? Colors.white : primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child:
                    selected
                        ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey('selected'),
                          color: primary,
                        )
                        : Icon(
                          Icons.radio_button_unchecked,
                          key: const ValueKey('unselected'),
                          color: theme.colorScheme.outline,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TIMER DISPLAY
// =============================================================================

class _TimerDisplay extends StatelessWidget {
  final String time;
  final bool warning;

  const _TimerDisplay({required this.time, required this.warning});

  @override
  Widget build(BuildContext context) {
    final color =
        warning ? Colors.redAccent : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            time,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BOTTOM BAR
// =============================================================================

class _BottomBar extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _BottomBar({
    required this.isFirst,
    required this.isLast,
    required this.onPrev,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: .5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isFirst ? null : onPrev,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: isLast ? onFinish : onNext,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLast ? 'Finish' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// NUMBER BUTTON (navigator)
// =============================================================================

class _NumberButton extends StatelessWidget {
  final int number;
  final bool answered;
  final bool bookmarked;
  final bool current;
  final VoidCallback onTap;

  const _NumberButton({
    required this.number,
    required this.answered,
    required this.bookmarked,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color bg = theme.colorScheme.surfaceContainerHighest;
    Color fg = theme.colorScheme.onSurface;

    if (answered) {
      bg = AppColors.success.withValues(alpha: .12);
      fg = AppColors.success;
    }
    if (current) {
      bg = theme.colorScheme.primary;
      fg = theme.colorScheme.onPrimary;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    current
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant.withValues(
                          alpha: .5,
                        ),
              ),
            ),
            child: Text(
              '$number',
              style: TextStyle(color: fg, fontWeight: FontWeight.w800),
            ),
          ),
          if (bookmarked)
            const Positioned(
              right: 3,
              top: 3,
              child: Icon(
                Icons.bookmark_rounded,
                size: 13,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// DIALOG STAT
// =============================================================================

class _DialogStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DialogStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

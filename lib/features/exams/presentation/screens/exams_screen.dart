import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/exam_catalog_providers.dart';
import '../../domain/entities/exam_subject.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryId = ref.watch(selectedExamCategoryProvider);
    final subjects = ref.watch(examSubjectsProvider(categoryId));
    final categories = ref.watch(examCategoriesProvider);

    final categoryName = categories.maybeWhen(
      data: (items) {
        for (final item in items) {
          if (item.id == categoryId) return item.name;
        }
        return 'General';
      },
      orElse: () => 'General',
    );

    return Scaffold(
      backgroundColor: AppColors.brandDeep,
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
          child: subjects.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error:
                (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load subjects.\n$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            data:
                (items) => CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: _SubjectsHeader(
                          categoryName: categoryName,
                          onBack: () => context.go('/home'),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final subject = items[index];
                            return _SubjectCard(
                                  subject: subject,
                                  onTap:
                                      () => context.pushNamed(
                                        'exam-details',
                                        pathParameters: {
                                          'examId': subject.id,
                                        },
                                      ),
                                )
                                .animate(delay: (35 * index).ms)
                                .fadeIn(duration: 220.ms)
                                .slideY(
                                  begin: 0.04,
                                  end: 0,
                                  duration: 220.ms,
                                );
                          },
                          childCount: items.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.92,
                            ),
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}

class _SubjectsHeader extends StatelessWidget {
  const _SubjectsHeader({
    required this.categoryName,
    required this.onBack,
  });

  final String categoryName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton.filledTonal(
          onPressed: onBack,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(height: 18),
        Text(
          categoryName.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Explore available subjects',
          style: TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Color(0xB3FFFFFF),
              ),
              hintText: 'Search subjects...',
              hintStyle: TextStyle(color: Color(0x80FFFFFF)),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.onTap,
  });

  final ExamSubject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(subject.iconKey);

    return Material(
      color: Colors.white.withValues(alpha: 0.045),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandViolet.withValues(alpha: 0.18),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                subject.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Start Practice',
                style: TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(String key) {
  switch (key) {
    case 'psychology':
      return Icons.psychology_outlined;
    case 'eco':
      return Icons.eco_outlined;
    case 'science':
      return Icons.science_outlined;
    case 'book':
      return Icons.menu_book_outlined;
    case 'newspaper':
      return Icons.newspaper_outlined;
    case 'translate':
      return Icons.translate_rounded;
    case 'economics':
      return Icons.monetization_on_outlined;
    case 'public':
      return Icons.public_rounded;
    case 'government':
      return Icons.account_balance_outlined;
    case 'library':
      return Icons.library_books_outlined;
    case 'calculate':
      return Icons.calculate_outlined;
    case 'bolt':
      return Icons.bolt_rounded;
    case 'groups':
      return Icons.groups_2_outlined;
    case 'computer':
      return Icons.computer_rounded;
    case 'language':
      return Icons.language_rounded;
    case 'architecture':
      return Icons.architecture_outlined;
    case 'home':
      return Icons.home_outlined;
    case 'restaurant':
      return Icons.restaurant_outlined;
    case 'receipt':
      return Icons.receipt_long_outlined;
    default:
      return Icons.school_outlined;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';
import '../../application/exam_catalog_providers.dart';
import '../../domain/entities/exam_subject.dart';

class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final categoryId = ref.watch(selectedExamCategoryProvider);
    final categories = ref.watch(examCategoriesProvider);
    final subjects = ref.watch(examSubjectsProvider(categoryId));
    final tokens = context.tokens;

    final categoryName = categories.maybeWhen(
      data: (items) {
        for (final item in items) {
          if (item.id == categoryId) return item.name;
        }
        return 'General';
      },
      orElse: () => 'General',
    );

    return TestoraScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 28,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Choose a subject to start practising.',
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    onChanged:
                        (value) => setState(
                          () => _query = value.trim().toLowerCase(),
                        ),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Search subjects',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  const SectionTitle(
                    title: 'Subjects',
                    subtitle: 'Explore available subjects',
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          subjects.when(
            loading:
                () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: TestoraLoading(message: 'Loading subjects...'),
                  ),
                ),
            error:
                (error, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: TestoraEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Could not load subjects',
                      message: '$error',
                    ),
                  ),
                ),
            data: (items) {
              final filtered =
                  items.where((subject) {
                    if (_query.isEmpty) return true;
                    return subject.name.toLowerCase().contains(_query) ||
                        subject.description.toLowerCase().contains(_query);
                  }).toList(growable: false);

              if (filtered.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: TestoraEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No subjects found',
                      message: 'Try a different search term.',
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sp40,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final subject = filtered[index];
                      return TestoraGridCard(
                            icon: _iconFor(subject.iconKey),
                            title: subject.name,
                            subtitle: subject.description,
                            onTap:
                                () => context.pushNamed(
                                  'exam-details',
                                  pathParameters: {'examId': subject.id},
                                ),
                          )
                          .animate(delay: (40 * index).ms)
                          .fadeIn(duration: 230.ms)
                          .slideY(
                            begin: 0.04,
                            end: 0,
                            duration: 230.ms,
                            curve: Curves.easeOutCubic,
                          );
                    },
                    childCount: filtered.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.95,
                      ),
                ),
              );
            },
          ),
        ],
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
      return Icons.trending_up_rounded;
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// MODELS
// =============================================================================

class SubjectPerformance {
  final String name;
  final double score;
  final IconData icon;

  const SubjectPerformance({
    required this.name,
    required this.score,
    required this.icon,
  });
}

class DayActivity {
  final String day;
  final double value;

  const DayActivity(this.day, this.value);
}

class ProgressStats {
  final double overallAccuracy;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final List<SubjectPerformance> subjects;
  final List<DayActivity> weeklyActivity;
  final int studyStreak;
  final String strongestSubject;
  final String weakestSubject;

  const ProgressStats({
    required this.overallAccuracy,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.subjects,
    required this.weeklyActivity,
    required this.studyStreak,
    required this.strongestSubject,
    required this.weakestSubject,
  });
}

// =============================================================================
// PROVIDER
// =============================================================================

final progressStatsProvider = FutureProvider<ProgressStats>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 600));

  return const ProgressStats(
    overallAccuracy: 0.78,
    totalQuestions: 250,
    correctAnswers: 192,
    wrongAnswers: 58,
    studyStreak: 7,
    strongestSubject: 'Mathematics',
    weakestSubject: 'Chemistry',
    subjects: [
      SubjectPerformance(
        name: 'Mathematics',
        score: 0.85,
        icon: Icons.calculate_rounded,
      ),
      SubjectPerformance(
        name: 'English Language',
        score: 0.78,
        icon: Icons.translate_rounded,
      ),
      SubjectPerformance(
        name: 'Physics',
        score: 0.72,
        icon: Icons.science_outlined,
      ),
      SubjectPerformance(
        name: 'Chemistry',
        score: 0.66,
        icon: Icons.biotech_outlined,
      ),
      SubjectPerformance(
        name: 'Biology',
        score: 0.80,
        icon: Icons.eco_outlined,
      ),
    ],
    weeklyActivity: [
      DayActivity('Mon', 0.35),
      DayActivity('Tue', 0.62),
      DayActivity('Wed', 0.45),
      DayActivity('Thu', 0.82),
      DayActivity('Fri', 0.70),
      DayActivity('Sat', 1.0),
      DayActivity('Sun', 0.58),
    ],
  );
});

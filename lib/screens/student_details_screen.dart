import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import '../utils/app_theme.dart';
import '../widgets/marks_progress_card.dart';
import 'compare_screen.dart';

/// Screen displaying complete academic performance breakdown for a selected student.
class StudentDetailsScreen extends StatelessWidget {
  final Student student;

  const StudentDetailsScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final studentService = Provider.of<StudentService>(context);
    final maxMarks = studentService.maxMarks;
    final avg = student.averageMark;
    final highest = student.highestMark;
    final lowest = student.lowestMark;

    // Calculate Semester delta (Sem 2 vs Sem 1)
    double? semDelta;
    if (student.sem1 != null && student.sem2 != null) {
      semDelta = student.sem2! - student.sem1!;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Academic Record'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Compare with another student',
            icon: const Icon(Icons.compare_arrows_rounded, color: AppTheme.secondaryElectric),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CompareScreen(initialStudentA: student),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      student.initials,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryElectric.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                student.rollNo,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sr No: ${student.srNo}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dept. of Robotics & Automation',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Academic Summary Highlights (Average, Highest, Lowest, Completed)
            Row(
              children: [
                Expanded(
                  child: _SummaryStatBox(
                    label: 'Overall Avg.',
                    value: avg != null ? '${avg.toStringAsFixed(1)}%' : 'N/A',
                    color: avg != null && avg >= 75
                        ? AppTheme.positiveGreen
                        : AppTheme.secondaryElectric,
                    icon: Icons.analytics_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryStatBox(
                    label: 'Highest Mark',
                    value: Student.formatScore(highest),
                    color: AppTheme.positiveGreen,
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryStatBox(
                    label: 'Lowest Mark',
                    value: Student.formatScore(lowest),
                    color: AppTheme.warningOrange,
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Semester Progression Improvement Banner
            if (semDelta != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: semDelta >= 0
                      ? AppTheme.positiveGreenBg
                      : AppTheme.warningOrangeBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: semDelta >= 0
                        ? AppTheme.positiveGreen.withOpacity(0.3)
                        : AppTheme.warningOrange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      semDelta >= 0 ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                      color: semDelta >= 0
                          ? AppTheme.positiveGreen
                          : AppTheme.warningOrange,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        semDelta >= 0
                            ? 'Semester 2 performance improved by +${semDelta.toStringAsFixed(1)} marks over Semester 1.'
                            : 'Semester 2 dropped by ${semDelta.abs().toStringAsFixed(1)} marks compared to Semester 1.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: semDelta >= 0
                              ? const Color(0xFF065F46)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Assessment Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Scores recorded for ${student.name} (Calculated out of ${maxMarks.toInt()})',
              style: const TextStyle(fontSize: 12, color: AppTheme.neutralGrey),
            ),
            const SizedBox(height: 12),

            // Assessment Cards: 10th, 12th, Sem 1, Sem 2
            MarksProgressCard(
              assessmentName: '10th Standard Board',
              subtitle: 'Secondary School Certificate examination',
              score: student.marks10th,
              maxMarks: maxMarks,
              icon: Icons.school_outlined,
            ),
            MarksProgressCard(
              assessmentName: '12th Standard / Diploma',
              subtitle: 'Higher Secondary examination (or equivalent lateral diploma)',
              score: student.marks12th,
              maxMarks: maxMarks,
              icon: Icons.history_edu_outlined,
            ),
            MarksProgressCard(
              assessmentName: 'Semester 1',
              subtitle: 'Autumn term university exams',
              score: student.sem1,
              maxMarks: maxMarks,
              icon: Icons.assignment_outlined,
            ),
            MarksProgressCard(
              assessmentName: 'Semester 2',
              subtitle: 'Spring term university exams',
              score: student.sem2,
              maxMarks: maxMarks,
              icon: Icons.fact_check_outlined,
            ),

            const SizedBox(height: 12),

            // Compare Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.compare_arrows_rounded),
                label: const Text('Compare with Another Student'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CompareScreen(initialStudentA: student),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryStatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.neutralGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

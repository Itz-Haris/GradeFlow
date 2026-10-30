import 'package:flutter/material.dart';
import '../models/student.dart';
import '../utils/app_theme.dart';

/// Reusable card widget for displaying a summary of a student's academic record in lists.
/// Supports dynamic styling for Light and Dark themes.
class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;
  final double maxMarks;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
    this.maxMarks = 100.0,
  });

  Color _getScoreColor(double? score) {
    if (score == null) return AppTheme.neutralGrey;
    final pct = (score / maxMarks) * 100.0;
    if (pct >= 75.0) return AppTheme.positiveGreen;
    if (pct >= 50.0) return AppTheme.secondaryElectric;
    if (pct >= 40.0) return AppTheme.warningOrange;
    return AppTheme.criticalRed;
  }

  @override
  Widget build(BuildContext context) {
    final avg = student.averageMark;
    final avgColor = _getScoreColor(avg);
    final avgFraction = Student.getFraction(avg, maxMarks) ?? 0.0;
    final surfaceColor = AppTheme.getSurface(context);
    final borderColor = AppTheme.getBorder(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final pillBg = AppTheme.getPillBackground(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: AppTheme.getSoftShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Initials avatar + Name/Roll + Average Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Initials circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.electricCyanGradient,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        student.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name and Roll
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: pillBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  student.rollNo,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.secondaryElectric,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Sr #${student.srNo}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Average badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: avgColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: avgColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            avg != null ? '${avg.toStringAsFixed(1)}%' : 'N/A',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: avgColor,
                            ),
                          ),
                          Text(
                            'Average',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(height: 1, color: borderColor),
                const SizedBox(height: 12),

                // Middle: Semester 1 & Semester 2 Chips
                Row(
                  children: [
                    Expanded(
                      child: _ScorePill(
                        label: 'Sem 1',
                        value: Student.formatScore(student.sem1),
                        color: _getScoreColor(student.sem1),
                        background: pillBg,
                        textColor: textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ScorePill(
                        label: 'Sem 2',
                        value: Student.formatScore(student.sem2),
                        color: _getScoreColor(student.sem2),
                        background: pillBg,
                        textColor: textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ScorePill(
                        label: 'Assessments',
                        value: '${student.availableMarksCount}/4',
                        color: textSecondary,
                        background: pillBg,
                        textColor: textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom: Progress bar indicating average vs max marks
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: avg != null ? avgFraction : 0.0,
                          minHeight: 6,
                          backgroundColor: pillBg,
                          valueColor: AlwaysStoppedAnimation<Color>(avgColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color background;
  final Color textColor;

  const _ScorePill({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

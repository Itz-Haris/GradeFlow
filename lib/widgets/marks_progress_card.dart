import 'package:flutter/material.dart';
import '../models/student.dart';
import '../utils/app_theme.dart';

/// Card displaying detailed marks breakdown for an individual assessment.
/// Handles missing scores by displaying "N/A" with clean visual feedback.
/// Supports dynamic styling for Light and Dark themes.
class MarksProgressCard extends StatelessWidget {
  final String assessmentName;
  final double? score;
  final double maxMarks;
  final IconData icon;
  final String? subtitle;

  const MarksProgressCard({
    super.key,
    required this.assessmentName,
    required this.score,
    this.maxMarks = 100.0,
    required this.icon,
    this.subtitle,
  });

  String _getPerformanceCategory(double? val) {
    if (val == null) return 'N/A';
    final pct = (val / maxMarks) * 100.0;
    if (pct >= 80.0) return 'Distinction';
    if (pct >= 60.0) return 'First Class';
    if (pct >= 40.0) return 'Pass';
    return 'Remedial';
  }

  Color _getCategoryColor(double? val) {
    if (val == null) return AppTheme.neutralGrey;
    final pct = (val / maxMarks) * 100.0;
    if (pct >= 80.0) return AppTheme.positiveGreen;
    if (pct >= 60.0) return AppTheme.secondaryElectric;
    if (pct >= 40.0) return AppTheme.warningOrange;
    return AppTheme.criticalRed;
  }

  @override
  Widget build(BuildContext context) {
    final hasScore = score != null;
    final fraction = hasScore ? Student.getFraction(score, maxMarks) ?? 0.0 : 0.0;
    final category = _getPerformanceCategory(score);
    final categoryColor = _getCategoryColor(score);
    final formattedScore = Student.formatScore(score);
    final surfaceColor = AppTheme.getSurface(context);
    final borderColor = AppTheme.getBorder(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final pillBg = AppTheme.getPillBackground(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: AppTheme.getSoftShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: categoryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessmentName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: categoryColor.withOpacity(0.3)),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Score / Max marks presentation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formattedScore,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: hasScore ? textPrimary : textSecondary,
                    ),
                  ),
                  if (hasScore) ...[
                    Text(
                      ' / ${maxMarks.toInt()}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              if (hasScore)
                Text(
                  '${(fraction * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                )
              else
                Text(
                  'Record Missing',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: textSecondary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Visual Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: pillBg,
              valueColor: AlwaysStoppedAnimation<Color>(
                hasScore ? categoryColor : borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

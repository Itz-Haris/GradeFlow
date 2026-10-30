import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Interactive & responsive Bar Chart comparing academic averages (10th, 12th, Sem 1, Sem 2).
/// Built cleanly with custom rendering for maximum reliability and pixel-perfect design.
class AcademicPerformanceChart extends StatelessWidget {
  final double? avg10th;
  final double? avg12th;
  final double? avgSem1;
  final double? avgSem2;
  final double maxMarks;

  const AcademicPerformanceChart({
    super.key,
    required this.avg10th,
    required this.avg12th,
    required this.avgSem1,
    required this.avgSem2,
    this.maxMarks = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    // Check if any data exists
    final hasData = avg10th != null || avg12th != null || avgSem1 != null || avgSem2 != null;

    if (!hasData) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(color: AppTheme.borderGrey, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bar_chart_rounded, size: 48, color: AppTheme.neutralGrey),
            SizedBox(height: 12),
            Text(
              'No Academic Records Available',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.primaryNavy,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Synchronize Google Sheets or switch to Demo Mode to view performance charts.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.neutralGrey),
            ),
          ],
        ),
      );
    }

    final bars = [
      _BarData(
        label: '10th Board',
        shortLabel: '10th',
        value: avg10th,
        color: const Color(0xFF3B82F6), // Blue
      ),
      _BarData(
        label: '12th Board',
        shortLabel: '12th',
        value: avg12th,
        color: const Color(0xFF6366F1), // Indigo
      ),
      _BarData(
        label: 'Semester 1',
        shortLabel: 'Sem 1',
        value: avgSem1,
        color: AppTheme.secondaryElectric, // Electric Blue
      ),
      _BarData(
        label: 'Semester 2',
        shortLabel: 'Sem 2',
        value: avgSem2,
        color: AppTheme.accentCyan, // Cyan
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderGrey, width: 1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cohort Assessment Comparison',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Average score progression across all students (Max: ${maxMarks.toInt()})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.neutralGrey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.insights, size: 14, color: AppTheme.secondaryElectric),
                    SizedBox(width: 4),
                    Text(
                      'Live Averages',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryElectric,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Chart canvas container
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: bars.map((bar) {
                final double fraction = bar.value != null
                    ? (bar.value! / maxMarks).clamp(0.0, 1.0)
                    : 0.0;
                final double barHeight = (fraction * 125).clamp(8.0, 125.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Score value label
                        Text(
                          bar.value != null ? bar.value!.toStringAsFixed(1) : 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: bar.value != null ? AppTheme.primaryNavy : AppTheme.neutralGrey,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // The animated-like vertical bar
                        Container(
                          height: bar.value != null ? barHeight : 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: bar.value != null
                                ? LinearGradient(
                                    colors: [
                                      bar.color.withOpacity(0.8),
                                      bar.color,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  )
                                : null,
                            color: bar.value == null ? AppTheme.borderGrey : null,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                              bottom: Radius.circular(4),
                            ),
                            boxShadow: bar.value != null
                                ? [
                                    BoxShadow(
                                      color: bar.color.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // X-axis label
                        Text(
                          bar.shortLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.borderGrey),
          const SizedBox(height: 12),

          // Pass Benchmark Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Min. Pass Benchmark: 40% (40.0)',
                style: TextStyle(fontSize: 11, color: AppTheme.neutralGrey),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.positiveGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'First Class: >=60% (60.0)',
                style: TextStyle(fontSize: 11, color: AppTheme.neutralGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarData {
  final String label;
  final String shortLabel;
  final double? value;
  final Color color;

  const _BarData({
    required this.label,
    required this.shortLabel,
    required this.value,
    required this.color,
  });
}

/// Chart displaying performance distribution across configured ranges (0–39, 40–59, 60–79, 80–100).
class DistributionBarChart extends StatelessWidget {
  final Map<String, int> distribution;
  final int totalStudents;
  final String metricLabel;

  const DistributionBarChart({
    super.key,
    required this.distribution,
    required this.totalStudents,
    required this.metricLabel,
  });

  Color _getColorForRange(String range) {
    switch (range) {
      case '0–39':
        return AppTheme.criticalRed;
      case '40–59':
        return AppTheme.warningOrange;
      case '60–79':
        return AppTheme.secondaryElectric;
      case '80–100':
        return AppTheme.positiveGreen;
      default:
        return AppTheme.neutralGrey;
    }
  }

  String _getRangeTitle(String range) {
    switch (range) {
      case '0–39':
        return 'Remedial / Needs Attention';
      case '40–59':
        return 'Pass / Average';
      case '60–79':
        return 'First Class / Good';
      case '80–100':
        return 'Distinction / Outstanding';
      default:
        return range;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderGrey, width: 1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Performance Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Metric: $metricLabel',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Number and proportion of students categorized by marks tier',
            style: TextStyle(fontSize: 12, color: AppTheme.neutralGrey),
          ),
          const SizedBox(height: 20),

          // Horizontal Distribution Bars
          ...distribution.entries.map((entry) {
            final range = entry.key;
            final count = entry.value;
            final pct = totalStudents > 0 ? (count / totalStudents) : 0.0;
            final color = _getColorForRange(range);
            final title = _getRangeTitle(range);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$range marks',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '($title)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.neutralGrey,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$count student${count == 1 ? '' : 's'} (${(pct * 100).toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 10,
                      backgroundColor: AppTheme.backgroundLight,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

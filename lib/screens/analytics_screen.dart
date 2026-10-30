import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_service.dart';
import '../utils/app_theme.dart';
import '../widgets/performance_chart.dart';

/// Dedicated Academic Analytics screen providing cohort-level insights and performance distributions.
/// Supports dynamic Light and Dark themes.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedMetric = 'Average';

  @override
  Widget build(BuildContext context) {
    final studentService = Provider.of<StudentService>(context);
    final total = studentService.totalStudents;
    final maxMarks = studentService.maxMarks;
    final highest = studentService.highestRecordedMark;
    final lowest = studentService.lowestRecordedMark;
    final withRecords = studentService.studentsWithRecordsCount;
    final cohortAvg = studentService.cohortAverage;
    final surfaceColor = AppTheme.getSurface(context);
    final borderColor = AppTheme.getBorder(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final pillBg = AppTheme.getPillBackground(context);

    // Distribution
    final distribution = studentService.getPerformanceDistribution(_selectedMetric);

    // Sem 1 vs Sem 2 analysis
    int improvedCount = 0;
    int declinedCount = 0;
    int equalCount = 0;
    for (final s in studentService.students) {
      if (s.sem1 != null && s.sem2 != null) {
        if (s.sem2! > s.sem1!) {
          improvedCount++;
        } else if (s.sem2! < s.sem1!) {
          declinedCount++;
        } else {
          equalCount++;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      appBar: AppBar(
        title: const Text('Academic Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: total == 0
          ? Center(
              child: Text(
                'No student records available for analytics.',
                style: TextStyle(color: textSecondary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cohort Performance Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryElectric.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$withRecords of $total Active Records',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryElectric,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Key Highlights KPI Grid
                  Row(
                    children: [
                      Expanded(
                        child: _AnalyticsKpiCard(
                          title: 'Cohort Avg.',
                          value: cohortAvg != null ? '${cohortAvg.toStringAsFixed(1)}%' : 'N/A',
                          icon: Icons.auto_graph,
                          color: AppTheme.secondaryElectric,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AnalyticsKpiCard(
                          title: 'Highest Mark',
                          value: highest != null ? highest.toStringAsFixed(1) : 'N/A',
                          icon: Icons.emoji_events_outlined,
                          color: AppTheme.positiveGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AnalyticsKpiCard(
                          title: 'Lowest Mark',
                          value: lowest != null ? lowest.toStringAsFixed(1) : 'N/A',
                          icon: Icons.arrow_downward_outlined,
                          color: AppTheme.warningOrange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Main Bar Chart: 10th, 12th, Sem 1, Sem 2
                  AcademicPerformanceChart(
                    avg10th: studentService.avg10th,
                    avg12th: studentService.avg12th,
                    avgSem1: studentService.avgSem1,
                    avgSem2: studentService.avgSem2,
                    maxMarks: maxMarks,
                  ),

                  const SizedBox(height: 20),

                  // Sem 1 vs Sem 2 Head-to-Head Progression Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      border: Border.all(color: borderColor),
                      boxShadow: AppTheme.getSoftShadow(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Semester 1 vs Semester 2 Trajectory',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: pillBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Progression',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryElectric,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Direct comparison of student performance between semesters',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _TrajectoryMetric(
                                label: 'Improved in Sem 2',
                                count: improvedCount,
                                color: AppTheme.positiveGreen,
                                icon: Icons.trending_up,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TrajectoryMetric(
                                label: 'Declined in Sem 2',
                                count: declinedCount,
                                color: AppTheme.criticalRed,
                                icon: Icons.trending_down,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TrajectoryMetric(
                                label: 'Maintained Level',
                                count: equalCount,
                                color: textSecondary,
                                icon: Icons.trending_flat,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Performance Distribution Range Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Metric for Distribution:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _selectedMetric,
                          underline: const SizedBox(),
                          dropdownColor: surfaceColor,
                          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.secondaryElectric),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryElectric,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Average', child: Text('Overall Average')),
                            DropdownMenuItem(value: 'Sem 1', child: Text('Semester 1')),
                            DropdownMenuItem(value: 'Sem 2', child: Text('Semester 2')),
                            DropdownMenuItem(value: '10th', child: Text('10th Marks')),
                            DropdownMenuItem(value: '12th', child: Text('12th Marks')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedMetric = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Performance Distribution Component
                  DistributionBarChart(
                    distribution: distribution,
                    totalStudents: total,
                    metricLabel: _selectedMetric,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _AnalyticsKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsKpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = AppTheme.getSurface(context);
    final borderColor = AppTheme.getBorder(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: AppTheme.getSoftShadow(context),
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
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
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
              fontSize: 18,
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

class _TrajectoryMetric extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _TrajectoryMetric({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import '../utils/app_theme.dart';

/// Screen allowing users to compare two students side-by-side with automatic score highlighting.
class CompareScreen extends StatefulWidget {
  final Student? initialStudentA;
  final Student? initialStudentB;

  const CompareScreen({
    super.key,
    this.initialStudentA,
    this.initialStudentB,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Student? _studentA;
  Student? _studentB;

  @override
  void initState() {
    super.initState();
    _studentA = widget.initialStudentA;
    _studentB = widget.initialStudentB;
  }

  void _showStudentPicker(bool isPickingA, List<Student> students) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Student ${isPickingA ? 'A' : 'B'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.borderGrey),
                  itemBuilder: (context, index) {
                    final s = students[index];
                    final isSelected = isPickingA ? (_studentA?.rollNo == s.rollNo) : (_studentB?.rollNo == s.rollNo);
                    final isOtherSelected = isPickingA ? (_studentB?.rollNo == s.rollNo) : (_studentA?.rollNo == s.rollNo);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? AppTheme.secondaryElectric : AppTheme.backgroundLight,
                        child: Text(
                          s.initials,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.primaryNavy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        s.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      subtitle: Text('${s.rollNo} • Avg: ${s.averageMark != null ? '${s.averageMark!.toStringAsFixed(1)}%' : 'N/A'}'),
                      trailing: isOtherSelected
                          ? const Text('(Selected as other)', style: TextStyle(fontSize: 11, color: AppTheme.neutralGrey))
                          : (isSelected ? const Icon(Icons.check_circle, color: AppTheme.positiveGreen) : null),
                      onTap: () {
                        setState(() {
                          if (isPickingA) {
                            _studentA = s;
                          } else {
                            _studentB = s;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Comparison indicator helper:
  /// Returns 1 if valA > valB, -1 if valB > valA, 0 if equal, null if cannot compare
  int? _compareValues(double? valA, double? valB) {
    if (valA == null || valB == null) return null;
    if (valA > valB) return 1;
    if (valB > valA) return -1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final studentService = Provider.of<StudentService>(context);
    final allStudents = studentService.students;

    // Automatically set default students if not provided and list is available
    if (_studentA == null && allStudents.isNotEmpty) {
      _studentA = allStudents[0];
    }
    if (_studentB == null && allStudents.length > 1) {
      _studentB = allStudents[1];
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Student Comparison'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: allStudents.isEmpty
          ? const Center(
              child: Text('No student records available to compare.'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Selection Cards (Side-by-side)
                  Row(
                    children: [
                      // Student A Selector
                      Expanded(
                        child: _StudentSelectorCard(
                          slotLabel: 'Student A',
                          student: _studentA,
                          onTap: () => _showStudentPicker(true, allStudents),
                          accentColor: AppTheme.secondaryElectric,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Student B Selector
                      Expanded(
                        child: _StudentSelectorCard(
                          slotLabel: 'Student B',
                          student: _studentB,
                          onTap: () => _showStudentPicker(false, allStudents),
                          accentColor: AppTheme.accentCyan,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (_studentA != null && _studentB != null) ...[
                    // Comparison Metrics Table
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                        border: Border.all(color: AppTheme.borderGrey),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Assessment Comparison Table',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.positiveGreenBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check_circle, size: 12, color: AppTheme.positiveGreen),
                                      SizedBox(width: 4),
                                      Text(
                                        'Higher highlighted',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF065F46),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppTheme.borderGrey),

                          // Table Rows
                          _ComparisonRow(
                            metric: 'Roll Number',
                            valA: _studentA!.rollNo,
                            valB: _studentB!.rollNo,
                            isNumeric: false,
                          ),
                          _ComparisonRow(
                            metric: '10th Board Marks',
                            valA: Student.formatScore(_studentA!.marks10th),
                            valB: Student.formatScore(_studentB!.marks10th),
                            comparisonResult: _compareValues(_studentA!.marks10th, _studentB!.marks10th),
                          ),
                          _ComparisonRow(
                            metric: '12th / Diploma Marks',
                            valA: Student.formatScore(_studentA!.marks12th),
                            valB: Student.formatScore(_studentB!.marks12th),
                            comparisonResult: _compareValues(_studentA!.marks12th, _studentB!.marks12th),
                          ),
                          _ComparisonRow(
                            metric: 'Semester 1 Marks',
                            valA: Student.formatScore(_studentA!.sem1),
                            valB: Student.formatScore(_studentB!.sem1),
                            comparisonResult: _compareValues(_studentA!.sem1, _studentB!.sem1),
                          ),
                          _ComparisonRow(
                            metric: 'Semester 2 Marks',
                            valA: Student.formatScore(_studentA!.sem2),
                            valB: Student.formatScore(_studentB!.sem2),
                            comparisonResult: _compareValues(_studentA!.sem2, _studentB!.sem2),
                          ),
                          _ComparisonRow(
                            metric: 'Overall Average',
                            valA: _studentA!.averageMark != null
                                ? '${_studentA!.averageMark!.toStringAsFixed(1)}%'
                                : 'N/A',
                            valB: _studentB!.averageMark != null
                                ? '${_studentB!.averageMark!.toStringAsFixed(1)}%'
                                : 'N/A',
                            comparisonResult: _compareValues(_studentA!.averageMark, _studentB!.averageMark),
                            isHighlightTotal: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick Summary Analysis Card
                    _ComparisonSummaryCard(studentA: _studentA!, studentB: _studentB!),
                  ] else ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'Please select two students above to view comparison.',
                          style: TextStyle(color: AppTheme.neutralGrey),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _StudentSelectorCard extends StatelessWidget {
  final String slotLabel;
  final Student? student;
  final VoidCallback onTap;
  final Color accentColor;

  const _StudentSelectorCard({
    required this.slotLabel,
    required this.student,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      slotLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppTheme.neutralGrey),
                  ],
                ),
                const SizedBox(height: 8),
                if (student != null) ...[
                  Text(
                    student!.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student!.rollNo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.neutralGrey,
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Select Student',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.neutralGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String metric;
  final String valA;
  final String valB;
  final int? comparisonResult; // 1 = A higher, -1 = B higher, 0 = equal, null = n/a
  final bool isNumeric;
  final bool isHighlightTotal;

  const _ComparisonRow({
    required this.metric,
    required this.valA,
    required this.valB,
    this.comparisonResult,
    this.isNumeric = true,
    this.isHighlightTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool aIsHigher = comparisonResult == 1;
    final bool bIsHigher = comparisonResult == -1;

    return Container(
      color: isHighlightTotal ? AppTheme.backgroundLight : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              metric,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isHighlightTotal ? FontWeight.bold : FontWeight.w500,
                color: AppTheme.primaryNavy,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _ValueCell(
              value: valA,
              isWinner: aIsHigher,
              isHighlightTotal: isHighlightTotal,
            ),
          ),
          Expanded(
            flex: 3,
            child: _ValueCell(
              value: valB,
              isWinner: bIsHigher,
              isHighlightTotal: isHighlightTotal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  final String value;
  final bool isWinner;
  final bool isHighlightTotal;

  const _ValueCell({
    required this.value,
    required this.isWinner,
    required this.isHighlightTotal,
  });

  @override
  Widget build(BuildContext context) {
    if (isWinner) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.positiveGreenBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.positiveGreen.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF065F46),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_upward, size: 12, color: AppTheme.positiveGreen),
          ],
        ),
      );
    }

    return Text(
      value,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        fontWeight: isHighlightTotal ? FontWeight.bold : FontWeight.normal,
        color: value == 'N/A' ? AppTheme.neutralGrey : AppTheme.primaryNavy,
      ),
    );
  }
}

class _ComparisonSummaryCard extends StatelessWidget {
  final Student studentA;
  final Student studentB;

  const _ComparisonSummaryCard({
    required this.studentA,
    required this.studentB,
  });

  @override
  Widget build(BuildContext context) {
    final avgA = studentA.averageMark;
    final avgB = studentB.averageMark;

    String conclusion = 'Both students demonstrate strong academic commitment.';
    if (avgA != null && avgB != null) {
      final diff = (avgA - avgB).abs().toStringAsFixed(1);
      if (avgA > avgB) {
        conclusion = '${studentA.name} leads overall average by $diff% over ${studentB.name}.';
      } else if (avgB > avgA) {
        conclusion = '${studentB.name} leads overall average by $diff% over ${studentA.name}.';
      } else {
        conclusion = '${studentA.name} and ${studentB.name} have identical overall averages.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryElectric.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline, color: AppTheme.secondaryElectric, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comparative Insight',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  conclusion,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.neutralGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

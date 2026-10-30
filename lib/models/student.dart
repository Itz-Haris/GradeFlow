import 'dart:math' as math;

/// Represents a student academic record in GradeFlow.
///
/// Designed to parse records from Google Sheets JSON API with complete fault tolerance.
/// Missing, blank, or non-numeric marks are strictly represented as `null` and
/// NEVER assumed to be zero.
class Student {
  final int srNo;
  final String rollNo;
  final String name;
  final double? marks10th;
  final double? marks12th;
  final double? sem1;
  final double? sem2;

  const Student({
    required this.srNo,
    required this.rollNo,
    required this.name,
    this.marks10th,
    this.marks12th,
    this.sem1,
    this.sem2,
  });

  /// Safely extracts and parses numeric scores from various types (int, double, String, null).
  ///
  /// Returns `null` if the value is missing, empty, or cannot be parsed as a positive number.
  static double? _parseScore(dynamic value) {
    if (value == null) return null;
    
    // Direct numeric types
    if (value is num) {
      if (value.isNaN || value.isInfinite) return null;
      return value.toDouble();
    }

    // String representations (e.g. "85.5", "  90  ", "N/A", "-")
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty ||
          trimmed.toUpperCase() == 'N/A' ||
          trimmed.toUpperCase() == 'NA' ||
          trimmed == '-' ||
          trimmed == 'null') {
        return null;
      }
      // Remove any trailing percentage signs if present (e.g. "85.5%")
      final cleaned = trimmed.replaceAll('%', '').trim();
      final parsed = double.tryParse(cleaned);
      if (parsed != null && !parsed.isNaN && !parsed.isInfinite) {
        return parsed;
      }
    }
    return null;
  }

  /// Factory constructor to parse student records from Google Sheets JSON response.
  /// Supports multiple variations of column header keys.
  factory Student.fromJson(Map<String, dynamic> json) {
    // Helper to find value from multiple potential key names
    dynamic findKey(List<String> candidateKeys) {
      for (final key in candidateKeys) {
        if (json.containsKey(key) && json[key] != null) {
          return json[key];
        }
      }
      return null;
    }

    // Serial number parsing
    final rawSr = findKey(['Sr No', 'srNo', 'Sr. No', 'Sr.No', 'sr_no', 'Serial No', 'id']);
    int parsedSr = 0;
    if (rawSr is num) {
      parsedSr = rawSr.toInt();
    } else if (rawSr is String) {
      parsedSr = int.tryParse(rawSr.trim()) ?? 0;
    }

    // Roll number parsing
    final rawRoll = findKey(['Roll No', 'rollNo', 'Roll. No', 'Roll_No', 'Roll Number', 'roll_no']);
    final parsedRoll = rawRoll != null ? rawRoll.toString().trim() : 'N/A';

    // Name parsing
    final rawName = findKey(['Student Name', 'name', 'Student_Name', 'studentName', 'Name']);
    final parsedName = (rawName != null && rawName.toString().trim().isNotEmpty)
        ? rawName.toString().trim()
        : 'Unnamed Student';

    // Academic scores parsing
    final raw10th = findKey(['10th', 'marks10th', '10th Marks', '10th_marks', 'Tenth']);
    final raw12th = findKey(['12th', 'marks12th', '12th Marks', '12th_marks', 'Twelfth', 'Diploma']);
    final rawSem1 = findKey(['Sem 1', 'sem1', 'Semester 1', 'Sem_1', 'Sem1', 'Semester_1']);
    final rawSem2 = findKey(['Sem 2', 'sem2', 'Semester 2', 'Sem_2', 'Sem2', 'Semester_2']);

    return Student(
      srNo: parsedSr,
      rollNo: parsedRoll,
      name: parsedName,
      marks10th: _parseScore(raw10th),
      marks12th: _parseScore(raw12th),
      sem1: _parseScore(rawSem1),
      sem2: _parseScore(rawSem2),
    );
  }

  /// Converts the Student object into a standard Map structure
  Map<String, dynamic> toJson() {
    return {
      'Sr No': srNo,
      'Roll No': rollNo,
      'Student Name': name,
      '10th': marks10th,
      '12th': marks12th,
      'Sem 1': sem1,
      'Sem 2': sem2,
    };
  }

  /// List of only valid, non-null academic marks available for this student.
  List<double> get availableMarks {
    final List<double> marks = [];
    if (marks10th != null) marks.add(marks10th!);
    if (marks12th != null) marks.add(marks12th!);
    if (sem1 != null) marks.add(sem1!);
    if (sem2 != null) marks.add(sem2!);
    return marks;
  }

  /// Count of assessments that have valid scores recorded
  int get availableMarksCount => availableMarks.length;

  /// Whether at least one assessment score is available
  bool get hasMarks => availableMarks.isNotEmpty;

  /// Calculates the average across all available marks.
  ///
  /// Strictly excludes missing (null) values from the denominator.
  /// Returns `null` if no assessments have been recorded.
  double? get averageMark {
    final list = availableMarks;
    if (list.isEmpty) return null;
    final total = list.reduce((a, b) => a + b);
    return total / list.length;
  }

  /// Highest score achieved among all recorded assessments.
  ///
  /// Returns `null` if no scores exist.
  double? get highestMark {
    final list = availableMarks;
    if (list.isEmpty) return null;
    return list.reduce(math.max);
  }

  /// Lowest score achieved among all recorded assessments.
  ///
  /// Returns `null` if no scores exist.
  double? get lowestMark {
    final list = availableMarks;
    if (list.isEmpty) return null;
    return list.reduce(math.min);
  }

  /// Helper to format a nullable score as a readable string (e.g. "85.5" or "N/A").
  static String formatScore(double? score, {int decimalPlaces = 1}) {
    if (score == null) return 'N/A';
    if (score == score.roundToDouble()) {
      return score.toInt().toString();
    }
    return score.toStringAsFixed(decimalPlaces);
  }

  /// Calculates percentage relative to configurable maximum marks (default 100.0).
  /// Returns a fraction between 0.0 and 1.0, or `null` if score is missing.
  static double? getFraction(double? score, double maxMarks) {
    if (score == null || maxMarks <= 0) return null;
    return (score / maxMarks).clamp(0.0, 1.0);
  }

  /// Returns student initials for avatar display (e.g., "Aarav Sharma" -> "AS")
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  Student copyWith({
    int? srNo,
    String? rollNo,
    String? name,
    double? marks10th,
    double? marks12th,
    double? sem1,
    double? sem2,
  }) {
    return Student(
      srNo: srNo ?? this.srNo,
      rollNo: rollNo ?? this.rollNo,
      name: name ?? this.name,
      marks10th: marks10th ?? this.marks10th,
      marks12th: marks12th ?? this.marks12th,
      sem1: sem1 ?? this.sem1,
      sem2: sem2 ?? this.sem2,
    );
  }

  @override
  String toString() {
    return 'Student(sr: $srNo, roll: $rollNo, name: $name, 10th: $marks10th, 12th: $marks12th, sem1: $sem1, sem2: $sem2)';
  }
}

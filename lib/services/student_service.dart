import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';

/// PLACEHOLDER REQUIRED BY SPECIFICATION:
/// Replace this string with your deployed Google Apps Script Web App URL.
/// Example: https://script.google.com/macros/s/AKfycbx.../exec
const String googleSheetsApiUrl = 'PASTE_YOUR_APPS_SCRIPT_WEB_APP_URL_HERE';

/// StudentService manages the data state, API communications with Google Sheets,
/// demo mode switching, calculation of dynamic academic statistics, and configuration.
///
/// Implements ChangeNotifier so UI screens automatically update on changes.
class StudentService extends ChangeNotifier {
  // Active student records list
  List<Student> _students = [];
  
  // State flags
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  
  // API & Demo Mode configuration
  // Starts in Demo Mode until the user inputs their live Google Apps Script URL.
  bool _isDemoMode = true;
  String _activeApiUrl = googleSheetsApiUrl;
  double _maxMarks = 100.0;
  DateTime? _lastSyncTime;
  ThemeMode _themeMode = ThemeMode.light;

  // Persistence keys
  static const String _prefKeyApiUrl = 'gradeflow_api_url';
  static const String _prefKeyDemoMode = 'gradeflow_demo_mode';
  static const String _prefKeyMaxMarks = 'gradeflow_max_marks';
  static const String _prefKeyThemeMode = 'gradeflow_theme_mode';

  // Request timeout duration
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // Getters
  List<Student> get students => List.unmodifiable(_students);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get isDemoMode => _isDemoMode;
  String get activeApiUrl => _activeApiUrl;
  double get maxMarks => _maxMarks;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get hasData => _students.isNotEmpty;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  StudentService() {
    _initializePreferencesAndLoad();
  }

  /// Sets the application theme mode (light, dark, system)
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyThemeMode, mode.name);
    } catch (_) {}
  }

  /// Toggles between Light and Dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// Loads saved preferences and initializes dataset
  Future<void> _initializePreferencesAndLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _activeApiUrl = prefs.getString(_prefKeyApiUrl) ?? googleSheetsApiUrl;
      _isDemoMode = prefs.getBool(_prefKeyDemoMode) ?? true;
      _maxMarks = prefs.getDouble(_prefKeyMaxMarks) ?? 100.0;
      final savedTheme = prefs.getString(_prefKeyThemeMode);
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedTheme == 'system') {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
    } catch (e) {
      debugPrint('SharedPreferences init note: $e');
    }

    if (_isDemoMode || _activeApiUrl == googleSheetsApiUrl) {
      loadDemoData();
    } else {
      fetchStudents();
    }
  }

  /// Sets configurable maximum marks (e.g. 100, 75, 50)
  Future<void> setMaxMarks(double value) async {
    if (value <= 0) return;
    _maxMarks = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefKeyMaxMarks, value);
    } catch (_) {}
  }

  /// Switches between Demo Mode and Live API Mode
  Future<void> toggleDemoMode(bool enableDemo) async {
    _isDemoMode = enableDemo;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyDemoMode, enableDemo);
    } catch (_) {}

    if (enableDemo) {
      loadDemoData();
    } else {
      fetchStudents(forceRefresh: true);
    }
  }

  /// Updates the Google Apps Script Web App URL and saves to local storage
  Future<void> updateApiUrl(String newUrl) async {
    final trimmed = newUrl.trim();
    _activeApiUrl = trimmed.isEmpty ? googleSheetsApiUrl : trimmed;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyApiUrl, _activeApiUrl);
    } catch (_) {}

    if (_activeApiUrl != googleSheetsApiUrl && _activeApiUrl.startsWith('http')) {
      _isDemoMode = false;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKeyDemoMode, false);
      } catch (_) {}
      fetchStudents(forceRefresh: true);
    }
  }

  /// Loads separate, clearly labelled sample student records for demonstration.
  /// Never mixes with live Google Sheets records.
  void loadDemoData() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Fictional academic records for first-year Robotics & Automation practical demo
    // Includes varying scenarios: High distinctions, missing 12th (diploma entrant), missing Sem 2
    final List<Student> sampleList = [
      const Student(
        srNo: 1,
        rollNo: 'RA-2026-001',
        name: 'Aarav Sharma',
        marks10th: 92.5,
        marks12th: 88.0,
        sem1: 85.5,
        sem2: 91.0,
      ),
      const Student(
        srNo: 2,
        rollNo: 'RA-2026-002',
        name: 'Diya Patel',
        marks10th: 95.0,
        marks12th: 94.5,
        sem1: 92.0,
        sem2: 96.0,
      ),
      const Student(
        srNo: 3,
        rollNo: 'RA-2026-003',
        name: 'Rohan Verma',
        marks10th: 78.0,
        marks12th: 72.5,
        sem1: 68.0,
        sem2: 74.5,
      ),
      const Student(
        srNo: 4,
        rollNo: 'RA-2026-004',
        name: 'Ananya Iyer',
        marks10th: 88.0,
        marks12th: 85.0,
        sem1: 79.5,
        sem2: 83.0,
      ),
      const Student(
        srNo: 5,
        rollNo: 'RA-2026-005',
        name: 'Kabir Mehta',
        marks10th: 81.0,
        marks12th: null, // Diploma lateral entry student — 12th marks missing
        sem1: 76.0,
        sem2: 82.5,
      ),
      const Student(
        srNo: 6,
        rollNo: 'RA-2026-006',
        name: 'Sneha Kulkarni',
        marks10th: 89.5,
        marks12th: 91.0,
        sem1: 88.0,
        sem2: 89.5,
      ),
      const Student(
        srNo: 7,
        rollNo: 'RA-2026-007',
        name: 'Vikramaditya Roy',
        marks10th: 65.0,
        marks12th: 58.5,
        sem1: 52.0,
        sem2: 60.5,
      ),
      const Student(
        srNo: 8,
        rollNo: 'RA-2026-008',
        name: 'Pooja Nair',
        marks10th: 74.0,
        marks12th: 70.0,
        sem1: 72.5,
        sem2: null, // Medical leave during Semester 2 — Sem 2 mark pending
      ),
      const Student(
        srNo: 9,
        rollNo: 'RA-2026-009',
        name: 'Arjun Das',
        marks10th: 58.0,
        marks12th: 52.0,
        sem1: 44.0,
        sem2: 48.5,
      ),
      const Student(
        srNo: 10,
        rollNo: 'RA-2026-010',
        name: 'Meera Nambiar',
        marks10th: 94.0,
        marks12th: 92.5,
        sem1: 90.0,
        sem2: 93.5,
      ),
    ];

    _students = sampleList;
    _lastSyncTime = DateTime.now();
    _isLoading = false;
    notifyListeners();
  }

  /// Fetches live student records from Google Apps Script Web App endpoint.
  /// Handles HTTP errors, timeouts, invalid JSON, and keeps previous dataset visible during refresh.
  Future<void> fetchStudents({bool forceRefresh = false}) async {
    // If in demo mode and not explicitly asking for live fetch, keep demo
    if (_isDemoMode && !forceRefresh) {
      loadDemoData();
      return;
    }

    // Validate API URL configuration
    if (_activeApiUrl == googleSheetsApiUrl ||
        _activeApiUrl.trim().isEmpty ||
        !_activeApiUrl.startsWith('http')) {
      _errorMessage =
          'Google Apps Script Web App URL is not configured. Please paste your deployed Web App URL in Settings or enable Demo Mode.';
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
      return;
    }

    // Keep previous data visible during refresh
    if (_students.isNotEmpty) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse(_activeApiUrl);
      final response = await http.get(uri).timeout(_timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 302) {
        final body = response.body.trim();
        if (body.isEmpty) {
          throw const FormatException('Empty response received from Google Sheets API.');
        }

        final dynamic decoded = jsonDecode(body);
        List<dynamic> jsonList = [];

        if (decoded is List) {
          jsonList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded['status'] == 'error') {
            throw Exception(decoded['message'] ?? 'API returned an error.');
          }
          if (decoded.containsKey('data') && decoded['data'] is List) {
            jsonList = decoded['data'] as List<dynamic>;
          } else if (decoded.containsKey('records') && decoded['records'] is List) {
            jsonList = decoded['records'] as List<dynamic>;
          } else if (decoded.containsKey('students') && decoded['students'] is List) {
            jsonList = decoded['students'] as List<dynamic>;
          } else {
            throw const FormatException('Unable to locate student records array in JSON response.');
          }
        } else {
          throw const FormatException('Expected a JSON array or object containing student records.');
        }

        final List<Student> parsedStudents = [];
        for (var i = 0; i < jsonList.length; i++) {
          final item = jsonList[i];
          if (item is Map<String, dynamic>) {
            // Check for completely blank row
            final student = Student.fromJson(item);
            if (student.name.isNotEmpty && student.name != 'Unnamed Student') {
              parsedStudents.add(student);
            }
          }
        }

        if (parsedStudents.isEmpty) {
          _errorMessage = 'Spreadsheet is reachable, but no valid student rows were found.';
        } else {
          _students = parsedStudents;
          _isDemoMode = false;
          _lastSyncTime = DateTime.now();
          _errorMessage = null;
        }
      } else {
        _errorMessage = 'Server returned HTTP ${response.statusCode}: ${response.reasonPhrase}';
      }
    } on SocketException {
      _errorMessage = 'Network connection failed. Please check your internet connectivity.';
    } on TimeoutException {
      _errorMessage = 'Connection timed out after 15 seconds. Google Apps Script is taking too long to respond.';
    } on FormatException catch (fe) {
      _errorMessage = 'Invalid response format from Google Apps Script: ${fe.message}';
    } catch (e) {
      _errorMessage = 'An error occurred while fetching records: $e';
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // DYNAMIC ACADEMIC STATISTICS (Calculated on-the-fly, not hardcoded)
  // -------------------------------------------------------------

  /// Total count of students currently loaded
  int get totalStudents => _students.length;

  /// Dynamic average of 10th marks across all students with valid 10th scores
  double? get avg10th {
    final valid = _students
        .map((s) => s.marks10th)
        .where((m) => m != null)
        .cast<double>()
        .toList();
    if (valid.isEmpty) return null;
    return valid.reduce((a, b) => a + b) / valid.length;
  }

  /// Dynamic average of 12th marks across all students with valid 12th scores
  double? get avg12th {
    final valid = _students
        .map((s) => s.marks12th)
        .where((m) => m != null)
        .cast<double>()
        .toList();
    if (valid.isEmpty) return null;
    return valid.reduce((a, b) => a + b) / valid.length;
  }

  /// Dynamic average of Semester 1 marks
  double? get avgSem1 {
    final valid = _students
        .map((s) => s.sem1)
        .where((m) => m != null)
        .cast<double>()
        .toList();
    if (valid.isEmpty) return null;
    return valid.reduce((a, b) => a + b) / valid.length;
  }

  /// Dynamic average of Semester 2 marks
  double? get avgSem2 {
    final valid = _students
        .map((s) => s.sem2)
        .where((m) => m != null)
        .cast<double>()
        .toList();
    if (valid.isEmpty) return null;
    return valid.reduce((a, b) => a + b) / valid.length;
  }

  /// Overall cohort average across all valid assessments
  double? get cohortAverage {
    final List<double> allScores = [];
    for (final s in _students) {
      allScores.addAll(s.availableMarks);
    }
    if (allScores.isEmpty) return null;
    return allScores.reduce((a, b) => a + b) / allScores.length;
  }

  /// Highest recorded individual assessment score in the entire cohort
  double? get highestRecordedMark {
    double? highest;
    for (final s in _students) {
      final sHigh = s.highestMark;
      if (sHigh != null) {
        if (highest == null || sHigh > highest) {
          highest = sHigh;
        }
      }
    }
    return highest;
  }

  /// Lowest recorded individual assessment score in the entire cohort
  double? get lowestRecordedMark {
    double? lowest;
    for (final s in _students) {
      final sLow = s.lowestMark;
      if (sLow != null) {
        if (lowest == null || sLow < lowest) {
          lowest = sLow;
        }
      }
    }
    return lowest;
  }

  /// Count of students who have at least one assessment score recorded
  int get studentsWithRecordsCount {
    return _students.where((s) => s.hasMarks).length;
  }

  /// Performance distribution calculation for customizable ranges:
  /// Default brackets:
  /// - 0–39 (Needs Attention)
  /// - 40–59 (Average / Pass)
  /// - 60–79 (Good / First Class)
  /// - 80–100 (Distinction)
  Map<String, int> getPerformanceDistribution(String metric) {
    int range0to39 = 0;
    int range40to59 = 0;
    int range60to79 = 0;
    int range80to100 = 0;

    for (final s in _students) {
      double? score;
      switch (metric) {
        case 'Sem 1':
          score = s.sem1;
          break;
        case 'Sem 2':
          score = s.sem2;
          break;
        case '10th':
          score = s.marks10th;
          break;
        case '12th':
          score = s.marks12th;
          break;
        case 'Average':
        default:
          score = s.averageMark;
          break;
      }

      if (score != null) {
        if (score < 40.0) {
          range0to39++;
        } else if (score < 60.0) {
          range40to59++;
        } else if (score < 80.0) {
          range60to79++;
        } else {
          range80to100++;
        }
      }
    }

    return {
      '0–39': range0to39,
      '40–59': range40to59,
      '60–79': range60to79,
      '80–100': range80to100,
    };
  }
}
